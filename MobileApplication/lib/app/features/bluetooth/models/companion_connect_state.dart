// 文件作用：定义机器人连接状态，并提供与原 Kotlin 项目一致的中文状态文案。

enum CompanionConnectState {
  disconnected,
  scanning,
  connected,
}

String statusText(CompanionConnectState connectState) {
  return switch (connectState) {
    CompanionConnectState.disconnected => '未连接',
    CompanionConnectState.scanning => '扫描中',
    CompanionConnectState.connected => '已连接',
  };
}
