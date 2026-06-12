// 文件作用：集中定义底部导航 tab，避免页面索引和文案散落在多个文件里

enum RobotTab {
  home('🏠', 'Home'),
  move('🎮', 'Move'),
  bluetooth('📡', 'BT'),
  settings('⚙️', 'Set');

  const RobotTab(this.icon, this.label);

  final String icon;
  final String label;
}
