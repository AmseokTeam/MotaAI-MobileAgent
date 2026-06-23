// 文件作用：提供 Mota 文本对话底部输入框，并在左侧管理可选 AI。

import 'package:flutter/material.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../../../shared/theme/app_colors.dart';
import '../controllers/mota_chat_controller.dart';

class MotaChatInput extends StatefulWidget {
  const MotaChatInput({required this.chatController, super.key});

  final MotaChatController chatController;

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
                tooltip: '选择 AI',
                onPressed: _showAiDrawer,
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

  Future<void> _showAiDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _MotaAiDrawer(settingsStore: _settingsStore),
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

class _MotaAiDrawer extends StatefulWidget {
  const _MotaAiDrawer({required this.settingsStore});

  final MotaLlmSettingsStore settingsStore;

  @override
  State<_MotaAiDrawer> createState() => _MotaAiDrawerState();
}

class _MotaAiDrawerState extends State<_MotaAiDrawer> {
  List<MotaLlmProfile> _profiles = <MotaLlmProfile>[];
  String? _selectedProfileId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '选择 AI',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '新增 AI',
                      onPressed: _showAddAiDialog,
                      icon: const Icon(Icons.add_circle_rounded),
                      color: AppColors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.ink,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_profiles.isEmpty)
                  _EmptyAiDrawer(onAdd: _showAddAiDialog)
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _profiles.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppColors.muted.withValues(alpha: 0.14),
                      ),
                      itemBuilder: (context, index) {
                        final profile = _profiles[index];
                        final selected = profile.id == _selectedProfileId;
                        return _AiProfileTile(
                          profile: profile,
                          selected: selected,
                          onTap: () => _selectProfile(profile),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadProfiles() async {
    final profiles = await widget.settingsStore.readProfiles();
    final selectedProfile = await widget.settingsStore.readSelectedProfile();
    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = profiles;
      _selectedProfileId = selectedProfile?.id;
      _loading = false;
    });
  }

  Future<void> _selectProfile(MotaLlmProfile profile) async {
    await widget.settingsStore.selectProfile(profile.id);
    if (!mounted) {
      return;
    }

    setState(() => _selectedProfileId = profile.id);
  }

  Future<void> _showAddAiDialog() async {
    final draft = await showDialog<_AiProfileDraft>(
      context: context,
      builder: (context) => const _AddAiDialog(),
    );
    if (draft == null) {
      return;
    }

    final profile = await widget.settingsStore.addProfile(
      modelName: draft.modelName,
      apiKey: draft.apiKey,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = <MotaLlmProfile>[..._profiles, profile];
      _selectedProfileId = profile.id;
    });
  }
}

class _EmptyAiDrawer extends StatelessWidget {
  const _EmptyAiDrawer({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.muted.withValues(alpha: 0.12)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_rounded, color: AppColors.orange, size: 36),
            SizedBox(height: 8),
            Text(
              '添加一个 AI',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiProfileTile extends StatelessWidget {
  const _AiProfileTile({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final MotaLlmProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.lime : AppColors.cardSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: selected ? AppColors.ink : AppColors.orange,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.modelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.maskedApiKey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.lime),
          ],
        ),
      ),
    );
  }
}

class _AddAiDialog extends StatefulWidget {
  const _AddAiDialog();

  @override
  State<_AddAiDialog> createState() => _AddAiDialogState();
}

class _AddAiDialogState extends State<_AddAiDialog> {
  late final TextEditingController _modelNameController;
  late final TextEditingController _apiKeyController;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController()..addListener(_onTextChanged);
    _apiKeyController = TextEditingController()..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _modelNameController
      ..removeListener(_onTextChanged)
      ..dispose();
    _apiKeyController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _modelNameController.text.trim().isNotEmpty &&
        _apiKeyController.text.trim().isNotEmpty;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text('添加 AI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _modelNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: '自定义模型名称',
              hintText: '例如 gpt-4o-mini',
              filled: true,
              fillColor: AppColors.cardSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'API Key',
              filled: true,
              fillColor: AppColors.cardSoft,
              suffixIcon: IconButton(
                tooltip: _obscureApiKey ? '显示 Key' : '隐藏 Key',
                onPressed: () {
                  setState(() => _obscureApiKey = !_obscureApiKey);
                },
                icon: Icon(
                  _obscureApiKey
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: canSave ? _save : null,
          child: const Text('完成'),
        ),
      ],
    );
  }

  void _save() {
    Navigator.of(context).pop(
      _AiProfileDraft(
        modelName: _modelNameController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
      ),
    );
  }

  void _onTextChanged() {
    setState(() {});
  }
}

class _AiProfileDraft {
  const _AiProfileDraft({required this.modelName, required this.apiKey});

  final String modelName;
  final String apiKey;
}
