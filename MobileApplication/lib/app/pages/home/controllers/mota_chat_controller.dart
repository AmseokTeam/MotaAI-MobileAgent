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
    _isSending = true;
    _errorText = null;
    notifyListeners();

    try {
      final reply = await _requestReply();
      _messages.add(_createMessage(MotaChatSender.assistant, reply));
    } on MotaChatException catch (error) {
      _errorText = error.message;
    } on TimeoutException {
      _errorText = 'Mota 响应超时，请稍后再试';
    } on SocketException {
      _errorText = '网络连接失败，请检查网络后再试';
    } on FormatException {
      _errorText = 'Mota 返回的数据格式无法识别';
    } catch (_) {
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

  Future<String> _requestReply() async {
    final profile = await _settingsStore.readSelectedProfile();
    if (profile == null || !profile.isReady) {
      throw const MotaChatException('请点击输入框左侧 + 添加并选择 AI');
    }

    final request = await _httpClient
        .postUrl(_chatCompletionsUri(MotaLlmSettingsStore.defaultBaseUrl))
        .timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${profile.apiKey}',
    );
    request.write(
      jsonEncode(<String, Object>{
        'model': profile.modelName,
        'messages': <Map<String, String>>[
          <String, String>{
            'role': 'system',
            'content': '你是 Mota，一个温柔、简洁、会陪用户聊天的机器人伙伴。',
          },
          ..._conversationPayload(),
        ],
        'temperature': 0.7,
      }),
    );

    final response = await request.close().timeout(_timeout);
    final responseText = await utf8.decoder.bind(response).join();
    final payload = jsonDecode(responseText) as Map<String, dynamic>;

    if (response.statusCode < HttpStatus.ok ||
        response.statusCode >= HttpStatus.multipleChoices) {
      throw MotaChatException(_readApiError(payload));
    }

    final choices = payload['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const FormatException('choices is empty');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      throw const FormatException('choice is invalid');
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      throw const FormatException('message is invalid');
    }

    final content = message['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const FormatException('content is empty');
    }

    return content.trim();
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
    return _messages.skip(start).map((message) {
      return <String, String>{
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      };
    }).toList(growable: false);
  }

  String _readApiError(Map<String, dynamic> payload) {
    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return 'Mota 请求失败：${message.trim()}';
      }
    }
    return 'Mota 请求失败，请稍后再试';
  }

  MotaChatMessage _createMessage(MotaChatSender sender, String text) {
    return MotaChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: sender,
      text: text,
      createdAt: DateTime.now(),
    );
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
