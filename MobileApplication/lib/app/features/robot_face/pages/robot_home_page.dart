// 文件作用：实现首页布局，复刻原 Kotlin 的顶部问候、机器人黑色卡片、操作卡、表情网格和最近活动。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/bluetooth/models/companion_connect_state.dart';
import '../../../shared/widgets/app_menu_overlay.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';
import '../models/companion_bot_mood.dart';
import '../widgets/robot_face_canvas.dart';

class RobotHomePage extends StatelessWidget {
  const RobotHomePage({
    required this.mood,
    required this.connectState,
    required this.lastCommand,
    required this.aiMessage,
    required this.onMoodChange,
    required this.onFullScreenTap,
    required this.onAiCallTap,
    required this.onScanTap,
    required this.onConnectTap,
    required this.onMenuTap,
    super.key,
  });

  final CompanionBotMood mood;
  final CompanionConnectState connectState;
  final String lastCommand;
  final String aiMessage;
  final ValueChanged<CompanionBotMood> onMoodChange;
  final VoidCallback onFullScreenTap;
  final VoidCallback onAiCallTap;
  final VoidCallback onScanTap;
  final VoidCallback onConnectTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopGreeting(onMenuTap: onMenuTap),
          const SizedBox(height: 22),
          RobotHeroCard(
            mood: mood,
            connectState: connectState,
            onTap: onFullScreenTap,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SoftActionCard(
                  title: 'AI 呼唤',
                  subtitle: '到我旁边',
                  emoji: '✨',
                  onTap: onAiCallTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftActionCard(
                  title: '蓝牙扫描',
                  subtitle: '打开扫描窗口',
                  emoji: '📡',
                  highlighted: true,
                  onTap: onScanTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SoftActionCard(
            title: '快速连接',
            subtitle: '模拟连接 LinBot-01',
            emoji: '🤖',
            onTap: onConnectTap,
          ),
          const SizedBox(height: 22),
          const SectionTitle('Mood Expressions'),
          const SizedBox(height: 12),
          MoodGrid(currentMood: mood, onMoodChange: onMoodChange),
          const SizedBox(height: 22),
          const SectionTitle('Recent Activity'),
          const SizedBox(height: 12),
          ActivityItem(
            emoji: '💬',
            title: 'AI Feedback',
            subtitle: aiMessage,
            value: mood.title,
          ),
          ActivityItem(
            emoji: '🎮',
            title: 'Last Command',
            subtitle: lastCommand,
            value: statusText(connectState),
          ),
        ],
      ),
    );
  }
}

class TopGreeting extends StatelessWidget {
  const TopGreeting({required this.onMenuTap, super.key});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Afternoon 👋',
                style: TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                'Lin Robot',
                style: TextStyle(color: AppColors.ink, fontSize: 30, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        AppMenuButton(onTap: onMenuTap),
      ],
    );
  }
}

class RobotHeroCard extends StatelessWidget {
  const RobotHeroCard({
    required this.mood,
    required this.connectState,
    required this.onTap,
    super.key,
  });

  final CompanionBotMood mood;
  final CompanionConnectState connectState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.heroBlack,
      borderRadius: BorderRadius.circular(32),
      elevation: 14,
      shadowColor: Colors.black.withOpacity(0.25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 238,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  mood.moodColor.withOpacity(0.28),
                  AppColors.heroBlack,
                  AppColors.heroDeepBlack,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🤖', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('机器人屏幕', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          Text('轻点进入横屏陪伴模式', style: TextStyle(color: Color(0x8CFFFFFF), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Positioned.fill(
                    top: 42,
                    bottom: 30,
                    child: SizedBox.shrink(),
                  ),
                  Positioned.fill(
                    top: 42,
                    bottom: 30,
                    child: RobotHeroPreview(mood: mood),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MiniInfoBlock(title: 'Mood', value: '${mood.emoji} ${mood.title}'),
                        MiniInfoBlock(title: 'Connect', value: statusText(connectState)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MiniInfoBlock extends StatelessWidget {
  const MiniInfoBlock({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.48), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class MoodGrid extends StatelessWidget {
  const MoodGrid({
    required this.currentMood,
    required this.onMoodChange,
    super.key,
  });

  final CompanionBotMood currentMood;
  final ValueChanged<CompanionBotMood> onMoodChange;

  @override
  Widget build(BuildContext context) {
    final rows = [
      [CompanionBotMood.happy, CompanionBotMood.sad, CompanionBotMood.angry],
      [CompanionBotMood.surprised, CompanionBotMood.sleepy, CompanionBotMood.love],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: row.map((mood) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: mood == row.last ? 0 : 10),
                  child: MoodPill(
                    mood: mood,
                    selected: mood == currentMood,
                    onTap: () => onMoodChange(mood),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class MoodPill extends StatelessWidget {
  const MoodPill({
    required this.mood,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final CompanionBotMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? mood.moodColor : Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Center(
            child: Text(
              '${mood.emoji} ${mood.title}',
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
