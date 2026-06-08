// 文件作用：设置页里的短状态标签。

import 'package:flutter/material.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.text, super.key});

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
