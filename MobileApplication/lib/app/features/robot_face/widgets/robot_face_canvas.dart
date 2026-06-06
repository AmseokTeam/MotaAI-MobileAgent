// 文件作用：用 Flutter CustomPainter 复刻 Kotlin/Compose 中的机器人脸、首页预览和横屏沉浸眼睛动画。

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/companion_bot_mood.dart';

class CompanionRobotFace extends StatefulWidget {
  const CompanionRobotFace({
    required this.mood,
    this.largeMode = false,
    super.key,
  });

  final CompanionBotMood mood;
  final bool largeMode;

  @override
  State<CompanionRobotFace> createState() => _CompanionRobotFaceState();
}

class _CompanionRobotFaceState extends State<CompanionRobotFace> with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();
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
          painter: CompanionRobotFacePainter(
            mood: widget.mood,
            tick: _loop.value,
            largeMode: widget.largeMode,
          ),
        );
      },
    );
  }
}

class RobotHeroPreview extends StatefulWidget {
  const RobotHeroPreview({
    required this.mood,
    super.key,
  });

  final CompanionBotMood mood;

  @override
  State<RobotHeroPreview> createState() => _RobotHeroPreviewState();
}

class _RobotHeroPreviewState extends State<RobotHeroPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
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
          painter: RobotHeroPreviewPainter(mood: widget.mood, tick: _loop.value),
        );
      },
    );
  }
}

class ImmersiveRobotDisplay extends StatefulWidget {
  const ImmersiveRobotDisplay({
    required this.mood,
    super.key,
  });

  final CompanionBotMood mood;

  @override
  State<ImmersiveRobotDisplay> createState() => _ImmersiveRobotDisplayState();
}

class _ImmersiveRobotDisplayState extends State<ImmersiveRobotDisplay> with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, child) {
              return CustomPaint(
                painter: ImmersiveRobotDisplayPainter(mood: widget.mood, tick: _loop.value),
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 46,
          child: Text(
            immersiveCaption(widget.mood),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Text(
            '轻点屏幕返回',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        Positioned(
          top: 24,
          right: 28,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: widget.mood.moodColor, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class CompanionRobotFacePainter extends CustomPainter {
  const CompanionRobotFacePainter({
    required this.mood,
    required this.tick,
    required this.largeMode,
  });

  final CompanionBotMood mood;
  final double tick;
  final bool largeMode;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final color = mood.moodColor;
    final scale = largeMode ? 1.18 : 1.0;
    final glowPulse = 0.35 + _easeSin(tick) * 0.55;
    final floatOffset = -8 + _easeSin(tick * 2800 / 2200) * 16;
    final eyeOffsetY = switch (mood) {
      CompanionBotMood.sad => 12.0,
      CompanionBotMood.sleepy => 8.0,
      CompanionBotMood.surprised => -8.0,
      _ => 0.0,
    };

    canvas.save();
    canvas.translate(0, floatOffset);

    final faceWidth = w * 0.68 * scale;
    final faceHeight = h * 0.48 * scale;
    final faceLeft = (w - faceWidth) / 2;
    final faceTop = h * (largeMode ? 0.24 : 0.22);
    final center = Offset(w * 0.5, h * 0.48);

    canvas.drawCircle(center, w * 0.40 * scale, Paint()..color = color.withOpacity(0.11 * glowPulse));
    canvas.drawCircle(center, w * 0.50 * scale, Paint()..color = color.withOpacity(0.07 * glowPulse));

    _roundRect(canvas, Rect.fromLTWH(faceLeft, faceTop, faceWidth, faceHeight), 54, AppColors.robotDark);
    _roundRectStroke(canvas, Rect.fromLTWH(faceLeft, faceTop, faceWidth, faceHeight), 54, color.withOpacity(0.48), 9);
    _roundRect(canvas, Rect.fromLTWH(faceLeft + 22, faceTop + 18, faceWidth - 44, 30), 30, Colors.white.withOpacity(0.07));

    _drawAntenna(canvas, centerX: w * 0.5, topY: faceTop, color: color, scale: scale);
    _drawEar(canvas, x: faceLeft - 24, y: faceTop + faceHeight * 0.40, color: color, scale: scale);
    _drawEar(canvas, x: faceLeft + faceWidth + 24, y: faceTop + faceHeight * 0.40, color: color, scale: scale);
    _drawEye(canvas, Offset(w * 0.36, h * 0.43 + eyeOffsetY), scale);
    _drawEye(canvas, Offset(w * 0.64, h * 0.43 + eyeOffsetY), scale);
    _drawBrows(canvas, w, h, color, scale);
    _drawMouth(canvas, w, h, color, scale);
    _drawCheeks(canvas, w, h, color, scale);

    canvas.restore();
  }

  void _drawEye(Canvas canvas, Offset center, double scale) {
    _drawWhiteEye(canvas, center, 28 * scale);
  }

  void _drawBrows(Canvas canvas, double w, double h, Color color, double scale) {
    if (mood == CompanionBotMood.happy || mood == CompanionBotMood.love || mood == CompanionBotMood.surprised) {
      return;
    }

    final tilt = switch (mood) {
      CompanionBotMood.angry => 1.0,
      CompanionBotMood.sad => -0.7,
      _ => 0.0,
    };
    _line(canvas, Offset(w * 0.27, h * 0.32 - 10 * tilt), Offset(w * 0.43, h * 0.32 + 12 * tilt), color, 8 * scale);
    _line(canvas, Offset(w * 0.73, h * 0.32 - 10 * tilt), Offset(w * 0.57, h * 0.32 + 12 * tilt), color, 8 * scale);
  }

  void _drawMouth(Canvas canvas, double w, double h, Color color, double scale) {
    final mouthCenterX = w * 0.5;
    final mouthY = h * 0.62;
    final open = switch (mood) {
      CompanionBotMood.surprised => 1.0,
      CompanionBotMood.sleepy => 0.42,
      CompanionBotMood.love => 0.2,
      _ => 0.0,
    };

    if (open > 0.1) {
      _oval(canvas, Rect.fromLTWH(mouthCenterX - 30 * scale, mouthY - 8 * scale, 60 * scale, 50 * open * scale), color.withOpacity(0.22));
      canvas.drawOval(
        Rect.fromLTWH(mouthCenterX - 18 * scale, mouthY, 36 * scale, 34 * open * scale),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7 * scale,
      );
      return;
    }

    if (mood == CompanionBotMood.sleepy) {
      _line(canvas, Offset(w * 0.43, mouthY), Offset(w * 0.57, mouthY), color, 8 * scale);
      canvas.drawCircle(Offset(w * 0.62, mouthY - 18 * scale), 7 * scale, Paint()..color = color);
      canvas.drawCircle(Offset(w * 0.66, mouthY - 34 * scale), 5 * scale, Paint()..color = color.withOpacity(0.65));
      return;
    }

    final smile = switch (mood) {
      CompanionBotMood.happy => 1.0,
      CompanionBotMood.love => 0.9,
      CompanionBotMood.sad => -1.0,
      CompanionBotMood.angry => -0.35,
      _ => 0.0,
    };

    if (smile.abs() < 0.15) {
      _line(canvas, Offset(w * 0.41, mouthY), Offset(w * 0.59, mouthY), color, 9 * scale);
    } else {
      final arcTop = smile >= 0 ? mouthY - 36 * scale : mouthY + 10 * scale;
      final startAngle = smile >= 0 ? 20.0 : 200.0;
      canvas.drawArc(
        Rect.fromLTWH(w * 0.36, arcTop, w * 0.28, h * 0.19),
        _deg(startAngle),
        _deg(140),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10 * scale
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCheeks(Canvas canvas, double w, double h, Color color, double scale) {
    if (mood != CompanionBotMood.happy && mood != CompanionBotMood.love) {
      return;
    }

    canvas.drawCircle(Offset(w * 0.27, h * 0.57), 18 * scale, Paint()..color = color.withOpacity(0.18));
    canvas.drawCircle(Offset(w * 0.73, h * 0.57), 18 * scale, Paint()..color = color.withOpacity(0.18));
  }

  void _drawAntenna(Canvas canvas, {required double centerX, required double topY, required Color color, required double scale}) {
    _line(canvas, Offset(centerX, topY), Offset(centerX, topY - 38 * scale), color.withOpacity(0.75), 7 * scale);
    canvas.drawCircle(Offset(centerX, topY - 48 * scale), 12 * scale, Paint()..color = color);
  }

  void _drawEar(Canvas canvas, {required double x, required double y, required Color color, required double scale}) {
    final rect = Rect.fromLTWH(x - 12 * scale, y - 36 * scale, 24 * scale, 72 * scale);
    _roundRect(canvas, rect, 18, AppColors.robotDark);
    _roundRectStroke(canvas, rect, 18, color.withOpacity(0.65), 5 * scale);
  }

  @override
  bool shouldRepaint(covariant CompanionRobotFacePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.tick != tick || oldDelegate.largeMode != largeMode;
  }
}

class RobotHeroPreviewPainter extends CustomPainter {
  const RobotHeroPreviewPainter({required this.mood, required this.tick});

  final CompanionBotMood mood;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    final glowColor = switch (mood) {
      CompanionBotMood.angry => const Color(0xFFFF3B4E),
      CompanionBotMood.love => const Color(0xFFFF5EA8),
      CompanionBotMood.surprised => const Color(0xFFFACC15),
      _ => const Color(0xFF1E63FF),
    };
    final breathe = 0.94 + _easeSin(tick) * 0.10;
    final centerX = size.width * 0.5;
    final screenW = size.width * 0.64;
    final screenH = size.height * 0.42;
    final screenLeft = centerX - screenW / 2;
    final screenTop = size.height * 0.15;

    canvas.drawCircle(Offset(centerX, screenTop + screenH * 0.62), size.width * 0.27, Paint()..color = glowColor.withOpacity(0.11));
    _roundRect(canvas, Rect.fromLTWH(screenLeft + 6, screenTop + screenH + 44, screenW - 12, 20), 24, Colors.black.withOpacity(0.34));
    _roundRect(canvas, Rect.fromLTWH(screenLeft, screenTop, screenW, screenH), 46, AppColors.robotScreen);
    _roundRectStroke(canvas, Rect.fromLTWH(screenLeft, screenTop, screenW, screenH), 46, glowColor.withOpacity(0.45), 4);
    _roundRect(canvas, Rect.fromLTWH(screenLeft + 10, screenTop + 8, screenW - 20, screenH * 0.20), 32, Colors.white.withOpacity(0.12));

    final eyeRadius = screenW * 0.08 * breathe;
    final eyeCenterY = screenTop + screenH * 0.36 + eyeRadius;
    _drawWhiteEye(canvas, Offset(screenLeft + screenW * 0.31, eyeCenterY), eyeRadius);
    _drawWhiteEye(canvas, Offset(screenLeft + screenW * 0.69, eyeCenterY), eyeRadius);

    canvas.drawArc(
      Rect.fromLTWH(centerX - screenW * 0.09, screenTop + screenH * 0.58, screenW * 0.18, screenH * 0.18),
      _deg(20),
      _deg(140),
      false,
      Paint()
        ..color = AppColors.robotEye
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    for (var index = 0; index < 4; index++) {
      final barHeight = 7.0 + index * 4;
      _roundRect(canvas, Rect.fromLTWH(screenLeft + screenW - 38 + index * 7, screenTop + 20 - barHeight, 4, barHeight), 3, Colors.white.withOpacity(0.72));
    }

    final bodyTop = screenTop + screenH + 8;
    final bodyW = screenW * 0.46;
    final bodyH = size.height * 0.26;
    final bodyLeft = centerX - bodyW / 2;
    _roundRect(canvas, Rect.fromLTWH(bodyLeft, bodyTop, bodyW, bodyH), 28, const Color(0xFFF9FAFB));
    _roundRect(canvas, Rect.fromLTWH(centerX - bodyW * 0.28, bodyTop + bodyH * 0.38, bodyW * 0.56, bodyH * 0.22), 18, AppColors.robotDark);
    _roundRect(canvas, Rect.fromLTWH(centerX - bodyW * 0.18, bodyTop + bodyH * 0.45, bodyW * 0.36, 5), 6, const Color(0xFF35C8FF));
    _roundRect(canvas, Rect.fromLTWH(bodyLeft - 14, bodyTop + bodyH * 0.30, 22, bodyH * 0.56), 12, const Color(0xFF374151));
    _roundRect(canvas, Rect.fromLTWH(bodyLeft + bodyW - 8, bodyTop + bodyH * 0.30, 22, bodyH * 0.56), 12, const Color(0xFF374151));
  }

  @override
  bool shouldRepaint(covariant RobotHeroPreviewPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.tick != tick;
  }
}

class ImmersiveRobotDisplayPainter extends CustomPainter {
  const ImmersiveRobotDisplayPainter({required this.mood, required this.tick});

  final CompanionBotMood mood;
  final double tick;

  @override
  void paint(Canvas canvas, Size size) {
    _drawImmersiveBackground(canvas, size);
    _drawImmersiveEyes(canvas, size);
    _drawImmersiveStatus(canvas, size);
  }

  void _drawImmersiveBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF10233A), Color(0xFF07111F), Colors.black],
          center: const Alignment(0, -0.28),
          radius: 0.78,
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.30,
      Paint()..color = const Color(0xFF36C8FF).withOpacity(0.08),
    );
  }

  void _drawImmersiveEyes(Canvas canvas, Size size) {
    final breathe = 0.88 + _easeSin(tick) * 0.16;
    final floatY = -5 + _easeSin(tick * 3200 / 2200) * 10;
    final eyeRadius = size.width * 0.075 * breathe;
    final eyeCenterY = size.height * 0.28 + floatY + eyeRadius;

    _drawWhiteEye(canvas, Offset(size.width * 0.34, eyeCenterY), eyeRadius);
    _drawWhiteEye(canvas, Offset(size.width * 0.66, eyeCenterY), eyeRadius);
  }

  void _drawImmersiveStatus(Canvas canvas, Size size) {
    final startX = size.width - 92;
    const topY = 32.0;
    for (var index = 0; index < 5; index++) {
      final h = 10.0 + index * 6;
      _roundRect(canvas, Rect.fromLTWH(startX + index * 9, topY + 34 - h, 5, h), 3, Colors.white.withOpacity(0.78));
    }
    canvas.drawCircle(Offset(34, size.height * 0.5), 3, Paint()..color = Colors.white.withOpacity(0.72));
  }

  @override
  bool shouldRepaint(covariant ImmersiveRobotDisplayPainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.tick != tick;
  }
}

double _easeSin(double value) {
  return (math.sin(value * math.pi * 2 - math.pi / 2) + 1) / 2;
}

double _deg(double degrees) {
  return degrees * math.pi / 180;
}

void _roundRect(Canvas canvas, Rect rect, double radius, Color color) {
  canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = color);
}

void _roundRectStroke(Canvas canvas, Rect rect, double radius, Color color, double width) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(radius)),
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );
}

void _oval(Canvas canvas, Rect rect, Color color) {
  canvas.drawOval(rect, Paint()..color = color);
}

void _line(Canvas canvas, Offset start, Offset end, Color color, double width) {
  canvas.drawLine(
    start,
    end,
    Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round,
  );
}

void _drawWhiteEye(Canvas canvas, Offset center, double radius) {
  canvas.drawCircle(center, radius, Paint()..color = Colors.white);
}
