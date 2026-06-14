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
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.92),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aqua.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.aquaSoft,
                ),
                child: Center(
                  child: AvatarPreview(
                    avatarEmoji: profile.avatarEmoji,
                    avatarImageBytes: profile.avatarImageBytes,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
