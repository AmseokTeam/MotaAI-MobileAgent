// 文件作用：保存 MotaLink Agent 的连接配置，并把访问 token 放入系统安全存储。

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PcBridgeSettings {
  const PcBridgeSettings({
    required this.host,
    required this.port,
    required this.token,
    required this.cli,
    required this.cwd,
  });

  factory PcBridgeSettings.defaults() {
    return const PcBridgeSettings(
      host: '192.168.1.23',
      port: 8765,
      token: '',
      cli: 'codex',
      cwd: '/Users/jhb/Desktop/Mota',
    );
  }

  final String host;
  final int port;
  final String token;
  final String cli;
  final String cwd;

  bool get canConnect =>
      host.trim().isNotEmpty && port > 0 && token.trim().isNotEmpty;

  bool get canCreateSession => canConnect && cli.trim().isNotEmpty;

  Uri get webSocketUri {
    return Uri(
      scheme: 'ws',
      host: host.trim(),
      port: port,
      path: '/ws',
      queryParameters: <String, String>{'token': token.trim()},
    );
  }

  PcBridgeSettings copyWith({
    String? host,
    int? port,
    String? token,
    String? cli,
    String? cwd,
  }) {
    return PcBridgeSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      token: token ?? this.token,
      cli: cli ?? this.cli,
      cwd: cwd ?? this.cwd,
    );
  }
}

class PcBridgeSettingsStore {
  PcBridgeSettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage;

  static const String _hostKey = 'pc_bridge_host';
  static const String _portKey = 'pc_bridge_port';
  static const String _tokenKey = 'pc_bridge_token';
  static const String _cliKey = 'pc_bridge_cli';
  static const String _cwdKey = 'pc_bridge_cwd';

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  Future<PcBridgeSettings> readSettings() async {
    final defaults = PcBridgeSettings.defaults();
    final rawPort = await _storage.read(key: _portKey);
    final port = int.tryParse(rawPort ?? '') ?? defaults.port;

    return PcBridgeSettings(
      host: await _storage.read(key: _hostKey) ?? defaults.host,
      port: port,
      token: await _storage.read(key: _tokenKey) ?? defaults.token,
      cli: await _storage.read(key: _cliKey) ?? defaults.cli,
      cwd: await _storage.read(key: _cwdKey) ?? defaults.cwd,
    );
  }

  Future<void> writeSettings(PcBridgeSettings settings) {
    return Future.wait<void>([
      _storage.write(key: _hostKey, value: settings.host.trim()),
      _storage.write(key: _portKey, value: settings.port.toString()),
      _storage.write(key: _tokenKey, value: settings.token.trim()),
      _storage.write(key: _cliKey, value: settings.cli.trim()),
      _storage.write(key: _cwdKey, value: settings.cwd.trim()),
    ]);
  }
}
