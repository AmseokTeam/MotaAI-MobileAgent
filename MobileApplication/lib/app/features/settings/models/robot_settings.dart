// 文件作用：定义设置页的偏好状态，避免开关状态散落在页面内部。

class RobotSettings {
  const RobotSettings({
    this.autoReconnect = true,
    this.hapticFeedback = true,
    this.faceAnimation = true,
  });

  final bool autoReconnect;
  final bool hapticFeedback;
  final bool faceAnimation;

  RobotSettings copyWith({
    bool? autoReconnect,
    bool? hapticFeedback,
    bool? faceAnimation,
  }) {
    return RobotSettings(
      autoReconnect: autoReconnect ?? this.autoReconnect,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      faceAnimation: faceAnimation ?? this.faceAnimation,
    );
  }
}
