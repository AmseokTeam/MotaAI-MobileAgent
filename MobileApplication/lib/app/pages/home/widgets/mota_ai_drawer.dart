// 文件作用：展示可选 AI 列表，并负责选择或新增本地保存的 AI 配置。

import 'package:flutter/material.dart';

import '../../../core/llm/mota_llm_settings_store.dart';
import '../../../core/pc_bridge/pc_bridge_controller.dart';
import '../../../shared/theme/app_colors.dart';
import 'add_ai_dialog.dart';

class MotaAiDrawer extends StatefulWidget {
  const MotaAiDrawer({
    required this.settingsStore,
    required this.bridgeController,
    required this.onPcConnectionFailed,
    super.key,
  });

  final MotaLlmSettingsStore settingsStore;
  final PcBridgeController bridgeController;
  final VoidCallback onPcConnectionFailed;

  @override
  State<MotaAiDrawer> createState() => _MotaAiDrawerState();
}

class _MotaAiDrawerState extends State<MotaAiDrawer> {
  List<MotaLlmProfile> _profiles = <MotaLlmProfile>[];
  String? _selectedProfileId;
  String? _connectingProfileId;
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
                        final connecting = profile.id == _connectingProfileId;
                        return _AiProfileTile(
                          profile: profile,
                          selected: selected,
                          connecting: connecting,
                          bridgeConnected: widget.bridgeController.isConnected,
                          onTap: _connectingProfileId == null
                              ? () => _selectProfile(profile)
                              : null,
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
    setState(() => _connectingProfileId = profile.id);

    try {
      if (profile.isPcBridge && !widget.bridgeController.isConnected) {
        final connected = await widget.bridgeController.connect();
        if (!mounted) {
          return;
        }
        if (!connected) {
          widget.onPcConnectionFailed();
          return;
        }
      }

      await widget.settingsStore.selectProfile(profile.id);
      if (!mounted) {
        return;
      }

      setState(() => _selectedProfileId = profile.id);
    } finally {
      if (mounted) {
        setState(() => _connectingProfileId = null);
      }
    }
  }

  Future<void> _showAddAiDialog() async {
    final draft = await showDialog<AiProfileDraft>(
      context: context,
      builder: (context) => AddAiDialog(
        bridgeController: widget.bridgeController,
      ),
    );
    if (draft == null) {
      return;
    }

    final profile = switch (draft.kind) {
      MotaLlmProfileKind.api => await widget.settingsStore.addProfile(
          providerId: draft.providerId,
          providerName: draft.providerName,
          baseUrl: draft.baseUrl,
          modelName: draft.modelName,
          apiKey: draft.apiKey,
        ),
      MotaLlmProfileKind.pcBridge =>
        await widget.settingsStore.addPcBridgeProfile(),
    };
    if (!mounted) {
      return;
    }

    final profiles = await widget.settingsStore.readProfiles();
    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = profiles;
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
    required this.connecting,
    required this.bridgeConnected,
    required this.onTap,
  });

  final MotaLlmProfile profile;
  final bool selected;
  final bool connecting;
  final bool bridgeConnected;
  final VoidCallback? onTap;

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
                profile.isPcBridge
                    ? Icons.computer_rounded
                    : Icons.auto_awesome_rounded,
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
                    profile.isPcBridge
                        ? profile.providerName
                        : '${profile.providerName} · ${profile.modelName}',
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
                    _subtitle,
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
            if (connecting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.orange,
                ),
              )
            else if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.lime),
          ],
        ),
      ),
    );
  }

  String get _subtitle {
    if (!profile.isPcBridge) {
      return profile.maskedApiKey;
    }
    if (connecting) {
      return '正在连接电脑';
    }
    if (bridgeConnected) {
      return '已连接，可作为聊天后端';
    }
    return '选择后尝试连接电脑';
  }
}
