import 'package:flutter/material.dart';

import '../../../features/bluetooth/models/companion_connect_state.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';
import '../models/companion_bot_mood.dart';
import '../widgets/home_header.dart';
import '../widgets/mood_grid.dart';
import '../widgets/robot_hero_card.dart';

class RobotHomePage extends StatelessWidget {
  const RobotHomePage({
    required this.mood,
    required this.connectState,
    required this.lastCommand,
    required this.aiMessage,
    required this.onMoodChange,
    required this.onFullScreenTap,
    required this.onAiCallTap,
    required this.onConnectTap,
    super.key,
  });

  final CompanionBotMood mood;
  final CompanionConnectState connectState;
  final String lastCommand;
  final String aiMessage;
  final ValueChanged<CompanionBotMood> onMoodChange;
  final VoidCallback onFullScreenTap;
  final VoidCallback onAiCallTap;
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
              _UsageOverviewCard(
                connected: _connected,
                mood: mood,
                onAiCallTap: onAiCallTap,
              ),
              const SizedBox(height: 14),
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

class _UsageOverviewCard extends StatelessWidget {
  const _UsageOverviewCard({
    required this.connected,
    required this.mood,
    required this.onAiCallTap,
  });

  final bool connected;
  final CompanionBotMood mood;
  final VoidCallback onAiCallTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(30),
      elevation: 10,
      shadowColor: AppColors.ink.withValues(alpha: 0.18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF202B3A), Color(0xFF111827)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '机器人使用时长',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _OnlineDot(connected: connected),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: _UsageMetric(
                    value: '2h 36m',
                    label: '今日陪伴',
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _UsageMetric(
                    value: '${mood.emoji} ${mood.title}',
                    label: '当前表情',
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: _MiniChart(),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAiCallTap,
                    child: const SizedBox(
                      width: 112,
                      height: 58,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '呼唤',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: connected ? const Color(0xFF22C55E) : AppColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? '在线' : '待连接',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageMetric extends StatelessWidget {
  const _UsageMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.aqua, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart();

  static const List<double> _bars = [0.45, 0.62, 0.38, 0.78, 0.92, 0.58];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _bars
            .map(
              (heightFactor) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FractionallySizedBox(
                    heightFactor: heightFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.aqua,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
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
