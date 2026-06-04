// 文件作用：定义机器人移动指令，保持与 Kotlin 项目的按钮顺序和中文文案一致。

enum CompanionMoveCommand {
  comeHere('到我旁边'),
  forward('前进'),
  backward('后退'),
  left('左转'),
  right('右转'),
  stop('停止');

  const CompanionMoveCommand(this.title);

  final String title;
}
