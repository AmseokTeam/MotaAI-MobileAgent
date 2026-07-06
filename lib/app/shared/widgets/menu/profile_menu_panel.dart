import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';
import 'app_menu_models.dart';

class ProfileMenuPanel extends StatefulWidget {
  const ProfileMenuPanel({
    required this.profile,
    required this.onProfileChange,
    super.key,
  });

  final MenuProfileState profile;
  final ValueChanged<MenuProfileState> onProfileChange;

  @override
  State<ProfileMenuPanel> createState() => _ProfileMenuPanelState();
}

class _ProfileMenuPanelState extends State<ProfileMenuPanel> {
  static const List<String> _avatarChoices = [
    '🤖',
    '😊',
    '😎',
    '🚀',
    '⭐',
    '🧠'
  ];

  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.profile.nickname);
  }

  @override
  void didUpdateWidget(covariant ProfileMenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.nickname != widget.profile.nickname &&
        _nicknameController.text != widget.profile.nickname) {
      _nicknameController.text = widget.profile.nickname;
    }
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
    widget.onProfileChange(
      widget.profile.copyWith(avatarImageBytes: bytes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileSummary(profile: widget.profile),
        const SizedBox(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '更换头像',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _GalleryAvatarButton(
              selected: widget.profile.avatarImageBytes != null,
              onTap: _pickAvatarFromGallery,
            ),
            ..._avatarChoices.map(
              (avatar) => _EmojiAvatarButton(
                emoji: avatar,
                selected: widget.profile.avatarImageBytes == null &&
                    widget.profile.avatarEmoji == avatar,
                onTap: () {
                  widget.onProfileChange(
                    widget.profile.copyWith(
                      avatarEmoji: avatar,
                      clearAvatarImage: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _nicknameController,
          onChanged: (value) {
            widget.onProfileChange(widget.profile.copyWith(nickname: value));
          },
          decoration: const InputDecoration(
            labelText: '昵称',
            border: UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile});

  final MenuProfileState profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          AvatarPreview(
            avatarEmoji: profile.avatarEmoji,
            avatarImageBytes: profile.avatarImageBytes,
            size: 72,
          ),
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
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '机器人陪伴控制台',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarPreview extends StatelessWidget {
  const AvatarPreview({
    required this.avatarEmoji,
    required this.avatarImageBytes,
    required this.size,
    super.key,
  });

  final String avatarEmoji;
  final Uint8List? avatarImageBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageBytes = avatarImageBytes;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.lime,
        shape: BoxShape.circle,
      ),
      child: imageBytes == null
          ? Center(
              child: Text(
                avatarEmoji,
                style: TextStyle(fontSize: size * 0.45),
              ),
            )
          : Image.memory(imageBytes, fit: BoxFit.cover),
    );
  }
}

class _GalleryAvatarButton extends StatelessWidget {
  const _GalleryAvatarButton({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AvatarShell(
      selected: selected,
      onTap: onTap,
      child: Icon(
        Icons.add_rounded,
        color: AppColors.ink,
        size: selected ? 30 : 28,
      ),
    );
  }
}

class _EmojiAvatarButton extends StatelessWidget {
  const _EmojiAvatarButton({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AvatarShell(
      selected: selected,
      onTap: onTap,
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}

class _AvatarShell extends StatelessWidget {
  const _AvatarShell({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.04 : 1,
      child: Material(
        color: selected ? AppColors.lime : const Color(0xFFF3F4F0),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 60,
            height: 54,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
