import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milo_ai/app/shared/models/companion_connect_state.dart';
import 'package:milo_ai/app/pages/set/models/robot_settings.dart';
import 'package:milo_ai/app/pages/set/models/robot_settings_content.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_header.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_row.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_section.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_switch_row.dart';
import 'package:milo_ai/app/pages/set/widgets/status_pill.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';
import 'package:milo_ai/app/shared/widgets/menu/app_menu_models.dart';
import 'package:milo_ai/app/shared/widgets/menu/privacy_menu_panel.dart';
import 'package:milo_ai/app/shared/widgets/menu/profile_menu_panel.dart';

class RobotSettingsPage extends StatelessWidget {
  const RobotSettingsPage({
    required this.connectState,
    required this.settings,
    required this.profile,
    required this.onSettingsChanged,
    required this.onProfileChanged,
    super.key,
  });

  final CompanionConnectState connectState;
  final RobotSettings settings;
  final MenuProfileState profile;
  final ValueChanged<RobotSettings> onSettingsChanged;
  final ValueChanged<MenuProfileState> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 144),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsHeader(
                profile: profile,
                onAvatarTap: () => _showProfileEditor(context),
              ),
              const SizedBox(height: 24),
              _ProfileHero(
                profile: profile,
                onAvatarTap: () => _showProfileEditor(context),
              ),
              const SizedBox(height: 18),
              SettingsSection(
                title: '个人主页',
                children: [
                  SettingsRow(
                    icon: Icons.person_rounded,
                    title: profile.nickname,
                    subtitle: '点击上方头像可更换相册图片、默认头像和昵称',
                    accentColor: AppColors.aqua,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SettingsSection(
                title: '体验设置',
                children: [
                  SettingsSwitchRow(
                    icon: Icons.vibration_rounded,
                    title: '触感反馈',
                    subtitle: '点击导航和关键控制时提供轻微震动',
                    value: settings.hapticFeedback,
                    onChanged: _setHapticFeedback,
                  ),
                  SettingsSwitchRow(
                    icon: Icons.auto_awesome_rounded,
                    title: '表情动画',
                    subtitle: '让机器人表情切换更柔和',
                    value: settings.faceAnimation,
                    onChanged: _setFaceAnimation,
                  ),
                  SettingsSwitchRow(
                    icon: Icons.bluetooth_audio_rounded,
                    title: '记住连接偏好',
                    subtitle: '后续接入真实蓝牙后优先恢复最近设备',
                    value: settings.autoReconnect,
                    onChanged: _setAutoReconnect,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SettingsSection(
                title: '隐私与关于',
                children: [
                  SettingsRow(
                    icon: Icons.privacy_tip_rounded,
                    title: '隐私政策',
                    subtitle: '查看蓝牙、相册和本地资料的使用说明',
                    accentColor: AppColors.ink,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: '关于 Milo-AI',
                    subtitle: '当前状态：${statusText(connectState)}，Flutter 移动端版本',
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

  void _showProfileEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          4,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 28,
        ),
        child: _ProfileEditSheet(
          profile: profile,
          onProfileChanged: onProfileChanged,
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

  void _showPrivacyDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: PrivacyMenuPanel(),
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
          'Milo-AI 是一个陪伴机器人控制台。当前 Flutter 版本支持机器人主页、蓝牙扫描、状态面板、移动控制、表情切换、头像本地保存和隐私设置。',
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.onAvatarTap,
  });

  final MenuProfileState profile;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(34),
      elevation: 12,
      shadowColor: AppColors.ink.withValues(alpha: 0.18),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF202B3A), Color(0xFF111827)],
          ),
        ),
        child: Row(
          children: [
            _EditableAvatar(profile: profile, size: 78, onTap: onAvatarTap),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                profile.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.profile,
    required this.size,
    required this.onTap,
  });

  final MenuProfileState profile;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AvatarPreview(
              avatarEmoji: profile.avatarEmoji,
              avatarImageBytes: profile.avatarImageBytes,
              size: size,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.ink,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.profile,
    required this.onProfileChanged,
  });

  final MenuProfileState profile;
  final ValueChanged<MenuProfileState> onProfileChanged;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  static const List<String> _avatarChoices = [
    '🤖',
    '😊',
    '😎',
    '🚀',
    '⭐',
    '🧠',
  ];

  late MenuProfileState _profile;
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nicknameController = TextEditingController(text: _profile.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarFromGallery() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 88,
    );
    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    _changeProfile(_profile.copyWith(avatarImageBytes: bytes));
  }

  void _selectEmojiAvatar(String emoji) {
    _changeProfile(
      _profile.copyWith(avatarEmoji: emoji, clearAvatarImage: true),
    );
  }

  void _changeProfile(MenuProfileState profile) {
    setState(() => _profile = profile);
    widget.onProfileChanged(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '编辑个人主页',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            AvatarPreview(
              avatarEmoji: _profile.avatarEmoji,
              avatarImageBytes: _profile.avatarImageBytes,
              size: 72,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _profile.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _AvatarChoiceButton(
              selected: _profile.avatarImageBytes != null,
              onTap: _pickAvatarFromGallery,
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.ink,
                size: 30,
              ),
            ),
            ..._avatarChoices.map(
              (emoji) => _AvatarChoiceButton(
                selected: _profile.avatarImageBytes == null &&
                    _profile.avatarEmoji == emoji,
                onTap: () => _selectEmojiAvatar(emoji),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _nicknameController,
          onChanged: (value) {
            _changeProfile(_profile.copyWith(nickname: value));
          },
          decoration: InputDecoration(
            labelText: '昵称',
            filled: true,
            fillColor: AppColors.cardSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarChoiceButton extends StatelessWidget {
  const _AvatarChoiceButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.lime : AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: 58, height: 58, child: Center(child: child)),
      ),
    );
  }
}
