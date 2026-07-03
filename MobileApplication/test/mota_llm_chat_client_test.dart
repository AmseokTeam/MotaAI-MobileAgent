import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/core/llm/mota_llm_chat_client.dart';
import 'package:milo_ai/app/core/llm/mota_llm_settings_store.dart';

void main() {
  test('buildMotaLlmChatCompletionsUri appends chat completions path once', () {
    expect(
      buildMotaLlmChatCompletionsUri('https://api.example.com/v1').toString(),
      'https://api.example.com/v1/chat/completions',
    );
    expect(
      buildMotaLlmChatCompletionsUri(
        'https://api.example.com/v1/chat/completions/',
      ).toString(),
      'https://api.example.com/v1/chat/completions',
    );
  });

  test('readMotaLlmStreamingDelta reads content from SSE data line', () {
    final payload = jsonEncode({
      'choices': [
        {
          'delta': {'content': '你好'},
        },
      ],
    });

    expect(readMotaLlmStreamingDelta('data: $payload'), '你好');
    expect(readMotaLlmStreamingDelta('data: [DONE]'), isNull);
    expect(readMotaLlmStreamingDelta(': keep-alive'), isNull);
  });

  test('buildMotaLlmChatRequestBody preserves provider-specific options', () {
    const messages = [
      MotaLlmChatMessage(role: 'user', content: '你好'),
    ];
    const kimiProfile = MotaLlmProfile(
      id: 'kimi-profile',
      kind: MotaLlmProfileKind.api,
      providerId: 'kimi',
      providerName: 'Kimi',
      baseUrl: 'https://api.moonshot.cn/v1',
      modelName: 'kimi-k2.6',
      apiKey: 'secret',
    );
    const customProfile = MotaLlmProfile(
      id: 'custom-profile',
      kind: MotaLlmProfileKind.api,
      providerId: 'custom',
      providerName: '自定义',
      baseUrl: 'https://api.example.com/v1',
      modelName: 'example-model',
      apiKey: 'secret',
    );

    expect(
      buildMotaLlmChatRequestBody(
        profile: kimiProfile,
        messages: messages,
      ),
      containsPair('thinking', {'type': 'disabled'}),
    );
    expect(
      buildMotaLlmChatRequestBody(
        profile: customProfile,
        messages: messages,
      ),
      containsPair('temperature', 0.7),
    );
  });
}
