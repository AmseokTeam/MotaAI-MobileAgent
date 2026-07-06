import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class UserAgreementPanel extends StatelessWidget {
  const UserAgreementPanel({super.key});

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
            _AgreementHero(),
            SizedBox(height: 14),
            _AgreementParagraph(
              text:
                  '欢迎使用 Mota。本协议用于说明你在使用 Mota 机器人陪伴应用时的基本规则、功能边界和双方责任。使用本应用即表示你已阅读并同意本协议。',
            ),
            _AgreementSection(
              title: '1. 服务内容',
              body:
                  'Mota 当前提供机器人状态展示、对话交互、表情动画、蓝牙连接、本地语音识别、头像与昵称设置、机器人移动控制和本地演示等功能。部分能力仍可能处于测试或演示阶段，实际效果以当前版本为准。',
            ),
            _AgreementSection(
              title: '2. 用户行为',
              body:
                  '你应当以合法、合理、安全的方式使用 Mota，不得利用本应用进行违法违规、侵害他人权益、恶意控制设备、破坏网络或系统安全的行为。',
            ),
            _AgreementSection(
              title: '3. 机器人连接与控制',
              body:
                  '当你使用蓝牙连接、移动控制或机器人互动功能时，请确认周围环境安全，并自行承担因不当操作、设备故障或环境因素产生的风险。Mota 会尽量提供清晰的状态提示，但不保证所有硬件状态都能实时准确反馈。',
            ),
            _AgreementSection(
              title: '4. AI 与语音能力',
              body:
                  '如果你配置第三方 AI 接口或开启本地语音识别，请确认相关服务来源可信，并遵守对应服务条款。当前版本默认不会主动上传语音内容；后续如接入云端能力，将在隐私政策中补充说明。',
            ),
            _AgreementSection(
              title: '5. 本地数据',
              body:
                  '头像、昵称、个性签名、连接偏好、对话配置和部分交互状态可能会保存在你的设备本地。卸载应用、清理缓存或更换设备可能导致这些数据丢失。',
            ),
            _AgreementSection(
              title: '6. 版本更新',
              body:
                  'Mota 可能会根据功能开发、系统适配、安全要求或用户反馈进行更新。更新后部分页面、功能名称、交互方式或协议内容可能发生变化。',
            ),
            _AgreementSection(
              title: '7. 免责声明',
              body:
                  '在法律允许范围内，Mota 对因网络异常、系统兼容、第三方服务、硬件设备、用户误操作或不可抗力造成的服务中断、数据丢失或使用异常不承担超出法律规定的责任。',
            ),
            _AgreementContact(),
          ],
        ),
      ),
    );
  }
}

class _AgreementHero extends StatelessWidget {
  const _AgreementHero();

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
            'Mota 用户协议',
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

class _AgreementParagraph extends StatelessWidget {
  const _AgreementParagraph({required this.text});

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

class _AgreementSection extends StatelessWidget {
  const _AgreementSection({
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

class _AgreementContact extends StatelessWidget {
  const _AgreementContact();

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
            '如果你对用户协议有疑问，可以通过以下方式联系我们：\n\n开发团队：AmseokTech\n联系邮箱：linsion07@outlook.com',
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
