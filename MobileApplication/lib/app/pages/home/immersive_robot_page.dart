// 文件作用：实现全屏横屏机器人表情页，复用首页机器人脸部预览动画。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/companion_bot_mood.dart';
import 'widgets/robot_face_canvas.dart';

class ImmersiveRobotPage extends StatefulWidget {
  const ImmersiveRobotPage({
    required this.mood,
    required this.onExit,
    super.key,
  });

  final CompanionBotMood mood;
  final VoidCallback onExit;

  @override
  State<ImmersiveRobotPage> createState() => _ImmersiveRobotPageState();
}

class _ImmersiveRobotPageState extends State<ImmersiveRobotPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: widget.onExit,
        child: Stack(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.72,
                heightFactor: 0.42,
                child: RobotHeroPreview(mood: widget.mood),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 46,
              child: Text(
                immersiveCaption(widget.mood),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Text(
                '轻点屏幕返回',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 28,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: widget.mood.moodColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
