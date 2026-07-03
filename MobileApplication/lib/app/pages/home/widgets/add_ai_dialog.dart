// 文件作用：提供新增 AI 配置的弹窗和表单草稿模型。

import 'package:flutter/material.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../../../core/pc_bridge/pc_bridge_controller.dart';
import '../../../shared/theme/app_colors.dart';

class AddAiDialog extends StatefulWidget {
  const AddAiDialog({required this.bridgeController, super.key});

  final PcBridgeController bridgeController;

  @override
  State<AddAiDialog> createState() => _AddAiDialogState();
}

class _AddAiDialogState extends State<AddAiDialog> {
  late final TextEditingController _modelNameController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _bridgeHostController;
  late final TextEditingController _bridgePortController;
  late final TextEditingController _bridgeTokenController;
  MotaLlmProviderPreset _provider = MotaLlmProviderPreset.defaultPreset;
  _AddAiMode _mode = _AddAiMode.api;
  bool _obscureApiKey = true;
  bool _connectingBridge = false;

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
    final bridgeSettings = widget.bridgeController.settings;
    _bridgeHostController = TextEditingController(text: bridgeSettings.host)
      ..addListener(_onTextChanged);
    _bridgePortController =
        TextEditingController(text: bridgeSettings.port.toString())
          ..addListener(_onTextChanged);
    _bridgeTokenController = TextEditingController(text: bridgeSettings.token)
      ..addListener(_onTextChanged);
    _loadBridgeSettings();
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
    _bridgeHostController
      ..removeListener(_onTextChanged)
      ..dispose();
    _bridgePortController
      ..removeListener(_onTextChanged)
      ..dispose();
    _bridgeTokenController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _baseUrlController.text.trim().isNotEmpty &&
        _modelNameController.text.trim().isNotEmpty &&
        _apiKeyController.text.trim().isNotEmpty;
    final canConnectBridge = _bridgeHostController.text.trim().isNotEmpty &&
        _bridgePortController.text.trim().isNotEmpty &&
        _bridgeTokenController.text.trim().isNotEmpty &&
        !_connectingBridge;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: const Text('添加 AI'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AddAiModePicker(
              mode: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(height: 14),
            if (_mode == _AddAiMode.api)
              _ApiConfigFields(
                provider: _provider,
                modelNameController: _modelNameController,
                baseUrlController: _baseUrlController,
                apiKeyController: _apiKeyController,
                obscureApiKey: _obscureApiKey,
                onProviderChanged: _changeProvider,
                onToggleApiKeyVisibility: () {
                  setState(() => _obscureApiKey = !_obscureApiKey);
                },
              )
            else
              _BridgeConfigFields(
                hostController: _bridgeHostController,
                portController: _bridgePortController,
                tokenController: _bridgeTokenController,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        if (_mode == _AddAiMode.api)
          FilledButton(
            onPressed: canSave ? _saveApi : null,
            child: const Text('完成'),
          )
        else
          FilledButton.icon(
            onPressed: canConnectBridge ? _connectBridge : null,
            icon: _connectingBridge
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(_connectingBridge ? '连接中' : '连接'),
          ),
      ],
    );
  }

  void _changeProvider(MotaLlmProviderPreset provider) {
    setState(() {
      _provider = provider;
      _baseUrlController.text = provider.baseUrl;
      _modelNameController.text = provider.defaultModelName;
    });
  }

  Future<void> _loadBridgeSettings() async {
    await widget.bridgeController.loadSettings();
    if (!mounted) {
      return;
    }

    final settings = widget.bridgeController.settings;
    _bridgeHostController.text = settings.host;
    _bridgePortController.text = settings.port.toString();
    _bridgeTokenController.text = settings.token;
  }

  void _saveApi() {
    Navigator.of(context).pop(
      AiProfileDraft.api(
        provider: _provider,
        providerName: _provider.name,
        baseUrl: _baseUrlController.text.trim(),
        modelName: _modelNameController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
      ),
    );
  }

  Future<void> _connectBridge() async {
    setState(() => _connectingBridge = true);
    final currentSettings = widget.bridgeController.settings;
    await widget.bridgeController.saveSettings(
      currentSettings.copyWith(
        host: _bridgeHostController.text.trim(),
        port: int.tryParse(_bridgePortController.text.trim()) ?? 8765,
        token: _bridgeTokenController.text.trim(),
      ),
    );
    final connected = await widget.bridgeController.connect();
    if (!mounted) {
      return;
    }

    setState(() => _connectingBridge = false);
    if (!connected) {
      await _showBridgeError(
        widget.bridgeController.errorText ?? '个人电脑 AI Agent 连接失败',
      );
      return;
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(const AiProfileDraft.pcBridge());
  }

  Future<void> _showBridgeError(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('连接失败'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  void _onTextChanged() {
    setState(() {});
  }
}

enum _AddAiMode { api, pcBridge }

class _AddAiModePicker extends StatelessWidget {
  const _AddAiModePicker({
    required this.mode,
    required this.onChanged,
  });

  final _AddAiMode mode;
  final ValueChanged<_AddAiMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AddAiModeTile(
          selected: mode == _AddAiMode.api,
          icon: Icons.auto_awesome_rounded,
          title: '添加聊天 AI API',
          subtitle: '填写接口地址、模型名称和 API Key',
          onTap: () => onChanged(_AddAiMode.api),
        ),
        const SizedBox(height: 8),
        _AddAiModeTile(
          selected: mode == _AddAiMode.pcBridge,
          icon: Icons.computer_rounded,
          title: '连接个人电脑 AI Agent',
          subtitle: '连接电脑上的 MotaLink Agent',
          onTap: () => onChanged(_AddAiMode.pcBridge),
        ),
      ],
    );
  }
}

class _AddAiModeTile extends StatelessWidget {
  const _AddAiModeTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.coralSoft : AppColors.cardSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.orange.withValues(alpha: 0.38)
                : AppColors.muted.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.orange : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiConfigFields extends StatelessWidget {
  const _ApiConfigFields({
    required this.provider,
    required this.modelNameController,
    required this.baseUrlController,
    required this.apiKeyController,
    required this.obscureApiKey,
    required this.onProviderChanged,
    required this.onToggleApiKeyVisibility,
  });

  final MotaLlmProviderPreset provider;
  final TextEditingController modelNameController;
  final TextEditingController baseUrlController;
  final TextEditingController apiKeyController;
  final bool obscureApiKey;
  final ValueChanged<MotaLlmProviderPreset> onProviderChanged;
  final VoidCallback onToggleApiKeyVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<MotaLlmProviderPreset>(
          initialValue: provider,
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
            if (provider != null) {
              onProviderChanged(provider);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: baseUrlController,
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
          controller: modelNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '模型名称',
            hintText: '例如 ${provider.defaultModelName}',
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
          controller: apiKeyController,
          obscureText: obscureApiKey,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'API Key',
            filled: true,
            fillColor: AppColors.cardSoft,
            suffixIcon: IconButton(
              tooltip: obscureApiKey ? '显示 Key' : '隐藏 Key',
              onPressed: onToggleApiKeyVisibility,
              icon: Icon(
                obscureApiKey
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
    );
  }
}

class _BridgeConfigFields extends StatelessWidget {
  const _BridgeConfigFields({
    required this.hostController,
    required this.portController,
    required this.tokenController,
  });

  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController tokenController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: hostController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '电脑地址',
            hintText: '192.168.1.23',
            filled: true,
            fillColor: AppColors.cardSoft,
            prefixIcon: const Icon(Icons.computer_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: portController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: '端口',
            hintText: '8765',
            filled: true,
            fillColor: AppColors.cardSoft,
            prefixIcon: const Icon(Icons.settings_ethernet_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: tokenController,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: '连接 Token',
            hintText: 'MotaLink Agent token',
            filled: true,
            fillColor: AppColors.cardSoft,
            prefixIcon: const Icon(Icons.key_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class AiProfileDraft {
  AiProfileDraft.api({
    required MotaLlmProviderPreset provider,
    required this.providerName,
    required this.baseUrl,
    required this.modelName,
    required this.apiKey,
  })  : kind = MotaLlmProfileKind.api,
        providerId = provider.id;

  const AiProfileDraft.pcBridge()
      : kind = MotaLlmProfileKind.pcBridge,
        providerId = MotaLlmSettingsStore.pcBridgeProviderId,
        providerName = MotaLlmSettingsStore.pcBridgeProviderName,
        baseUrl = '',
        modelName = MotaLlmSettingsStore.pcBridgeModelName,
        apiKey = '';

  final MotaLlmProfileKind kind;
  final String providerId;
  final String providerName;
  final String baseUrl;
  final String modelName;
  final String apiKey;
}
