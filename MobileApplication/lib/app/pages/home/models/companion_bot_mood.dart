// 文件作用：定义机器人表情枚举、中文文案、符号和表情对应颜色。

import 'package:flutter/material.dart';

class CompanionBotMoodInfo {
  const CompanionBotMoodInfo({
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
  });

  final String title;
  final String emoji;
  final String description;
  final Color color;
}

enum CompanionBotMood {
  happy,
  sad,
  angry,
  surprised,
  sleepy,
  love,
  neutral,
}

extension CompanionBotMoodMeta on CompanionBotMood {
  CompanionBotMoodInfo get info {
    return switch (this) {
      CompanionBotMood.happy => const CompanionBotMoodInfo(
          title: '开心',
          emoji: '😊',
          description: '机器人现在很开心',
          color: Color(0xFF22C55E),
        ),
      CompanionBotMood.sad => const CompanionBotMoodInfo(
          title: '委屈',
          emoji: '🥺',
          description: '机器人有点委屈',
          color: Color(0xFF60A5FA),
        ),
      CompanionBotMood.angry => const CompanionBotMoodInfo(
          title: '生气',
          emoji: '😠',
          description: '机器人有点生气',
          color: Color(0xFFEF4444),
        ),
      CompanionBotMood.surprised => const CompanionBotMoodInfo(
          title: '惊讶',
          emoji: '😮',
          description: '机器人发现了新东西',
          color: Color(0xFFFACC15),
        ),
      CompanionBotMood.sleepy => const CompanionBotMoodInfo(
          title: '困困',
          emoji: '😴',
          description: '机器人想休息一下',
          color: Color(0xFFA78BFA),
        ),
      CompanionBotMood.love => const CompanionBotMoodInfo(
          title: '喜欢',
          emoji: '😍',
          description: '机器人想靠近你',
          color: Color(0xFFFF5EA8),
        ),
      CompanionBotMood.neutral => const CompanionBotMoodInfo(
          title: '平静',
          emoji: '😐',
          description: '机器人正在待机',
          color: Color(0xFF38BDF8),
        ),
    };
  }

  String get title => info.title;
  String get emoji => info.emoji;
  String get description => info.description;
  Color get moodColor => info.color;
}

String immersiveCaption(CompanionBotMood mood) {
  return switch (mood) {
    CompanionBotMood.happy => '听说你会表演才艺',
    CompanionBotMood.sad => '我有一点点委屈',
    CompanionBotMood.angry => '我现在有点生气',
    CompanionBotMood.surprised => '哇，发现新东西了',
    CompanionBotMood.sleepy => '不用点火，我想休息一会',
    CompanionBotMood.love => '喜欢你，想靠近一点',
    CompanionBotMood.neutral => '我在听，你说',
  };
}
