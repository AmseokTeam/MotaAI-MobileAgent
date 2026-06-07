import 'package:flutter/material.dart';

import '../../../features/bluetooth/models/companion_connect_state.dart';
import '../../../shared/theme/app_colors.dart';

class RobotSettingsPage extends StatefulWidget {
  const RobotSettingsPage({
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
  State<RobotSettingsPage> createState() => _RobotSettingsPageState();
}

class _RobotSettingsPageState extends State<RobotSettingsPage> {
  bool _autoReconnect = true;
  bool _hapticFeedback = true;
  bool _faceAnimation = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 118),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SettingsHeader(),
                  const SizedBox(height: 24),
                  _ConnectionHero(
                    connectState: widget.connectState,
                    onScanTap: widget.onScanTap,
                    onConnectTap: widget.onConnectTap,
                    onDisconnectTap: widget.onDisconnectTap,
                  ),
                  const SizedBox(height: 18),
                  _SettingsSection(
                    title: '机器人连接',
                    children: [
                      _SettingsRow(
                        icon: Icons.radar_rounded,
                        title: '扫描附近机器人',
                        subtitle: '打开蓝牙扫描窗口，选择可连接设备',
                        accentColor: AppColors.aqua,
                        onTap: widget.onScanTap,
                      ),
                      _SettingsRow(
                        icon: Icons.link_rounded,
                        title: '快速连接 LinBot-01',
                        subtitle: '用于调试默认机器人连接状态',
                        accentColor: AppColors.lime,
                        trailing: const _StatusPill(text: '连接'),
                        onTap: widget.onConnectTap,
                      ),
                      _SettingsRow(
                        icon: Icons.link_off_rounded,
                        title: '断开当前连接',
                        subtitle: '清空连接状态并恢复默认表情',
                        accentColor: AppColors.danger,
                        danger: true,
                        onTap: widget.onDisconnectTap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: '体验偏好',
                    children: [
                      _SwitchRow(
                        icon: Icons.bluetooth_audio_rounded,
                        title: '自动重连',
                        subtitle: '下次进入应用时优先恢复上次机器人',
                        value: _autoReconnect,
                        onChanged: (value) =>
                            setState(() => _autoReconnect = value),
                      ),
                      _SwitchRow(
                        icon: Icons.vibration_rounded,
                        title: '触感反馈',
                        subtitle: '导航和重要按钮点击时给出轻微震动',
                        value: _hapticFeedback,
                        onChanged: (value) =>
                            setState(() => _hapticFeedback = value),
                      ),
                      _SwitchRow(
                        icon: Icons.auto_awesome_rounded,
                        title: '表情动画',
                        subtitle: '机器人眼睛和情绪变化保持柔和过渡',
                        value: _faceAnimation,
                        onChanged: (value) =>
                            setState(() => _faceAnimation = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: '应用与隐私',
                    children: [
                      _SettingsRow(
                        icon: Icons.photo_library_rounded,
                        title: '个人头像',
                        subtitle: '在主页菜单中可从相册更换头像',
                        accentColor: AppColors.orange,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showToast(context, '请回到主页，打开右上角菜单更换头像'),
                      ),
                      _SettingsRow(
                        icon: Icons.privacy_tip_rounded,
                        title: '隐私政策',
                        subtitle: '查看蓝牙、相册和本地设置的使用说明',
                        accentColor: AppColors.ink,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showPrivacyDialog(context),
                      ),
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        title: '关于 Milo-AI',
                        subtitle: 'Flutter 版本，当前用于机器人陪伴控制台',
                        accentColor: AppColors.aqua,
                        trailing: const _StatusPill(text: '1.0.0'),
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '连接、体验与隐私设置',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text('🤖', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}

class _ConnectionHero extends StatelessWidget {
  const _ConnectionHero({
    required this.connectState,
    required this.onScanTap,
    required this.onConnectTap,
    required this.onDisconnectTap,
  });

  final CompanionConnectState connectState;
  final VoidCallback onScanTap;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    final connected = connectState == CompanionConnectState.connected;
    final scanning = connectState == CompanionConnectState.scanning;

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
                    connected
                        ? Icons.bluetooth_connected_rounded
                        : scanning
                            ? Icons.radar_rounded
                            : Icons.bluetooth_rounded,
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
                        connected
                            ? 'LinBot-01 已准备好接收指令'
                            : scanning
                                ? '正在扫描附近可用设备'
                                : '连接机器人后即可发送控制指令',
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
                  text: connected
                      ? '已连接'
                      : scanning
                          ? '扫描中'
                          : '未连接',
                  active: connected,
                ),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textColor = danger ? AppColors.danger : AppColors.ink;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            _SettingIcon(icon: icon, color: accentColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          _SettingIcon(icon: icon, color: AppColors.aqua),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.ink,
            activeTrackColor: AppColors.lime,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(17),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
