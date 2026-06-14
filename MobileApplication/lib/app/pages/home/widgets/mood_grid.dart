import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/companion_bot_mood.dart';

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
      [
        CompanionBotMood.surprised,
        CompanionBotMood.sleepy,
        CompanionBotMood.love,
      ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? mood.moodColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
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
