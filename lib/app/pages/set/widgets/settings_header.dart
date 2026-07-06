import 'package:flutter/material.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
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
          '隐私、协议与应用信息',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
