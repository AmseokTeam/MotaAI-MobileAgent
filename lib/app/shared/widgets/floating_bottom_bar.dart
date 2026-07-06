import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../router/app_router.dart';
import '../theme/app_colors.dart';

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
      child: SizedBox(
        height: 98,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.10),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.70),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.86),
                          width: 1.2,
                        ),
                      ),
                      child: SizedBox(
                        height: 76,
                        child: Row(
                          children: RobotTab.values.map((tab) {
                            return Expanded(
                              child: BottomTabItem(
                                tab: tab,
                                selected: tab == currentTab,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onTabChange(tab);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
    final activeColor = selected ? AppColors.orange : AppColors.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            splashColor: AppColors.orange.withValues(alpha: 0.08),
            highlightColor: AppColors.orange.withValues(alpha: 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.coralSoft.withValues(alpha: 0.72)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: AnimatedScale(
                scale: selected ? 1.04 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: selected ? 38 : 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.88)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.orange.withValues(alpha: 0.16),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        tab.iconAsset,
                        width: selected ? 23 : 22,
                        height: selected ? 23 : 22,
                        colorFilter: ColorFilter.mode(
                          activeColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: activeColor,
                        fontSize: selected ? 11.5 : 11,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w700,
                        height: 1.1,
                      ),
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: selected ? 16 : 4,
                      height: 3,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
