// 文件作用：定义 Mota 与 MotaLink Agent 之间的 WebSocket JSON 协议消息。

import 'dart:convert';

import 'project_bridge_models.dart';

class PcBridgeMessage {
  const PcBridgeMessage({
    required this.type,
    this.requestId,
    this.sessionId,
    this.text,
    this.code,
    this.message,
    this.exitCode,
    this.projectListing,
    this.projectFile,
    this.projectDiff,
  });

  factory PcBridgeMessage.fromJsonText(String text) {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Bridge message is not an object');
    }

    final type = decoded['type'];
    if (type is! String || type.trim().isEmpty) {
      throw const FormatException('Bridge message type is invalid');
    }

    final messageJson = Map<String, dynamic>.from(decoded);
    return PcBridgeMessage(
      type: type,
      requestId: _readString(decoded['requestId']),
      sessionId: _readString(decoded['sessionId']),
      text: _readString(decoded['text'], allowEmpty: true),
      code: _readString(decoded['code']),
      message: _readString(decoded['message']),
      exitCode: _readInt(decoded['exitCode']),
      projectListing: type == 'project.list.result'
          ? ProjectDirectoryListing.fromJson(messageJson)
          : null,
      projectFile: type == 'project.readFile.result'
          ? ProjectFileContent.fromJson(messageJson)
          : null,
      projectDiff: type == 'project.gitDiff.result'
          ? _readString(decoded['diff'], allowEmpty: true) ?? ''
          : null,
    );
  }

  final String type;
  final String? requestId;
  final String? sessionId;
  final String? text;
  final String? code;
  final String? message;
  final int? exitCode;
  final ProjectDirectoryListing? projectListing;
  final ProjectFileContent? projectFile;
  final String? projectDiff;
}

String encodePcBridgeMessage(Map<String, Object?> message) {
  return jsonEncode(
    Map<String, Object?>.fromEntries(
      message.entries.where((entry) => entry.value != null),
    ),
  );
}

String? _readString(Object? value, {bool allowEmpty = false}) {
  if (value is String && (allowEmpty || value.trim().isNotEmpty)) {
    return value;
  }
  return null;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return null;
}
