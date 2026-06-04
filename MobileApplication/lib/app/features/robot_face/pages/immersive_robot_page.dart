// 文件作用：实现全屏横屏机器人表情页，对应 Kotlin 的 CompanionFullScreenFace 与 ImmersiveRobotDisplay。

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/companion_bot_mood.dart';
import '../widgets/robot_face_canvas.dart';

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
        child: ImmersiveRobotDisplay(mood: widget.mood),
      ),
    );
  }
}
