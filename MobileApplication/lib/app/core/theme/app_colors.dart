// 文件作用：集中定义从 Kotlin/Compose 原项目迁移过来的颜色，避免页面里散落魔法色值。

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color pageBackground = Color(0xFFF3F2EF);
  static const Color ink = Color(0xFF1F2937);
  static const Color muted = Color(0xFF9CA3AF);
  static const Color orange = Color(0xFFE66A32);
  static const Color lime = Color(0xFFBDEB4F);
  static const Color danger = Color(0xFFEF4444);
  static const Color robotDark = Color(0xFF111827);
  static const Color heroBlack = Color(0xFF151515);
  static const Color heroDeepBlack = Color(0xFF050505);
  static const Color robotScreen = Color(0xFF07111F);
  static const Color robotEye = Color(0xFF5AD7FF);
  static const Color cardSoft = Color(0xFFF7F7F4);
}
