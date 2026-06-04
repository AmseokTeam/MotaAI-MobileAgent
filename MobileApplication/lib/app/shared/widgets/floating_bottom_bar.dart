// 文件作用：复刻原 Kotlin 项目的底部浮动白色圆角导航栏，集中处理导航入口和触感反馈。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../router/app_router.dart';

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({
    required this.currentTab,
    required this.onTabChange,
    super.key,
  });

  final RobotTab currentTab;
  final ValueChanged<RobotTab> onTabChange;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Material(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          elevation: 18,
          shadowColor: Colors.black.withOpacity(0.18),
          child: SizedBox(
            height: 74,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: RobotTab.values.map((tab) {
                return BottomTabItem(
                  tab: tab,
                  selected: tab == currentTab,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTabChange(tab);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomTabItem extends StatelessWidget {
  const BottomTabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final RobotTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tab.icon, style: const TextStyle(fontSize: 20)),
              Text(
                tab.label,
                style: TextStyle(
                  color: selected ? AppColors.orange : AppColors.muted,
                  fontSize: 11,
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
