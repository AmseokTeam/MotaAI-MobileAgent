import 'package:flutter/material.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';
import 'package:milo_ai/app/shared/widgets/menu/app_menu_models.dart';
import 'package:milo_ai/app/shared/widgets/menu/profile_menu_panel.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    required this.profile,
    required this.onAvatarTap,
    super.key,
  });

  final MenuProfileState profile;
  final VoidCallback onAvatarTap;

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
                '个人主页、体验与隐私设置',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AvatarPreview(
                avatarEmoji: profile.avatarEmoji,
                avatarImageBytes: profile.avatarImageBytes,
                size: 54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
