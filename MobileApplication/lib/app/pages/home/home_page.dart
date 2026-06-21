import 'package:flutter/material.dart';

import '../../shared/theme/app_colors.dart';
import 'models/companion_bot_mood.dart';
import 'widgets/robot_face_canvas.dart';

class RobotHomePage extends StatelessWidget {
  const RobotHomePage({
    required this.mood,
    super.key,
  });

  final CompanionBotMood mood;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const _PortraitOnlyView();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final topGap =
                (constraints.maxHeight * 0.08).clamp(28.0, 76.0).toDouble();
            final faceHeight =
                (constraints.maxHeight * 0.30).clamp(170.0, 260.0).toDouble();

            return ColoredBox(
              color: AppColors.heroDeepBlack,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 124),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 124,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: topGap),
                      SizedBox(
                        height: faceHeight,
                        child: FractionallySizedBox(
                          widthFactor: 0.78,
                          child: RobotHeroPreview(mood: mood),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '你想和Mota聊些什么？',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _MotaChatInput(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MotaChatInput extends StatelessWidget {
  const _MotaChatInput();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      child: TextField(
        minLines: 1,
        maxLines: 4,
        textInputAction: TextInputAction.send,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: '输入你想说的话',
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.chat_bubble_rounded,
            color: AppColors.orange,
            size: 21,
          ),
          suffixIcon: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

class _PortraitOnlyView extends StatelessWidget {
  const _PortraitOnlyView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.heroDeepBlack,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            '该功能仅支持竖屏使用',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
