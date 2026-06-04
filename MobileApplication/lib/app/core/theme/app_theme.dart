// 文件作用：定义 Flutter 全局主题，使 Dart 版在字体、背景、卡片和按钮上贴近原 Compose 项目。

import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.pageBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
      background: AppColors.pageBackground,
      surface: Colors.white,
    ),
    fontFamily: null,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink),
      titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.ink),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.muted),
    ),
  );
}
