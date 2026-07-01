import 'package:flutter/material.dart';
import 'package:milo_ai/app/shared/models/companion_connect_state.dart';
import 'package:milo_ai/app/pages/set/models/robot_settings_content.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_header.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_row.dart';
import 'package:milo_ai/app/pages/set/widgets/settings_section.dart';
import 'package:milo_ai/app/pages/set/widgets/status_pill.dart';
import 'package:milo_ai/app/shared/theme/app_colors.dart';
import 'package:milo_ai/app/shared/widgets/menu/privacy_menu_panel.dart';
import 'package:milo_ai/app/shared/widgets/menu/user_agreement_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class RobotSettingsPage extends StatelessWidget {
  const RobotSettingsPage({
    required this.connectState,
    super.key,
  });

  final CompanionConnectState connectState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 144),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeader(),
              const SizedBox(height: 24),
              SettingsSection(
                title: '支持与关于',
                children: [
                  SettingsRow(
                    icon: Icons.bug_report_rounded,
                    title: 'Bug 问题反馈',
                    subtitle: '遇到问题时可直接发送邮件给开发团队',
                    accentColor: AppColors.orange,
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => _openBugFeedbackEmail(context),
                  ),
                  SettingsRow(
                    icon: Icons.description_rounded,
                    title: '用户协议',
                    subtitle: '查看 Mota 的使用规则、功能边界和服务说明',
                    accentColor: AppColors.aqua,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showUserAgreementDialog(context),
                  ),
                  SettingsRow(
                    icon: Icons.privacy_tip_rounded,
                    title: '隐私政策',
                    subtitle: '查看蓝牙、相册和本地资料的使用说明',
                    accentColor: AppColors.ink,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: '关于 Mota',
                    subtitle: '当前状态：${statusText(connectState)}，Flutter 移动端版本',
                    accentColor: AppColors.aqua,
                    trailing: const StatusPill(
                      text: RobotSettingsContent.appVersion,
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: PrivacyMenuPanel(),
      ),
    );
  }

  void _showUserAgreementDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: UserAgreementPanel(),
      ),
    );
  }

  Future<void> _openBugFeedbackEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: RobotSettingsContent.feedbackEmail,
      queryParameters: const {
        'subject': 'Mota Bug 问题反馈',
        'body': '请描述你遇到的问题：\n\n发生页面：\n操作步骤：\n期望结果：\n实际结果：\n',
      },
    );

    final opened = await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );

    if (opened || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '没有找到可用的邮箱应用：${RobotSettingsContent.feedbackEmail}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text('关于 Mota'),
        content: const Text(
          'MotaAI 是一个开源的手机 AI 平台，可以连接电脑，让你在手机上完成代码的编写与开发。\n\n'
          '同时，MotaAI 也是一个聊天机器人，你可以随时和它聊天，也可以通过语音聊天的方式完成开发。',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
