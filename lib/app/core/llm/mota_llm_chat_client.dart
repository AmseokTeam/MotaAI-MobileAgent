// 文件作用：封装 Mota 对话使用的大模型 Chat Completions 请求和 SSE 增量解析。

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'mota_llm_settings_store.dart';

class MotaLlmChatClient {
  MotaLlmChatClient({
    HttpClient? httpClient,
    Duration timeout = const Duration(seconds: 30),
  })  : _httpClient = httpClient ?? HttpClient(),
        _timeout = timeout;

  final HttpClient _httpClient;
  final Duration _timeout;

  Future<void> streamChatCompletion({
    required MotaLlmProfile profile,
    required List<MotaLlmChatMessage> messages,
    required void Function(String text) onText,
  }) async {
    final requestUri = buildMotaLlmChatCompletionsUri(profile.baseUrl);
    final request = await _httpClient.postUrl(requestUri).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${profile.apiKey}',
    );
    request.write(jsonEncode(
      buildMotaLlmChatRequestBody(
        profile: profile,
        messages: messages,
      ),
    ));

    final response = await request.close().timeout(_timeout);
    if (response.statusCode < HttpStatus.ok ||
        response.statusCode >= HttpStatus.multipleChoices) {
      final responseText = await utf8.decoder.bind(response).join();
      final payload = _decodeResponsePayload(responseText);
      debugPrint(
        'Mota LLM request failed: provider=${profile.providerName}, '
        'model=${profile.modelName}, status=${response.statusCode}, '
        'response=${_responsePreview(responseText, maxLength: 500)}',
      );
      throw MotaLlmChatException(_readApiError(
        payload: payload,
        responseText: responseText,
        statusCode: response.statusCode,
        providerName: profile.providerName,
        requestUri: requestUri,
      ));
    }

    final reply = await _readStreamingReply(response, onText);
    if (reply.trim().isEmpty) {
      throw const FormatException('stream content is empty');
    }
  }

  Future<String> _readStreamingReply(
    HttpClientResponse response,
    void Function(String text) onText,
  ) async {
    final buffer = StringBuffer();
    var pendingText = '';

    await for (final chunk in utf8.decoder.bind(response).timeout(_timeout)) {
      pendingText += chunk;
      final lines = pendingText.split('\n');
      pendingText = lines.removeLast();

      for (final line in lines) {
        final delta = readMotaLlmStreamingDelta(line);
        if (delta == null || delta.isEmpty) {
          continue;
        }

        buffer.write(delta);
        onText(buffer.toString());
      }
    }

    final trailingDelta = readMotaLlmStreamingDelta(pendingText);
    if (trailingDelta != null && trailingDelta.isNotEmpty) {
      buffer.write(trailingDelta);
      onText(buffer.toString());
    }

    return buffer.toString();
  }

  Map<String, dynamic>? _decodeResponsePayload(String responseText) {
    if (responseText.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(responseText);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  String _readApiError({
    required Map<String, dynamic>? payload,
    required String responseText,
    required int statusCode,
    required String providerName,
    required Uri requestUri,
  }) {
    final target =
        '${requestUri.scheme}://${requestUri.host}${requestUri.path}';
    final error = payload?['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return '$providerName 请求失败 ($statusCode)：${message.trim()}\n$target';
      }
    }

    final message = payload?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return '$providerName 请求失败 ($statusCode)：${message.trim()}\n$target';
    }

    final compactBody = _responsePreview(responseText, maxLength: 300);
    if (compactBody.isNotEmpty) {
      return '$providerName 请求失败 ($statusCode)：$compactBody\n$target';
    }

    return '$providerName 请求失败 ($statusCode)，请检查接口、模型名、Key 或额度\n$target';
  }

  String _responsePreview(String responseText, {required int maxLength}) {
    final compactBody = responseText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compactBody.length <= maxLength) {
      return compactBody;
    }
    return '${compactBody.substring(0, maxLength)}...';
  }

  void close({bool force = true}) {
    _httpClient.close(force: force);
  }
}

class MotaLlmChatMessage {
  const MotaLlmChatMessage({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  Map<String, String> toJson() {
    return <String, String>{
      'role': role,
      'content': content,
    };
  }
}

class MotaLlmChatException implements Exception {
  const MotaLlmChatException(this.message);

  final String message;
}

Map<String, Object> buildMotaLlmChatRequestBody({
  required MotaLlmProfile profile,
  required List<MotaLlmChatMessage> messages,
}) {
  final body = <String, Object>{
    'model': profile.modelName,
    'messages': messages.map((message) => message.toJson()).toList(),
    'stream': true,
  };

  if (profile.providerId == MotaLlmProviderPreset.kimi.id) {
    body['thinking'] = <String, String>{'type': 'disabled'};
  } else {
    body['temperature'] = 0.7;
  }

  return body;
}

Uri buildMotaLlmChatCompletionsUri(String baseUrl) {
  final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  if (normalizedBaseUrl.endsWith('/chat/completions')) {
    return Uri.parse(normalizedBaseUrl);
  }
  return Uri.parse('$normalizedBaseUrl/chat/completions');
}

String? readMotaLlmStreamingDelta(String rawLine) {
  final line = rawLine.trim();
  if (line.isEmpty || !line.startsWith('data:')) {
    return null;
  }

  final data = line.substring('data:'.length).trim();
  if (data == '[DONE]') {
    return null;
  }

  final decoded = jsonDecode(data);
  if (decoded is! Map<String, dynamic>) {
    return null;
  }

  final choices = decoded['choices'];
  if (choices is! List || choices.isEmpty) {
    return null;
  }

  final firstChoice = choices.first;
  if (firstChoice is! Map<String, dynamic>) {
    return null;
  }

  final delta = firstChoice['delta'];
  if (delta is! Map<String, dynamic>) {
    return null;
  }

  final content = delta['content'];
  return content is String ? content : null;
}
