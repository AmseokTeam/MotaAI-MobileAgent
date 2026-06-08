// 文件作用：设置列表项左侧的统一图标容器。

import 'package:flutter/material.dart';

class SettingIcon extends StatelessWidget {
  const SettingIcon({
    required this.icon,
    required this.color,
    super.key,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(17),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 23),
    );
  }
}
