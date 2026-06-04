// 文件作用：实现设置页，保留 Kotlin 项目中的蓝牙状态、扫描、快速连接和断开入口。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/bluetooth/models/companion_connect_state.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';

class RobotSettingsPage extends StatelessWidget {
  const RobotSettingsPage({
    required this.connectState,
    required this.onScanTap,
    required this.onConnectTap,
    required this.onDisconnectTap,
    super.key,
  });

  final CompanionConnectState connectState;
  final VoidCallback onScanTap;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle(title: 'Settings', subtitle: 'Bluetooth and robot config'),
          const SizedBox(height: 22),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bluetooth', style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('当前状态：${statusText(connectState)}', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                  const SizedBox(height: 18),
                  ControlButton(text: '扫描机器人', onTap: onScanTap),
                  const SizedBox(height: 10),
                  ControlButton(text: '连接 LinBot-01', orange: true, onTap: onConnectTap),
                  const SizedBox(height: 10),
                  ControlButton(text: '断开连接', danger: true, onTap: onDisconnectTap),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const ActivityItem(
            emoji: '🧩',
            title: 'Next Step',
            subtitle: '后期可以新增真实 BluetoothRobotController 发送硬件指令。',
            value: 'NEXT',
          ),
        ],
      ),
    );
  }
}
