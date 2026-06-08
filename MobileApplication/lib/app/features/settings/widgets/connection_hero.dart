// 文件作用：设置页顶部的机器人连接状态卡片。

import 'package:flutter/material.dart';
import 'package:milo_ai/app/features/bluetooth/models/companion_connect_state.dart';
import 'package:milo_ai/app/features/settings/models/robot_settings_content.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';

class ConnectionHero extends StatelessWidget {
  const ConnectionHero({
    required this.connectState,
    required this.onScanTap,
    required this.onConnectTap,
    required this.onDisconnectTap,
    super.key,
  });

  final CompanionConnectState connectState;
  final VoidCallback onScanTap;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    final presentation = _ConnectionPresentation.from(connectState);
    final connected = connectState == CompanionConnectState.connected;

    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(34),
      elevation: 10,
      shadowColor: AppColors.ink.withValues(alpha: 0.22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    presentation.icon,
                    color: connected ? AppColors.lime : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '机器人连接',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        presentation.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _ConnectionBadge(
                    text: presentation.statusText, active: connected),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _HeroButton(
                    text: '扫描',
                    icon: Icons.search_rounded,
                    onTap: onScanTap,
                    highlighted: !connected,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeroButton(
                    text: connected ? '断开' : '连接',
                    icon:
                        connected ? Icons.link_off_rounded : Icons.link_rounded,
                    onTap: connected ? onDisconnectTap : onConnectTap,
                    danger: connected,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionPresentation {
  const _ConnectionPresentation({
    required this.icon,
    required this.subtitle,
    required this.statusText,
  });

  final IconData icon;
  final String subtitle;
  final String statusText;

  factory _ConnectionPresentation.from(CompanionConnectState state) {
    return switch (state) {
      CompanionConnectState.connected => const _ConnectionPresentation(
          icon: Icons.bluetooth_connected_rounded,
          subtitle: '${RobotSettingsContent.defaultRobotName} 已准备好接收指令',
          statusText: '已连接',
        ),
      CompanionConnectState.scanning => const _ConnectionPresentation(
          icon: Icons.radar_rounded,
          subtitle: '正在扫描附近可用设备',
          statusText: '扫描中',
        ),
      CompanionConnectState.disconnected => const _ConnectionPresentation(
          icon: Icons.bluetooth_rounded,
          subtitle: '连接机器人后即可发送控制指令',
          statusText: '未连接',
        ),
    };
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.lime : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? AppColors.ink : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
    this.danger = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final background = danger
        ? AppColors.danger
        : highlighted
            ? AppColors.lime
            : Colors.white.withValues(alpha: 0.14);
    final foreground = highlighted ? AppColors.ink : Colors.white;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
