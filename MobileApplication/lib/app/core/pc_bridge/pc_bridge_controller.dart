// 文件作用：管理 MotaLink Agent 的连接状态、CLI 会话和终端输出。

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'pc_bridge_client.dart';
import 'pc_bridge_message.dart';
import 'pc_bridge_settings_store.dart';
import 'project_bridge_models.dart';

enum PcBridgeConnectionState {
  disconnected,
  connecting,
  connected,
}

class PcBridgeController extends ChangeNotifier {
  PcBridgeController({
    PcBridgeSettingsStore? settingsStore,
  }) : _settingsStore = settingsStore ?? PcBridgeSettingsStore();

  final PcBridgeSettingsStore _settingsStore;
  PcBridgeSettings _settings = PcBridgeSettings.defaults();
  final List<String> _terminalLines = <String>[];
  final Map<String, List<ProjectEntry>> _projectEntriesByPath =
      <String, List<ProjectEntry>>{};
  final Set<String> _expandedProjectPaths = <String>{};
  final Set<String> _loadingProjectPaths = <String>{};
  final Map<String, _ProjectRequest> _projectRequests =
      <String, _ProjectRequest>{};

  PcBridgeClient? _client;
  StreamSubscription<PcBridgeMessage>? _messageSubscription;
  PcBridgeConnectionState _connectionState =
      PcBridgeConnectionState.disconnected;
  String? _sessionId;
  String? _errorText;
  ProjectFileContent? _selectedProjectFile;
  String? _projectDiff;
  String? _projectErrorText;
  bool _settingsLoaded = false;
  bool _creatingSession = false;
  bool _readingProjectFile = false;
  bool _loadingProjectDiff = false;

  PcBridgeSettings get settings => _settings;
  PcBridgeConnectionState get connectionState => _connectionState;
  String? get sessionId => _sessionId;
  String? get errorText => _errorText;
  bool get settingsLoaded => _settingsLoaded;
  bool get creatingSession => _creatingSession;
  bool get isConnected => _connectionState == PcBridgeConnectionState.connected;
  bool get hasSession => _sessionId != null;
  List<String> get terminalLines => List.unmodifiable(_terminalLines);
  Map<String, List<ProjectEntry>> get projectEntriesByPath =>
      Map.unmodifiable(_projectEntriesByPath);
  Set<String> get expandedProjectPaths =>
      Set.unmodifiable(_expandedProjectPaths);
  Set<String> get loadingProjectPaths => Set.unmodifiable(_loadingProjectPaths);
  ProjectFileContent? get selectedProjectFile => _selectedProjectFile;
  String? get projectDiff => _projectDiff;
  String? get projectErrorText => _projectErrorText;
  bool get readingProjectFile => _readingProjectFile;
  bool get loadingProjectDiff => _loadingProjectDiff;

  Future<void> loadSettings() async {
    if (_settingsLoaded) {
      return;
    }

    _settings = await _settingsStore.readSettings();
    _settingsLoaded = true;
    notifyListeners();
  }

  Future<void> saveSettings(PcBridgeSettings settings) async {
    _settings = settings;
    await _settingsStore.writeSettings(settings);
    _settingsLoaded = true;
    _clearError();
    notifyListeners();
  }

  Future<void> connect() async {
    await loadSettings();
    if (!_settings.canConnect) {
      _setError('请填写 PC 地址、端口和连接 Token');
      return;
    }

    await disconnect();
    _connectionState = PcBridgeConnectionState.connecting;
    _clearError();
    notifyListeners();

    try {
      final client = PcBridgeClient.connect(_settings);
      _client = client;
      _messageSubscription = client.messages.listen(
        _handleMessage,
        onError: (_) => _handleDisconnected('MotaLink Agent 连接失败'),
        onDone: () => _handleDisconnected(null),
        cancelOnError: true,
      );
      _connectionState = PcBridgeConnectionState.connected;
      _appendTerminalLine('已连接 MotaLink Agent\n');
    } catch (_) {
      _connectionState = PcBridgeConnectionState.disconnected;
      _setError('MotaLink Agent 连接失败');
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    final client = _client;
    _client = null;
    _sessionId = null;
    _creatingSession = false;
    _connectionState = PcBridgeConnectionState.disconnected;
    _clearProjectLoadingState();
    if (client != null) {
      await client.close();
    }
    notifyListeners();
  }

  void createSession({int cols = 100, int rows = 30}) {
    final client = _client;
    if (client == null || !isConnected) {
      _setError('请先连接 MotaLink Agent');
      return;
    }
    if (!_settings.canCreateSession) {
      _setError('请填写 CLI 和工作目录');
      return;
    }

    _creatingSession = true;
    _clearError();
    notifyListeners();
    client.createSession(
      requestId: _createRequestId(),
      cli: _settings.cli.trim(),
      cwd: _settings.cwd.trim(),
      cols: cols,
      rows: rows,
    );
  }

  void sendInput(String rawText) {
    final text = rawText.trimRight();
    final client = _client;
    final sessionId = _sessionId;
    if (client == null || sessionId == null) {
      _setError('请先创建 CLI 会话');
      return;
    }
    if (text.trim().isEmpty) {
      return;
    }

    client.sendInput(sessionId: sessionId, text: '$text\n');
  }

  void interruptSession() {
    _sendSignal('interrupt');
  }

  void terminateSession() {
    _sendSignal('terminate');
  }

  void clearTerminal() {
    _terminalLines.clear();
    notifyListeners();
  }

  @visibleForTesting
  void debugSetConnectedForProjectTest(PcBridgeSettings settings) {
    _settings = settings;
    _settingsLoaded = true;
    _connectionState = PcBridgeConnectionState.connected;
    notifyListeners();
  }

  @visibleForTesting
  void debugHandleMessage(PcBridgeMessage message) {
    _handleMessage(message);
  }

  void loadProjectRoot() {
    listProjectPath('.');
  }

  void listProjectPath(String path) {
    final client = _client;
    if (client == null || !isConnected) {
      _setProjectError('请先连接 MotaLink Agent');
      return;
    }

    final requestId = _createRequestId();
    _projectRequests[requestId] = _ProjectRequest(
      kind: _ProjectRequestKind.list,
      path: path,
    );
    _loadingProjectPaths.add(path);
    _projectErrorText = null;
    notifyListeners();
    client.listProject(requestId: requestId, path: path);
  }

  void toggleProjectDirectory(ProjectEntry entry) {
    if (!entry.isDirectory) {
      return;
    }

    if (_expandedProjectPaths.contains(entry.path)) {
      _expandedProjectPaths.remove(entry.path);
      notifyListeners();
      return;
    }

    final cachedEntries = _projectEntriesByPath[entry.path];
    if (cachedEntries != null) {
      _expandedProjectPaths.add(entry.path);
      notifyListeners();
      return;
    }

    listProjectPath(entry.path);
  }

  void readProjectFile(ProjectEntry entry) {
    if (entry.isDirectory) {
      toggleProjectDirectory(entry);
      return;
    }

    readProjectFilePath(entry.path);
  }

  void readProjectFilePath(String path) {
    final client = _client;
    if (client == null || !isConnected) {
      _setProjectError('请先连接 MotaLink Agent');
      return;
    }

    final requestId = _createRequestId();
    _projectRequests[requestId] = _ProjectRequest(
      kind: _ProjectRequestKind.readFile,
      path: path,
    );
    _readingProjectFile = true;
    _projectErrorText = null;
    notifyListeners();
    client.readProjectFile(requestId: requestId, path: path);
  }

  void readGitDiff() {
    final client = _client;
    if (client == null || !isConnected) {
      _setProjectError('请先连接 MotaLink Agent');
      return;
    }

    final requestId = _createRequestId();
    _projectRequests[requestId] = const _ProjectRequest(
      kind: _ProjectRequestKind.gitDiff,
    );
    _loadingProjectDiff = true;
    _projectErrorText = null;
    notifyListeners();
    client.readGitDiff(requestId: requestId);
  }

  void _sendSignal(String signal) {
    final client = _client;
    final sessionId = _sessionId;
    if (client == null || sessionId == null) {
      _setError('请先创建 CLI 会话');
      return;
    }
    client.sendSignal(sessionId: sessionId, signal: signal);
  }

  void _handleMessage(PcBridgeMessage message) {
    switch (message.type) {
      case 'session.created':
        _sessionId = message.sessionId;
        _creatingSession = false;
        _appendTerminalLine('已创建 ${_settings.cli} 会话\n');
      case 'session.output':
        _appendTerminalLine(message.text ?? '');
      case 'session.exit':
        _appendTerminalLine('会话已退出，退出码 ${message.exitCode ?? 0}\n');
        _sessionId = null;
        _creatingSession = false;
      case 'project.list.result':
        _handleProjectListing(message);
      case 'project.readFile.result':
        _handleProjectFile(message);
      case 'project.gitDiff.result':
        _handleProjectDiff(message);
      case 'error':
        if (!_handleProjectError(message)) {
          _creatingSession = false;
          _setError(message.message ?? 'MotaLink Agent 返回错误');
        }
      default:
        break;
    }
    notifyListeners();
  }

  void _handleDisconnected(String? message) {
    _connectionState = PcBridgeConnectionState.disconnected;
    _sessionId = null;
    _creatingSession = false;
    _clearProjectLoadingState();
    if (message != null) {
      _errorText = message;
      _appendTerminalLine('$message\n');
    }
    notifyListeners();
  }

  void _appendTerminalLine(String text) {
    if (text.isEmpty) {
      return;
    }

    _terminalLines.add(text);
    if (_terminalLines.length > 220) {
      _terminalLines.removeRange(0, _terminalLines.length - 220);
    }
  }

  void _setError(String message) {
    _errorText = message;
    _appendTerminalLine('$message\n');
    notifyListeners();
  }

  void _clearError() {
    _errorText = null;
  }

  void _handleProjectListing(PcBridgeMessage message) {
    final listing = message.projectListing;
    if (listing == null) {
      _setProjectError('项目目录响应格式无效');
      return;
    }

    final request = _takeProjectRequest(message.requestId);
    if (request?.path != null) {
      _loadingProjectPaths.remove(request!.path);
    }
    _loadingProjectPaths.remove(listing.path);
    _projectEntriesByPath[listing.path] = listing.entries;
    _expandedProjectPaths.add(listing.path);
    _projectErrorText = null;
  }

  void _handleProjectFile(PcBridgeMessage message) {
    final file = message.projectFile;
    if (file == null) {
      _setProjectError('项目文件响应格式无效');
      return;
    }

    _takeProjectRequest(message.requestId);
    _readingProjectFile = false;
    _selectedProjectFile = file;
    _projectErrorText = null;
  }

  void _handleProjectDiff(PcBridgeMessage message) {
    _takeProjectRequest(message.requestId);
    _loadingProjectDiff = false;
    _projectDiff = message.projectDiff ?? '';
    _projectErrorText = null;
  }

  bool _handleProjectError(PcBridgeMessage message) {
    final request = _takeProjectRequest(message.requestId);
    if (request == null) {
      return false;
    }

    switch (request.kind) {
      case _ProjectRequestKind.list:
        if (request.path != null) {
          _loadingProjectPaths.remove(request.path);
        }
      case _ProjectRequestKind.readFile:
        _readingProjectFile = false;
      case _ProjectRequestKind.gitDiff:
        _loadingProjectDiff = false;
    }

    _setProjectError(message.message ?? 'MotaLink Agent 返回错误');
    return true;
  }

  _ProjectRequest? _takeProjectRequest(String? requestId) {
    if (requestId == null) {
      return null;
    }
    return _projectRequests.remove(requestId);
  }

  void _setProjectError(String message) {
    _projectErrorText = message;
    notifyListeners();
  }

  void _clearProjectLoadingState() {
    _loadingProjectPaths.clear();
    _projectRequests.clear();
    _readingProjectFile = false;
    _loadingProjectDiff = false;
  }

  String _createRequestId() {
    return 'req_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _client?.close();
    super.dispose();
  }
}

enum _ProjectRequestKind {
  list,
  readFile,
  gitDiff,
}

class _ProjectRequest {
  const _ProjectRequest({
    required this.kind,
    this.path,
  });

  final _ProjectRequestKind kind;
  final String? path;
}
