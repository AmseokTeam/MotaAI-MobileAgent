// 文件作用：提供原 Kotlin 项目中多页面复用的软卡片、活动条、按钮和统计行组件。

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SoftActionCard extends StatelessWidget {
  const SoftActionCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
    this.highlighted = false,
    this.height = 100,
    super.key,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;
  final bool highlighted;
  final double height;

  @override
  Widget build(BuildContext context) {
    final containerColor = highlighted ? AppColors.lime : Colors.white;
    final iconColor = highlighted ? Colors.white.withOpacity(0.88) : const Color(0xFFFFEEE6);
    final subtitleColor = highlighted ? AppColors.ink.withOpacity(0.62) : AppColors.muted;

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(26),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  const ActivityItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    super.key,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.11),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({
    required this.text,
    required this.onTap,
    this.danger = false,
    this.orange = false,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final bool danger;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    final bg = danger ? AppColors.danger : orange ? AppColors.orange : AppColors.ink;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompactActionButton extends StatelessWidget {
  const CompactActionButton({
    required this.text,
    required this.onTap,
    this.highlighted = false,
    this.danger = false,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final bool highlighted;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final bg = danger ? AppColors.danger : highlighted ? AppColors.ink : const Color(0xFFF3F4F0);
    final fg = danger || highlighted ? Colors.white : AppColors.ink;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  const StatRow({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
