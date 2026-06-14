import 'package:flutter/material.dart';

import '../../shared/models/companion_connect_state.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/widgets/page_title.dart';
import '../../shared/widgets/soft_cards.dart';
import 'models/companion_bot_mood.dart';
import 'widgets/home_header.dart';
import 'widgets/mood_grid.dart';
import 'widgets/robot_hero_card.dart';

class RobotHomePage extends StatelessWidget {
  const RobotHomePage({
    required this.mood,
    required this.connectState,
    required this.lastCommand,
    required this.aiMessage,
    required this.onMoodChange,
    required this.onFullScreenTap,
    required this.onConnectTap,
    super.key,
  });

  final CompanionBotMood mood;
  final CompanionConnectState connectState;
  final String lastCommand;
  final String aiMessage;
  final ValueChanged<CompanionBotMood> onMoodChange;
  final VoidCallback onFullScreenTap;
  final VoidCallback onConnectTap;

  bool get _connected => connectState == CompanionConnectState.connected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 144),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 16),
              RobotHeroCard(
                mood: mood,
                onTap: onFullScreenTap,
              ),
              const SizedBox(height: 16),
              _CompactHomeAction(
                icon: Icons.link_rounded,
                title: '快速连接',
                subtitle: _connected ? '已在线' : '连接 LinBot-01',
                color: AppColors.coralSoft,
                onTap: onConnectTap,
              ),
              const SizedBox(height: 18),
              const SectionTitle('Mood Expressions'),
              const SizedBox(height: 12),
              MoodGrid(currentMood: mood, onMoodChange: onMoodChange),
              const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}

class _CompactHomeAction extends StatelessWidget {
  const _CompactHomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(26),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 110,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.ink, size: 24),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
