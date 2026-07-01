// 文件作用：提供新增 AI 配置的弹窗和表单草稿模型。

import 'package:flutter/material.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../../../shared/theme/app_colors.dart';

class AddAiDialog extends StatefulWidget {
  const AddAiDialog({super.key});

  @override
  State<AddAiDialog> createState() => _AddAiDialogState();
}

class _AddAiDialogState extends State<AddAiDialog> {
  late final TextEditingController _modelNameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  MotaLlmProviderPreset _provider = MotaLlmProviderPreset.defaultPreset;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController(
      text: _provider.defaultModelName,
    )..addListener(_onTextChanged);
    _baseUrlController = TextEditingController(
      text: _provider.baseUrl,
    )..addListener(_onTextChanged);
    _apiKeyController = TextEditingController()..addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _modelNameController
      ..removeListener(_onTextChanged)
      ..dispose();
    _baseUrlController
      ..removeListener(_onTextChanged)
      ..dispose();
    _apiKeyController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _baseUrlController.text.trim().isNotEmpty &&
        _modelNameController.text.trim().isNotEmpty &&
        _apiKeyController.text.trim().isNotEmpty;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text('添加 AI'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MotaLlmProviderPreset>(
              initialValue: _provider,
              decoration: InputDecoration(
                labelText: 'API 接口',
                filled: true,
                fillColor: AppColors.cardSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              items: MotaLlmProviderPreset.all.map((provider) {
                return DropdownMenuItem<MotaLlmProviderPreset>(
                  value: provider,
                  child: Text(provider.name),
                );
              }).toList(growable: false),
              onChanged: (provider) {
                if (provider == null) {
                  return;
                }
                setState(() {
                  _provider = provider;
                  _baseUrlController.text = provider.baseUrl;
                  _modelNameController.text = provider.defaultModelName;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '接口地址',
                hintText: 'https://api.example.com/v1',
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
              controller: _modelNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '模型名称',
                hintText: '例如 ${_provider.defaultModelName}',
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
      AiProfileDraft(
        provider: _provider,
        providerName: _provider.name,
        baseUrl: _baseUrlController.text.trim(),
        modelName: _modelNameController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
      ),
    );
  }

  void _onTextChanged() {
    setState(() {});
  }
}

class AiProfileDraft {
  const AiProfileDraft({
    required this.provider,
    required this.providerName,
    required this.baseUrl,
    required this.modelName,
    required this.apiKey,
  });

  final MotaLlmProviderPreset provider;
  final String providerName;
  final String baseUrl;
  final String modelName;
  final String apiKey;
}
