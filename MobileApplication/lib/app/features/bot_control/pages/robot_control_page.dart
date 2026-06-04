// 文件作用：实现机器人移动控制页，按钮顺序和布局对应 Kotlin 的 RobotControlPage。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/bluetooth/models/companion_connect_state.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';
import '../models/companion_move_command.dart';

class RobotControlPage extends StatelessWidget {
  const RobotControlPage({
    required this.connectState,
    required this.lastCommand,
    required this.onMoveCommand,
    super.key,
  });

  final CompanionConnectState connectState;
  final String lastCommand;
  final ValueChanged<CompanionMoveCommand> onMoveCommand;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle(title: 'Control', subtitle: 'Move your robot'),
          const SizedBox(height: 22),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Robot Movement', style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('蓝牙状态：${statusText(connectState)}', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                  const SizedBox(height: 24),
                  ControlButton(text: '到我旁边', orange: true, onTap: () => onMoveCommand(CompanionMoveCommand.comeHere)),
                  const SizedBox(height: 12),
                  ControlButton(text: '前进', onTap: () => onMoveCommand(CompanionMoveCommand.forward)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: ControlButton(text: '左转', onTap: () => onMoveCommand(CompanionMoveCommand.left))),
                      const SizedBox(width: 12),
                      Expanded(child: ControlButton(text: '停止', danger: true, onTap: () => onMoveCommand(CompanionMoveCommand.stop))),
                      const SizedBox(width: 12),
                      Expanded(child: ControlButton(text: '右转', onTap: () => onMoveCommand(CompanionMoveCommand.right))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ControlButton(text: '后退', onTap: () => onMoveCommand(CompanionMoveCommand.backward)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ActivityItem(
            emoji: '🎮',
            title: 'Last Command',
            subtitle: '当前只是前端指令，后期接真实蓝牙发送。',
            value: lastCommand,
          ),
        ],
      ),
    );
  }
}
