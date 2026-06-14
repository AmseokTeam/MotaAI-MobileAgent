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

  Future<void> _showProfileEditor(BuildContext context) async {
    final updatedProfile = await showModalBottomSheet<MenuProfileState>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _ProfileEditSheet(profile: profile),
      ),
    );

    if (updatedProfile == null || !context.mounted) {
      return;
    }

    onProfileChanged(updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('个人主页已更新'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(38),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF243247), Color(0xFF111A2A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            _EditableAvatar(profile: profile, size: 62, onTap: onAvatarTap),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.bio.isEmpty ? '我的机器人伙伴' : profile.bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.64),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.lime.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '点击编辑头像与昵称',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
            Container(
              width: size + 18,
              height: size + 18,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.98),
                    AppColors.aquaSoft,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aqua.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AvatarPreview(
                avatarEmoji: profile.avatarEmoji,
                avatarImageBytes: profile.avatarImageBytes,
                size: size,
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
  });

  final MenuProfileState profile;

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

  static const List<String> _preferenceChoices = [
    '安静陪伴',
    '活泼互动',
    '学习助手',
    '情绪陪伴',
    '桌面机器人',
  ];

  static const List<String> _extraAvatarChoices = [
    '🐱',
    '🐶',
    '🎮',
    '💡',
  ];

  late MenuProfileState _profile;
  late final TextEditingController _nicknameController;
  late final TextEditingController _bioController;

  List<String> get _allAvatarChoices => [
        ..._avatarChoices,
        ..._extraAvatarChoices,
      ];

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nicknameController = TextEditingController(text: _profile.nickname);
    _bioController = TextEditingController(text: _profile.bio);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
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
  }

  void _togglePreference(String tag) {
    final tags = [..._profile.preferenceTags];
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }

    _changeProfile(_profile.copyWith(preferenceTags: tags));
  }

  void _saveProfile() {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('昵称不能为空'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    final bio = _bioController.text.trim();
    Navigator.of(context).pop(
      _profile.copyWith(
        nickname: nickname,
        bio: bio.isEmpty ? '我的机器人伙伴' : bio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nicknameLength = _nicknameController.text.characters.length;
    final bioLength = _bioController.text.characters.length;
    final canSave = _nicknameController.text.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.muted.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '编辑个人主页',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '自定义你的机器人伙伴资料',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _ProfileEditSummary(profile: _profile),
            const SizedBox(height: 20),
            _SectionLabel(
              title: '头像',
              trailing: _profile.avatarImageBytes == null ? '默认头像' : '来自相册',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _AvatarChoiceButton(
                      selected: _profile.avatarImageBytes != null,
                      onTap: _pickAvatarFromGallery,
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.ink,
                        size: 30,
                      ),
                    ),
                  ),
                  ..._allAvatarChoices.map(
                    (emoji) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _AvatarChoiceButton(
                        selected: _profile.avatarImageBytes == null &&
                            _profile.avatarEmoji == emoji,
                        onTap: () => _selectEmojiAvatar(emoji),
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 25)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ModernTextField(
              controller: _nicknameController,
              label: '昵称',
              hint: 'Lin Robot 用户',
              maxLength: 16,
              currentLength: nicknameLength,
              onChanged: (value) {
                _changeProfile(_profile.copyWith(nickname: value));
              },
            ),
            const SizedBox(height: 14),
            _ModernTextField(
              controller: _bioController,
              label: '个性签名 / Bio',
              hint: '我的机器人伙伴',
              maxLength: 30,
              currentLength: bioLength,
              onChanged: (value) {
                _changeProfile(_profile.copyWith(bio: value));
              },
            ),
            const SizedBox(height: 18),
            const _SectionLabel(title: '机器人偏好'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _preferenceChoices.map((tag) {
                final selected = _profile.preferenceTags.contains(tag);
                return _PreferenceChip(
                  label: tag,
                  selected: selected,
                  onTap: () => _togglePreference(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                        color: AppColors.muted.withValues(alpha: 0.25),
                      ),
                      foregroundColor: AppColors.ink,
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canSave ? _saveProfile : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: AppColors.lime,
                      disabledBackgroundColor:
                          AppColors.muted.withValues(alpha: 0.18),
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '保存更改',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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

class _ProfileEditSummary extends StatelessWidget {
  const _ProfileEditSummary({required this.profile});

  final MenuProfileState profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Container(
              key: ValueKey<Object?>(
                profile.avatarImageBytes ?? profile.avatarEmoji,
              ),
              width: 76,
              height: 76,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lime.withValues(alpha: 0.48),
                    AppColors.aquaSoft,
                  ],
                ),
              ),
              child: AvatarPreview(
                avatarEmoji: profile.avatarEmoji,
                avatarImageBytes: profile.avatarImageBytes,
                size: 62,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.bio.isEmpty ? '我的机器人伙伴' : profile.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    this.trailing,
  });

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.maxLength,
    required this.currentLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLength;
  final int currentLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '$currentLength/$maxLength',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: '清空',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.muted.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.lime, width: 2),
        ),
      ),
    );
  }
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? AppColors.lime : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? AppColors.lime
              : AppColors.muted.withValues(alpha: 0.16),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1 : 0.75,
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.add_rounded,
                  size: 16,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
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
        border: Border.all(
          color:
              selected ? AppColors.ink.withValues(alpha: 0.14) : Colors.white,
          width: selected ? 2 : 1,
        ),
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
        child: SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            children: [
              Center(child: child),
              if (selected)
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.ink,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
