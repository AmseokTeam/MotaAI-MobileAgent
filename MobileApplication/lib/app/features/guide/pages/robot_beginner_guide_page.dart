// 文件作用：实现新手引导页面，复刻 Kotlin 的 GuideIntroCard 和四个步骤卡片。

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/page_title.dart';
import '../../../shared/widgets/soft_cards.dart';

class RobotBeginnerGuidePage extends StatelessWidget {
  const RobotBeginnerGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PageTitle(title: 'Guide', subtitle: '新手文档'),
          SizedBox(height: 22),
          GuideIntroCard(),
          SizedBox(height: 18),
          SectionTitle('快速上手'),
          SizedBox(height: 12),
          GuideStepCard(step: '01', title: '连接机器人', description: '进入蓝牙页，扫描附近设备，选择 LinBot 或你的机器人蓝牙名称进行连接。'),
          GuideStepCard(step: '02', title: '切换表情', description: '在首页选择开心、委屈、生气、惊讶、困困、喜欢等表情，机器人脸部会立即变化。'),
          GuideStepCard(step: '03', title: '控制移动', description: '进入 Move 页面发送前进、后退、左转、右转、停止和到我旁边等指令。'),
          GuideStepCard(step: '04', title: '全屏展示', description: '点击首页机器人脸部卡片，可横屏全屏显示表情，再次点击或返回即可退出。'),
          SizedBox(height: 12),
          ActivityItem(
            emoji: '💡',
            title: '开发提示',
            subtitle: '当前控制和连接状态仍是前端应用层逻辑，后续接入真实机器人协议后即可发送硬件指令。',
            value: 'NEXT',
          ),
        ],
      ),
    );
  }
}

class GuideIntroCard extends StatelessWidget {
  const GuideIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(32),
      elevation: 8,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('陪伴机器人控制台', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
              '这里整理了第一次使用时最常用的流程：先连接蓝牙，再选择表情，最后发送移动指令。',
              style: TextStyle(color: Color(0xB8FFFFFF), fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideStepCard extends StatelessWidget {
  const GuideStepCard({
    required this.step,
    required this.title,
    required this.description,
    super.key,
  });

  final String step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.11),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(18)),
                alignment: Alignment.center,
                child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.46)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
