import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';

class CreativeWorkshopPage extends StatelessWidget {
  const CreativeWorkshopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '创意工坊',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 5,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 132,
                    child: Center(
                      child: Text(
                        '暂无插件',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
