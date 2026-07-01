// 文件作用：管理 Mota 文本对话的发送状态，并调用用户配置的大模型 API 获取回复。

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../models/mota_chat_message.dart';

class MotaChatController extends ChangeNotifier {
  MotaChatController({
    MotaLlmSettingsStore? settingsStore,
    HttpClient? httpClient,
    Duration timeout = const Duration(seconds: 30),
  })  : _settingsStore = settingsStore ?? MotaLlmSettingsStore(),
        _httpClient = httpClient ?? HttpClient(),
        _timeout = timeout;

  final MotaLlmSettingsStore _settingsStore;
  final HttpClient _httpClient;
  final Duration _timeout;
  final List<MotaChatMessage> _messages = <MotaChatMessage>[];

  bool _isSending = false;
  String? _errorText;

  List<MotaChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get errorText => _errorText;

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    _messages.add(_createMessage(MotaChatSender.user, text));
    final assistantMessage = _createMessage(MotaChatSender.assistant, '');
    _messages.add(assistantMessage);
    _isSending = true;
    _errorText = null;
    notifyListeners();

    try {
      await _requestReplyStream(assistantMessage.id);
    } on MotaChatException catch (error) {
      _removeEmptyAssistantMessage(assistantMessage.id);
      _errorText = error.message;
    } on TimeoutException {
      _removeEmptyAssistantMessage(assistantMessage.id);
      _errorText = 'Mota 响应超时，请稍后再试';
    } on SocketException {
      _removeEmptyAssistantMessage(assistantMessage.id);
      _errorText = '网络连接失败，请检查网络后再试';
    } on FormatException {
      _removeEmptyAssistantMessage(assistantMessage.id);
      _errorText = 'Mota 返回的数据格式无法识别';
    } catch (_) {
      _removeEmptyAssistantMessage(assistantMessage.id);
      _errorText = 'Mota 暂时没有回应，请稍后再试';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorText == null) {
      return;
    }
    _errorText = null;
    notifyListeners();
  }

  Future<void> _requestReplyStream(String assistantMessageId) async {
    final profile = await _settingsStore.readSelectedProfile();
    if (profile == null || !profile.isReady) {
      throw const MotaChatException('请点击输入框左侧 + 添加并选择 AI');
    }

    final requestUri = _chatCompletionsUri(profile.baseUrl);
    final request = await _httpClient.postUrl(requestUri).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${profile.apiKey}',
    );
    request.write(jsonEncode(_requestBody(profile)));

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
      throw MotaChatException(_readApiError(
        payload: payload,
        responseText: responseText,
        statusCode: response.statusCode,
        providerName: profile.providerName,
        requestUri: requestUri,
      ));
    }

    final reply = await _readStreamingReply(response, assistantMessageId);
    if (reply.trim().isEmpty) {
      throw const FormatException('stream content is empty');
    }
  }

  Uri _chatCompletionsUri(String baseUrl) {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalizedBaseUrl.endsWith('/chat/completions')) {
      return Uri.parse(normalizedBaseUrl);
    }
    return Uri.parse('$normalizedBaseUrl/chat/completions');
  }

  List<Map<String, String>> _conversationPayload() {
    final start = (_messages.length - 20).clamp(0, _messages.length);
    return _messages.skip(start).where((message) {
      return message.text.trim().isNotEmpty;
    }).map((message) {
      return <String, String>{
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      };
    }).toList(growable: false);
  }

  Map<String, Object> _requestBody(MotaLlmProfile profile) {
    final body = <String, Object>{
      'model': profile.modelName,
      'messages': <Map<String, String>>[
        <String, String>{
          'role': 'system',
          'content': '你是 Mota，一个温柔、简洁、会陪用户聊天的机器人伙伴。',
        },
        ..._conversationPayload(),
      ],
      'stream': true,
    };

    if (profile.providerId == MotaLlmProviderPreset.kimi.id) {
      body['thinking'] = <String, String>{'type': 'disabled'};
    } else {
      body['temperature'] = 0.7;
    }

    return body;
  }

  Future<String> _readStreamingReply(
    HttpClientResponse response,
    String assistantMessageId,
  ) async {
    final buffer = StringBuffer();
    var pendingText = '';

    await for (final chunk in utf8.decoder.bind(response).timeout(_timeout)) {
      pendingText += chunk;
      final lines = pendingText.split('\n');
      pendingText = lines.removeLast();

      for (final line in lines) {
        final delta = _readStreamingDelta(line);
        if (delta == null || delta.isEmpty) {
          continue;
        }

        buffer.write(delta);
        _updateAssistantMessage(assistantMessageId, buffer.toString());
      }
    }

    final trailingDelta = _readStreamingDelta(pendingText);
    if (trailingDelta != null && trailingDelta.isNotEmpty) {
      buffer.write(trailingDelta);
      _updateAssistantMessage(assistantMessageId, buffer.toString());
    }

    return buffer.toString();
  }

  String? _readStreamingDelta(String rawLine) {
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
    final target = '${requestUri.scheme}://${requestUri.host}${requestUri.path}';
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

  MotaChatMessage _createMessage(MotaChatSender sender, String text) {
    return MotaChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: sender,
      text: text,
      createdAt: DateTime.now(),
    );
  }

  void _updateAssistantMessage(String messageId, String text) {
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return;
    }

    _messages[index] = _messages[index].copyWith(text: text);
    notifyListeners();
  }

  void _removeEmptyAssistantMessage(String messageId) {
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1 || _messages[index].text.trim().isNotEmpty) {
      return;
    }

    _messages.removeAt(index);
  }

  @override
  void dispose() {
    _httpClient.close(force: true);
    super.dispose();
  }
}

class MotaChatException implements Exception {
  const MotaChatException(this.message);

  final String message;
}
