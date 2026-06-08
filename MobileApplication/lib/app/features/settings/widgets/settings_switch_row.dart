// 文件作用：设置页布尔偏好的开关行。

import 'package:flutter/material.dart';
import 'package:milo_ai/app/features/settings/widgets/setting_icon.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
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
          SettingIcon(icon: icon, color: AppColors.aqua),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
