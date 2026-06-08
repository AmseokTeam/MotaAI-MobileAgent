// 文件作用：组装机器人设置页，连接具体设置项与应用级状态。

import 'package:flutter/material.dart';
import 'package:milo_ai/app/features/bluetooth/models/companion_connect_state.dart';
import 'package:milo_ai/app/features/settings/models/robot_settings.dart';
import 'package:milo_ai/app/features/settings/models/robot_settings_content.dart';
import 'package:milo_ai/app/features/settings/widgets/connection_hero.dart';
import 'package:milo_ai/app/features/settings/widgets/settings_header.dart';
import 'package:milo_ai/app/features/settings/widgets/settings_row.dart';
import 'package:milo_ai/app/features/settings/widgets/settings_section.dart';
import 'package:milo_ai/app/features/settings/widgets/settings_switch_row.dart';
import 'package:milo_ai/app/features/settings/widgets/status_pill.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';

class RobotSettingsPage extends StatelessWidget {
  const RobotSettingsPage({
    required this.connectState,
    required this.settings,
    required this.onSettingsChanged,
    required this.onScanTap,
    required this.onConnectTap,
    required this.onDisconnectTap,
    super.key,
  });

  final CompanionConnectState connectState;
  final RobotSettings settings;
  final ValueChanged<RobotSettings> onSettingsChanged;
  final VoidCallback onScanTap;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 118),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeader(),
              const SizedBox(height: 24),
              ConnectionHero(
                connectState: connectState,
                onScanTap: onScanTap,
                onConnectTap: onConnectTap,
                onDisconnectTap: onDisconnectTap,
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: '机器人连接',
                children: [
                  SettingsRow(
                    icon: Icons.radar_rounded,
                    title: '扫描附近机器人',
                    subtitle: '打开蓝牙扫描窗口，选择可连接设备',
                    accentColor: AppColors.aqua,
                    onTap: onScanTap,
                  ),
                  SettingsRow(
                    icon: Icons.link_rounded,
                    title: '快速连接 ${RobotSettingsContent.defaultRobotName}',
                    subtitle: '用于调试默认机器人连接状态',
                    accentColor: AppColors.lime,
                    trailing: const StatusPill(text: '连接'),
                    onTap: onConnectTap,
                  ),
                  SettingsRow(
                    icon: Icons.link_off_rounded,
                    title: '断开当前连接',
                    subtitle: '清空连接状态并恢复默认表情',
                    accentColor: AppColors.danger,
                    danger: true,
                    onTap: onDisconnectTap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SettingsSection(
                title: '体验偏好',
                children: [
                  SettingsSwitchRow(
                    icon: Icons.bluetooth_audio_rounded,
                    title: '自动重连',
                    subtitle: '在当前会话中优先恢复最近机器人',
                    value: settings.autoReconnect,
                    onChanged: _setAutoReconnect,
                  ),
                  SettingsSwitchRow(
                    icon: Icons.vibration_rounded,
                    title: '触感反馈',
                    subtitle: '记录导航和重要按钮的触感反馈偏好',
                    value: settings.hapticFeedback,
                    onChanged: _setHapticFeedback,
                  ),
                  SettingsSwitchRow(
                    icon: Icons.auto_awesome_rounded,
                    title: '表情动画',
                    subtitle: '记录机器人表情过渡动画偏好',
                    value: settings.faceAnimation,
                    onChanged: _setFaceAnimation,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SettingsSection(
                title: '应用与隐私',
                children: [
                  SettingsRow(
                    icon: Icons.photo_library_rounded,
                    title: '个人头像',
                    subtitle: '在主页菜单中可从相册更换头像',
                    accentColor: AppColors.orange,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showToast(
                      context,
                      '请回到主页，打开右上角菜单更换头像',
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.privacy_tip_rounded,
                    title: '隐私政策',
                    subtitle: '查看蓝牙、相册和本地设置的使用说明',
                    accentColor: AppColors.ink,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: '关于 Milo-AI',
                    subtitle: 'Flutter 版本，当前用于机器人陪伴控制台',
                    accentColor: AppColors.aqua,
                    trailing: const StatusPill(
                      text: RobotSettingsContent.appVersion,
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setAutoReconnect(bool value) {
    onSettingsChanged(settings.copyWith(autoReconnect: value));
  }

  void _setHapticFeedback(bool value) {
    onSettingsChanged(settings.copyWith(hapticFeedback: value));
  }

  void _setFaceAnimation(bool value) {
    onSettingsChanged(settings.copyWith(faceAnimation: value));
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('隐私政策'),
        content: const Text(
          '当前应用仅在本地模拟机器人控制流程。蓝牙扫描用于发现附近设备，相册权限仅用于选择个人头像，触感反馈用于改善操作体验。',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('关于 Milo-AI'),
        content: const Text(
          'Milo-AI 是一个机器人陪伴控制台。当前版本已迁移为 Flutter 项目，支持主页表情、蓝牙扫描、移动控制、新手文档和应用菜单。',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
