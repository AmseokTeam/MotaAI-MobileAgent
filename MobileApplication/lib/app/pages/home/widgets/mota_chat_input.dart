// 文件作用：提供 Mota 文本对话底部输入框。

import 'package:flutter/material.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../../../core/pc_bridge/pc_bridge_controller.dart';
import '../../../shared/theme/app_colors.dart';
import '../controllers/mota_chat_controller.dart';
import 'mota_action_drawer.dart';
import 'mota_ai_drawer.dart';
import 'mota_project_drawer.dart';

class MotaChatInput extends StatefulWidget {
  const MotaChatInput({
    required this.chatController,
    required this.bridgeController,
    super.key,
  });

  final MotaChatController chatController;
  final PcBridgeController bridgeController;

  @override
  State<MotaChatInput> createState() => _MotaChatInputState();
}

class _MotaChatInputState extends State<MotaChatInput> {
  late final TextEditingController _textController;
  final MotaLlmSettingsStore _settingsStore = MotaLlmSettingsStore();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.chatController,
      builder: (context, child) {
        final canSend = _textController.text.trim().isNotEmpty &&
            !widget.chatController.isSending;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.24),
          child: TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '输入你想说的话',
              hintStyle: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: IconButton(
                tooltip: '打开工具',
                onPressed: _showActionDrawer,
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.orange,
                  size: 24,
                ),
              ),
              suffixIcon: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: canSend
                      ? AppColors.ink
                      : AppColors.muted.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '发送',
                  onPressed: canSend ? _send : null,
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 17,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showActionDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => MotaActionDrawer(
        onOpenAi: _showAiDrawer,
        onOpenProject: _showProjectDrawer,
      ),
    );
  }

  Future<void> _showAiDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => MotaAiDrawer(
        settingsStore: _settingsStore,
        bridgeController: widget.bridgeController,
      ),
    );
  }

  Future<void> _showProjectDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => MotaProjectDrawer(
        bridgeController: widget.bridgeController,
      ),
    );
  }

  Future<void> _send() async {
    final text = _textController.text;
    if (text.trim().isEmpty || widget.chatController.isSending) {
      return;
    }

    _textController.clear();
    await widget.chatController.send(text);
  }

  void _onTextChanged() {
    setState(() {});
    widget.chatController.clearError();
  }
}
