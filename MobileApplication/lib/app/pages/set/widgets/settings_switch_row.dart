import 'package:flutter/material.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_row.dart';
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
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accentColor: AppColors.aqua,
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.ink,
        activeTrackColor: AppColors.lime,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFE5E7EB),
        onChanged: onChanged,
      ),
    );
  }
}
