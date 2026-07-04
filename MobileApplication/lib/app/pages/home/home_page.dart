import 'package:flutter/material.dart';

import '../../core/pc_bridge/pc_bridge_controller.dart';
import '../../shared/theme/app_colors.dart';
import 'controllers/mota_chat_controller.dart';
import 'models/companion_bot_mood.dart';
import 'widgets/mota_chat_input.dart';
import 'widgets/mota_chat_transcript.dart';
import 'widgets/robot_face_canvas.dart';

class RobotHomePage extends StatefulWidget {
  const RobotHomePage({
    required this.mood,
    required this.bridgeController,
    required this.onPcConnectionFailed,
    super.key,
  });

  final CompanionBotMood mood;
  final PcBridgeController bridgeController;
  final VoidCallback onPcConnectionFailed;

  @override
  State<RobotHomePage> createState() => _RobotHomePageState();
}

class _RobotHomePageState extends State<RobotHomePage> {
  late final MotaChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = MotaChatController(
      bridgeController: widget.bridgeController,
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

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
                (constraints.maxHeight * 0.18).clamp(96.0, 148.0).toDouble();
            final faceHeight =
                (constraints.maxHeight * 0.22).clamp(160.0, 210.0).toDouble();

            return ColoredBox(
              color: AppColors.chatWarmBackground,
              child: AnimatedBuilder(
                animation: _chatController,
                builder: (context, child) {
                  final hasConversation = _chatController.messages.isNotEmpty ||
                      _chatController.isSending ||
                      _chatController.errorText != null;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Column(
                      children: [
                        if (hasConversation)
                          const SizedBox(height: 8)
                        else ...[
                          SizedBox(height: topGap),
                          SizedBox(
                            height: faceHeight,
                            child: FractionallySizedBox(
                              widthFactor: 0.96,
                              child: RobotHeroPreview(mood: widget.mood),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '你想和Mota聊些什么？',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                        Expanded(
                          child: hasConversation
                              ? MotaChatTranscript(
                                  chatController: _chatController,
                                )
                              : const SizedBox.expand(),
                        ),
                        MotaChatInput(
                          chatController: _chatController,
                          bridgeController: widget.bridgeController,
                          onPcConnectionFailed: widget.onPcConnectionFailed,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _PortraitOnlyView extends StatelessWidget {
  const _PortraitOnlyView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.chatWarmBackground,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            '该功能仅支持竖屏使用',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
