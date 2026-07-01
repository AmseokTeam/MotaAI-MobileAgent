import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class PrivacyMenuPanel extends StatelessWidget {
  const PrivacyMenuPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: math.min(screenHeight * 0.68, 560),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(right: 10, bottom: 6),
          children: const [
            _PrivacyHero(),
            SizedBox(height: 14),
            _PrivacyParagraph(
              text: '欢迎使用 Mota。我们重视你的隐私和个人信息保护。本协议用于说明 Mota 如何收集、使用和保护你的信息。',
            ),
            _PrivacySection(
              title: '1. 信息收集与使用',
              body: 'Mota 当前主要用于机器人状态展示、对话交互、表情动画、蓝牙连接和本地演示。我们可能会在以下场景使用相关信息：',
            ),
            _PrivacyItem(
              title: '蓝牙连接',
              body: '用于搜索附近机器人设备、建立连接、发送控制指令，并记录最近连接的设备偏好。',
            ),
            _PrivacyItem(
              title: '头像图片',
              body: '如果你选择头像图片，我们仅用于个人主页头像显示，不会自动上传或扫描你的相册。',
            ),
            _PrivacyItem(
              title: '本地语音识别',
              body: '如果你开启语音识别功能，Mota 可能会使用麦克风进行语音输入。当前版本默认在设备本地处理，不会主动上传语音内容。',
            ),
            _PrivacyItem(
              title: '本地设置',
              body: '例如触感反馈、表情动画、连接偏好等设置，会保存在你的设备本地，用于提升使用体验。',
            ),
            _PermissionSection(),
            _PrivacySection(
              title: '3. 数据存储',
              body:
                  '当前版本主要将数据保存在你的设备本地，例如应用设置、头像缓存、连接偏好和交互状态。\n\n除非你主动使用云同步、AI 接口或账号服务，否则我们不会主动上传你的个人信息或机器人控制数据。',
            ),
            _PrivacySection(
              title: '4. 第三方服务',
              body:
                  '当前版本默认不向第三方共享你的个人信息。\n\n如果后续接入第三方 AI、云服务、统计 SDK 或其他服务，我们会在隐私政策中补充说明，并在需要时征得你的同意。',
            ),
            _PrivacySection(
              title: '5. 信息安全',
              body: '我们会尽量减少不必要的信息收集，并采取合理措施保护你的数据安全。但请理解，任何系统都无法保证绝对安全。',
            ),
            _PrivacySection(
              title: '6. 未成年人保护',
              body: '如果你是未满 14 周岁的未成年人，请在监护人同意和指导下使用本应用。',
            ),
            _PrivacySection(
              title: '7. 协议更新',
              body:
                  '如果 Mota 后续增加账号登录、云同步、第三方 AI、远程控制等功能，我们可能会更新本协议，并通过应用内提示等方式告知你。',
            ),
            _ContactSection(),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.robotDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mota 隐私协议',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          _DateLine(label: '更新日期', value: '2026 年 6 月 26 日'),
          SizedBox(height: 4),
          _DateLine(label: '生效日期', value: '2026 年 7 月 1 日'),
        ],
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label：$value',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.72),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PrivacyParagraph extends StatelessWidget {
  const _PrivacyParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.muted.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.aquaSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.aqua,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionSection extends StatelessWidget {
  const _PermissionSection();

  @override
  Widget build(BuildContext context) {
    return const _PrivacySection(
      title: '2. 权限说明',
      body:
          'Mota 可能会申请以下权限：\n\n蓝牙权限：搜索和连接机器人设备\n麦克风权限：本地语音识别\n相册/图片权限：设置头像\n通知权限：连接状态或提醒\n网络权限：后续云服务、AI 接口或版本更新\n\n你可以拒绝或关闭相关权限，但对应功能可能无法正常使用。',
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '8. 联系我们',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '如果你对隐私协议有疑问，可以通过以下方式联系我们：\n\n开发团队：AmseokTech\n联系邮箱：linsion07@outlook.com',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
