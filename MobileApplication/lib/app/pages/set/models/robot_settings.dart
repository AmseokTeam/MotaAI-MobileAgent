class RobotSettings {
  const RobotSettings({
    this.autoReconnect = true,
    this.hapticFeedback = true,
    this.faceAnimation = true,
    this.localAsrEnabled = false,
  });

  final bool autoReconnect;
  final bool hapticFeedback;
  final bool faceAnimation;
  final bool localAsrEnabled;

  RobotSettings copyWith({
    bool? autoReconnect,
    bool? hapticFeedback,
    bool? faceAnimation,
    bool? localAsrEnabled,
  }) {
    return RobotSettings(
      autoReconnect: autoReconnect ?? this.autoReconnect,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      faceAnimation: faceAnimation ?? this.faceAnimation,
      localAsrEnabled: localAsrEnabled ?? this.localAsrEnabled,
    );
  }
}
