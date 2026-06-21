// 文件作用：提供首页复用的机器人眨眼眼睛动画。

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/companion_bot_mood.dart';

class RobotHeroPreview extends StatefulWidget {
  const RobotHeroPreview({
    required this.mood,
    super.key,
  });

  final CompanionBotMood mood;

  @override
  State<RobotHeroPreview> createState() => _RobotHeroPreviewState();
}

class _RobotHeroPreviewState extends State<RobotHeroPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, child) {
        return CustomPaint(
          painter:
              RobotHeroPreviewPainter(mood: widget.mood, tick: _loop.value),
        );
      },
    );
  }
}

class RobotHeroPreviewPainter extends CustomPainter {
  const RobotHeroPreviewPainter({required this.mood, required this.tick});

  final CompanionBotMood mood;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    final breathe = 0.96 + _easeSin(tick) * 0.08;
    final centerX = size.width * 0.5;
    final faceCenterY = size.height * 0.46;
    final eyeRadius = size.width * 0.075 * breathe;

    final blink = _blinkAmount(tick);
    _drawBlinkingEye(canvas, Offset(centerX - size.width * 0.18, faceCenterY),
        eyeRadius, blink);
    _drawBlinkingEye(canvas, Offset(centerX + size.width * 0.18, faceCenterY),
        eyeRadius, blink);

    for (var index = 0; index < 4; index++) {
      final barHeight = 7.0 + index * 4.5;
      _roundRect(
          canvas,
          Rect.fromLTWH(size.width - 58 + index * 8,
              faceCenterY - eyeRadius * 0.9 - barHeight, 5, barHeight),
          3,
          Colors.white.withValues(alpha: 0.72));
    }
  }

  @override
  bool shouldRepaint(covariant RobotHeroPreviewPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.tick != tick;
  }
}

double _easeSin(double value) {
  return (math.sin(value * math.pi * 2 - math.pi / 2) + 1) / 2;
}

double _blinkAmount(double tick) {
  const blinkDuration = 0.12;
  final phase = (tick + 0.08) % 1.0;
  if (phase > blinkDuration) {
    return 0;
  }
  return math.sin((phase / blinkDuration) * math.pi);
}

void _drawBlinkingEye(
    Canvas canvas, Offset center, double radius, double blinkAmount) {
  final heightScale = 1 - blinkAmount * 0.9;
  final eyeRect = Rect.fromCenter(
    center: center,
    width: radius * 2,
    height: math.max(radius * 0.16, radius * 2 * heightScale),
  );
  canvas.drawOval(eyeRect, Paint()..color = Colors.white);
}

void _roundRect(Canvas canvas, Rect rect, double radius, Color color) {
  canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color);
}
