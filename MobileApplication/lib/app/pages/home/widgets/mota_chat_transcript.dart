// 文件作用：展示 Mota 文本对话消息列表、等待状态和错误提示。

import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../controllers/mota_chat_controller.dart';
import '../models/mota_chat_message.dart';

class MotaChatTranscript extends StatelessWidget {
  const MotaChatTranscript({required this.chatController, super.key});

  final MotaChatController chatController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatController,
      builder: (context, child) {
        final messages = chatController.messages;
        final errorText = chatController.errorText;
        if (messages.isEmpty &&
            !chatController.isSending &&
            errorText == null) {
          return const SizedBox.expand();
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            for (final message in messages)
              _MotaMessageBubble(message: message),
            if (chatController.isSending) const _MotaThinkingBubble(),
            if (errorText != null) _MotaErrorBubble(message: errorText),
          ],
        );
      },
    );
  }
}

class _MotaMessageBubble extends StatelessWidget {
  const _MotaMessageBubble({required this.message});

  final MotaChatMessage message;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = message.isUser ? AppColors.ink : AppColors.cardSoft;
    final textColor = message.isUser ? Colors.white : AppColors.ink;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.muted.withValues(alpha: 0.18)),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _MotaThinkingBubble extends StatelessWidget {
  const _MotaThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.muted.withValues(alpha: 0.18)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 9),
            Text(
              'Mota 正在思考',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotaErrorBubble extends StatelessWidget {
  const _MotaErrorBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.danger,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
