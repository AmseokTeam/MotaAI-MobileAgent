// 文件作用：复刻右上角菜单按钮和菜单弹层，包含个人主页与隐私政策两个分段页。

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppMenuPanel {
  profile,
  privacy,
}

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (_) => Container(
                  width: 22,
                  height: 3,
                  margin: const EdgeInsets.symmetric(vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppMenuOverlay extends StatefulWidget {
  const AppMenuOverlay({
    required this.visible,
    required this.onDismiss,
    super.key,
  });

  final bool visible;
  final VoidCallback onDismiss;

  @override
  State<AppMenuOverlay> createState() => _AppMenuOverlayState();
}

class _AppMenuOverlayState extends State<AppMenuOverlay> {
  AppMenuPanel _panel = AppMenuPanel.profile;
  String _nickname = 'Lin Robot 用户';
  String _avatar = '🤖';

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.black.withOpacity(0.42)),
          ),
        ),
        Positioned(
          top: 72,
          left: 20,
          right: 20,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            scale: widget.visible ? 1 : 0.86,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              elevation: 20,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuHeader(onDismiss: widget.onDismiss),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _MenuSegment(
                            text: '个人主页',
                            selected: _panel == AppMenuPanel.profile,
                            onTap: () => setState(() => _panel = AppMenuPanel.profile),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MenuSegment(
                            text: '隐私政策',
                            selected: _panel == AppMenuPanel.privacy,
                            onTap: () => setState(() => _panel = AppMenuPanel.privacy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _panel == AppMenuPanel.profile
                          ? _ProfilePanel(
                              key: const ValueKey('profile'),
                              nickname: _nickname,
                              avatar: _avatar,
                              onNicknameChange: (value) => setState(() => _nickname = value),
                              onAvatarChange: (value) => setState(() => _avatar = value),
                            )
                          : const _PrivacyPanel(key: ValueKey('privacy')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('菜单', style: TextStyle(color: AppColors.ink, fontSize: 26, fontWeight: FontWeight.w800)),
              Text('机器人应用设置', style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF3F4F0),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onDismiss,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Text('×', style: TextStyle(color: AppColors.muted, fontSize: 24, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuSegment extends StatelessWidget {
  const _MenuSegment({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.lime : const Color(0xFFF3F4F0),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatefulWidget {
  const _ProfilePanel({
    required this.nickname,
    required this.avatar,
    required this.onNicknameChange,
    required this.onAvatarChange,
    super.key,
  });

  final String nickname;
  final String avatar;
  final ValueChanged<String> onNicknameChange;
  final ValueChanged<String> onAvatarChange;

  @override
  State<_ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<_ProfilePanel> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.nickname);
    _avatarController = TextEditingController(text: widget.avatar);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Text(widget.avatar, style: const TextStyle(fontSize: 42)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.nickname,
                  style: const TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nicknameController,
          onChanged: widget.onNicknameChange,
          decoration: const InputDecoration(labelText: '昵称'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _avatarController,
          onChanged: widget.onAvatarChange,
          decoration: const InputDecoration(labelText: '头像符号'),
        ),
      ],
    );
  }
}

class _PrivacyPanel extends StatelessWidget {
  const _PrivacyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '本地演示版本不会上传机器人控制数据。后续接入真实蓝牙、账号或云服务时，需要在这里补充完整的隐私说明。',
      style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.55),
    );
  }
}
