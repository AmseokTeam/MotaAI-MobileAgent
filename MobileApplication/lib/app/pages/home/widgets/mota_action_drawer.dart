// 文件作用：展示 Mota 对话输入框左侧加号打开的工具入口。

import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

class MotaActionDrawer extends StatelessWidget {
  const MotaActionDrawer({
    required this.onOpenAi,
    required this.onOpenBridge,
    super.key,
  });

  final VoidCallback onOpenAi;
  final VoidCallback onOpenBridge;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mota 工具',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _MotaActionTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI 模型',
                  subtitle: '选择或添加本地 API Key',
                  onTap: () {
                    Navigator.of(context).pop();
                    onOpenAi();
                  },
                ),
                const SizedBox(height: 8),
                _MotaActionTile(
                  icon: Icons.computer_rounded,
                  title: 'PC Bridge',
                  subtitle: '连接 MotaLink Agent',
                  onTap: () {
                    Navigator.of(context).pop();
                    onOpenBridge();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MotaActionTile extends StatelessWidget {
  const _MotaActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.muted.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.coralSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.orange, size: 21),
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
