// 文件作用：复刻原 Compose 的页面标题行，左侧标题说明，右侧圆形机器人入口图标。

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('🤖', style: TextStyle(fontSize: 22)),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
