// 文件作用：保存和读取 Mota 用户协议接受状态，保持协议版本判断集中在一个地方。

import 'package:shared_preferences/shared_preferences.dart';

class AgreementAcceptanceStore {
  const AgreementAcceptanceStore();

  static const String acceptedKey = 'hasAcceptedUserAgreement';
  static const String versionKey = 'agreementVersion';
  static const String currentVersion = '2026-07-01';

  Future<bool> shouldShowAgreementGate() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(acceptedKey) ?? false;
    final version = prefs.getString(versionKey);

    return !accepted || version != currentVersion;
  }

  Future<void> acceptCurrentAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(acceptedKey, true);
    await prefs.setString(versionKey, currentVersion);
  }
}
