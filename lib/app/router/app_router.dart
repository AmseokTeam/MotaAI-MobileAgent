// 文件作用：集中定义底部导航 tab，避免页面索引和文案散落在多个文件里

enum RobotTab {
  chat('assets/icons/harmony_message.svg', '对话'),
  creativeWorkshop('assets/icons/harmony_creative.svg', '创意工坊'),
  settings('assets/icons/harmony_settings.svg', '设置');

  const RobotTab(this.iconAsset, this.label);

  final String iconAsset;
  final String label;
}
