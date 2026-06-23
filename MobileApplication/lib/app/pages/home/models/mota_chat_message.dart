// 文件作用：定义 Mota 文本对话中的消息数据结构。

class MotaChatMessage {
  const MotaChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final MotaChatSender sender;
  final String text;
  final DateTime createdAt;

  bool get isUser => sender == MotaChatSender.user;
}

enum MotaChatSender { user, assistant }
