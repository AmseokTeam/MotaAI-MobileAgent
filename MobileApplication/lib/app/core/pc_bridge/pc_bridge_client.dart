// 文件作用：封装 MotaLink Agent 的 WebSocket 连接和基础协议发送。

import 'dart:async';

import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pc_bridge_message.dart';
import 'pc_bridge_settings_store.dart';

class PcBridgeClient {
  PcBridgeClient._(this._channel);

  factory PcBridgeClient.connect(PcBridgeSettings settings) {
    return PcBridgeClient._(WebSocketChannel.connect(settings.webSocketUri));
  }

  final WebSocketChannel _channel;

  Stream<PcBridgeMessage> get messages {
    return _channel.stream.map((event) {
      if (event is String) {
        return PcBridgeMessage.fromJsonText(event);
      }
      throw const FormatException('Bridge message is not text');
    });
  }

  void createSession({
    required String requestId,
    required String cli,
    required String cwd,
    required int cols,
    required int rows,
  }) {
    _send(<String, Object?>{
      'type': 'session.create',
      'requestId': requestId,
      'cli': cli,
      'cwd': cwd,
      'cols': cols,
      'rows': rows,
    });
  }

  void sendInput({
    required String sessionId,
    required String text,
  }) {
    _send(<String, Object?>{
      'type': 'session.input',
      'sessionId': sessionId,
      'text': text,
    });
  }

  void sendSignal({
    required String sessionId,
    required String signal,
  }) {
    _send(<String, Object?>{
      'type': 'session.signal',
      'sessionId': sessionId,
      'signal': signal,
    });
  }

  void resize({
    required String sessionId,
    required int cols,
    required int rows,
  }) {
    _send(<String, Object?>{
      'type': 'session.resize',
      'sessionId': sessionId,
      'cols': cols,
      'rows': rows,
    });
  }

  void listProject({
    required String requestId,
    required String path,
  }) {
    _send(<String, Object?>{
      'type': 'project.list',
      'requestId': requestId,
      'path': path,
    });
  }

  void readProjectFile({
    required String requestId,
    required String path,
  }) {
    _send(<String, Object?>{
      'type': 'project.readFile',
      'requestId': requestId,
      'path': path,
    });
  }

  void readGitDiff({
    required String requestId,
  }) {
    _send(<String, Object?>{
      'type': 'project.gitDiff',
      'requestId': requestId,
    });
  }

  Future<void> close() {
    return _channel.sink.close(ws_status.normalClosure);
  }

  void _send(Map<String, Object?> message) {
    _channel.sink.add(encodePcBridgeMessage(message));
  }
}
