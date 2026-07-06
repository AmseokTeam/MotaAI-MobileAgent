import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AgreementGateDialog extends StatefulWidget {
  const AgreementGateDialog({
    required this.onAccepted,
    super.key,
  });

  final Future<void> Function() onAccepted;

  @override
  State<AgreementGateDialog> createState() => _AgreementGateDialogState();
}

class _AgreementGateDialogState extends State<AgreementGateDialog> {
  static const String _agreementText = '''
欢迎使用 Mota。

Mota 是一款用于机器人状态展示、蓝牙连接、表情互动、对话交互和本地演示的应用。

在使用过程中，我们可能会申请蓝牙、麦克风、相册/图片、通知等权限，但仅会在你使用对应功能时调用。

当前版本主要在设备本地运行，不会主动上传你的语音内容、相册图片或机器人控制数据。

使用 Mota 时，请勿进行违法、危险、破坏设备或侵犯他人权益的行为。机器人连接和控制效果可能受设备、系统版本、蓝牙环境等因素影响，请在安全环境下使用。

继续使用即表示你已阅读并同意《用户协议》和《隐私协议》。

开发团队：AmseokTech
联系邮箱：linsion07@outlook.com
''';

  bool _showWarning = false;
  bool _saving = false;

  Future<void> _acceptAgreement() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);
    await widget.onAccepted();
  }

  void _rejectAgreement() {
    setState(() => _showWarning = true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.ink,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '用户协议与隐私协议说明',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSoft,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.muted.withValues(alpha: 0.10),
                      ),
                    ),
                    child: const SingleChildScrollView(
                      child: Text(
                        _agreementText,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _showWarning
                      ? const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            '需要同意用户协议与隐私协议后才能继续使用 Mota。',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : const SizedBox(height: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _rejectAgreement,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.ink,
                          side: BorderSide(
                            color: AppColors.muted.withValues(alpha: 0.24),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          '不同意',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _acceptAgreement,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: AppColors.lime,
                          foregroundColor: AppColors.ink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.ink,
                                ),
                              )
                            : const Text(
                                '同意并继续',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
