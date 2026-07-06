import 'dart:typed_data';

enum AppMenuPanel {
  profile,
  privacy,
}

class MenuProfileState {
  const MenuProfileState({
    required this.nickname,
    required this.avatarEmoji,
    this.bio = '我的机器人伙伴',
    this.preferenceTags = const ['安静陪伴'],
    this.avatarImageBytes,
  });

  final String nickname;
  final String avatarEmoji;
  final String bio;
  final List<String> preferenceTags;
  final Uint8List? avatarImageBytes;

  MenuProfileState copyWith({
    String? nickname,
    String? avatarEmoji,
    String? bio,
    List<String>? preferenceTags,
    Uint8List? avatarImageBytes,
    bool clearAvatarImage = false,
  }) {
    return MenuProfileState(
      nickname: nickname ?? this.nickname,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      bio: bio ?? this.bio,
      preferenceTags: preferenceTags ?? this.preferenceTags,
      avatarImageBytes:
          clearAvatarImage ? null : avatarImageBytes ?? this.avatarImageBytes,
    );
  }
}
