// 文件作用：管理 MotaLink Agent 的连接状态、聊天会话和项目文件能力。

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
  Completer<void>? _sessionCreationCompleter;
  _BridgeChatRequest? _activeChatRequest;
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

  Future<bool> connect() async {
    await loadSettings();
    if (!_settings.canConnect) {
      _setError('请填写 PC 地址、端口和连接 Token');
      return false;
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
      await client.ready.timeout(const Duration(seconds: 8));
      _connectionState = PcBridgeConnectionState.connected;
      _appendTerminalLine('已连接 MotaLink Agent\n');
      notifyListeners();
      return true;
    } catch (_) {
      await _messageSubscription?.cancel();
      _messageSubscription = null;
      await _client?.close();
      _client = null;
      _connectionState = PcBridgeConnectionState.disconnected;
      _setError('MotaLink Agent 连接失败');
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _failSessionCreation('MotaLink Agent 已断开连接');
    _failActiveChat('MotaLink Agent 已断开连接');
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

  Future<void> streamChatPrompt({
    required String prompt,
    required ValueChanged<String> onText,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return;
    }

    if (_activeChatRequest != null) {
      throw const PcBridgeChatException('个人电脑 AI Agent 正在回复，请稍后再试');
    }

    if (!isConnected) {
      final connected = await connect();
      if (!connected) {
        throw PcBridgeChatException(errorText ?? '个人电脑 AI Agent 连接失败');
      }
    }

    await _ensureChatSession();
    final client = _client;
    final sessionId = _sessionId;
    if (client == null || sessionId == null) {
      throw const PcBridgeChatException('请先连接个人电脑 AI Agent');
    }

    final request = _BridgeChatRequest(
      prompt: trimmedPrompt,
      onText: onText,
    );
    _activeChatRequest = request;
    client.sendInput(sessionId: sessionId, text: '$trimmedPrompt\n');

    try {
      await request.done;
    } finally {
      if (_activeChatRequest == request) {
        _activeChatRequest = null;
      }
      request.dispose();
    }
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

  Future<void> _ensureChatSession() async {
    if (_sessionId != null) {
      return;
    }

    final pendingCompleter = _sessionCreationCompleter;
    if (pendingCompleter != null) {
      await pendingCompleter.future.timeout(const Duration(seconds: 12));
      return;
    }

    final client = _client;
    if (client == null || !isConnected) {
      throw const PcBridgeChatException('请先连接个人电脑 AI Agent');
    }
    if (!_settings.canCreateSession) {
      throw const PcBridgeChatException('个人电脑 AI Agent 会话配置不完整');
    }

    final completer = Completer<void>();
    _sessionCreationCompleter = completer;
    _creatingSession = true;
    _clearError();
    notifyListeners();
    client.createSession(
      requestId: _createRequestId(),
      cli: _settings.cli.trim(),
      cwd: _settings.cwd.trim(),
      cols: 100,
      rows: 30,
    );

    try {
      await completer.future.timeout(const Duration(seconds: 12));
    } on TimeoutException {
      _sessionCreationCompleter = null;
      _creatingSession = false;
      _setError('个人电脑 AI Agent 启动聊天超时');
      throw const PcBridgeChatException('个人电脑 AI Agent 启动聊天超时');
    }
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
        _sessionCreationCompleter?.complete();
        _sessionCreationCompleter = null;
        _appendTerminalLine('已创建 ${_settings.cli} 会话\n');
      case 'session.output':
        _appendTerminalLine(message.text ?? '');
        _activeChatRequest?.append(message.text ?? '');
      case 'session.exit':
        _appendTerminalLine('会话已退出，退出码 ${message.exitCode ?? 0}\n');
        _sessionId = null;
        _creatingSession = false;
        _activeChatRequest?.finish();
      case 'project.list.result':
        _handleProjectListing(message);
      case 'project.readFile.result':
        _handleProjectFile(message);
      case 'project.gitDiff.result':
        _handleProjectDiff(message);
      case 'error':
        if (!_handleProjectError(message)) {
          final errorMessage = message.message ?? 'MotaLink Agent 返回错误';
          _creatingSession = false;
          _failSessionCreation(errorMessage);
          _failActiveChat(errorMessage);
          _setError(errorMessage);
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
    _failSessionCreation(message ?? 'MotaLink Agent 已断开连接');
    _failActiveChat(message ?? 'MotaLink Agent 已断开连接');
    _clearProjectLoadingState();
    if (message != null) {
      _errorText = message;
      _appendTerminalLine('$message\n');
    }
    notifyListeners();
  }

  void _failSessionCreation(String message) {
    final completer = _sessionCreationCompleter;
    _sessionCreationCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(PcBridgeChatException(message));
    }
  }

  void _failActiveChat(String message) {
    final request = _activeChatRequest;
    _activeChatRequest = null;
    request?.fail(PcBridgeChatException(message));
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
    _failSessionCreation('MotaLink Agent 已关闭');
    _failActiveChat('MotaLink Agent 已关闭');
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

class PcBridgeChatException implements Exception {
  const PcBridgeChatException(this.message);

  final String message;
}

class _BridgeChatRequest {
  _BridgeChatRequest({
    required this.prompt,
    required this.onText,
  }) {
    _overallTimer = Timer(
      const Duration(seconds: 90),
      () => fail(const PcBridgeChatException('个人电脑 AI Agent 响应超时')),
    );
  }

  final String prompt;
  final ValueChanged<String> onText;
  final StringBuffer _buffer = StringBuffer();
  final Completer<void> _completer = Completer<void>();
  Timer? _idleTimer;
  Timer? _overallTimer;

  Future<void> get done => _completer.future;

  void append(String text) {
    if (_completer.isCompleted || text.isEmpty) {
      return;
    }

    _buffer.write(text);
    final displayText = _displayText;
    if (displayText != null && displayText.trim().isNotEmpty) {
      onText(displayText);
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 2200), finish);
  }

  void finish() {
    if (_completer.isCompleted) {
      return;
    }

    _completer.complete();
    dispose();
  }

  void fail(Object error) {
    if (_completer.isCompleted) {
      return;
    }

    _completer.completeError(error);
    dispose();
  }

  void dispose() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _overallTimer?.cancel();
    _overallTimer = null;
  }

  String? get _displayText {
    final text = _stripPromptEcho(
      output: _buffer.toString(),
      prompt: prompt,
    );
    return text?.trimRight();
  }
}

String? _stripPromptEcho({
  required String output,
  required String prompt,
}) {
  final sanitizedOutput = _sanitizeTerminalText(output).trimLeft();
  final sanitizedPrompt = _sanitizeTerminalText(prompt).trim();
  if (sanitizedPrompt.isEmpty) {
    return sanitizedOutput;
  }

  final promptIndex = sanitizedOutput.indexOf(sanitizedPrompt);
  if (promptIndex == -1) {
    return null;
  }

  final replyText =
      sanitizedOutput.substring(promptIndex + sanitizedPrompt.length);
  return _stripLeadingTerminalNoise(replyText, sanitizedPrompt);
}

String _sanitizeTerminalText(String text) {
  return text
      .replaceAll(RegExp(r'\x1B\][\s\S]*?(?:\x07|\x1B\\|$)'), '')
      .replaceAll(RegExp(r'\x1B[P^_][\s\S]*?(?:\x1B\\|$)'), '')
      .replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '')
      .replaceAll(RegExp(r'\x1B[()][A-Za-z0-9]'), '')
      .replaceAll(RegExp(r'\x1B[@-Z\\-_]'), '')
      .replaceAll(RegExp(r'\](?:0|1|2|10|11);[^\n]*'), '')
      .replaceAll('\r', '')
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
}

String _stripLeadingTerminalNoise(String text, String prompt) {
  var value = _dropTerminalNoiseLines(text, prompt);
  for (var i = 0; i < 12; i++) {
    final before = value;
    value = value.trimLeft().replaceFirst(_terminalFramePrefixPattern, '');

    if (prompt.isNotEmpty && value.startsWith(prompt)) {
      final afterPrompt = value.substring(prompt.length).trimLeft();
      if (afterPrompt.isEmpty ||
          afterPrompt.startsWith(prompt) ||
          _startsWithTerminalNoise(afterPrompt)) {
        value = afterPrompt;
        continue;
      }
    }

    final noiseMatch = _matchLeadingTerminalNoise(value);
    if (noiseMatch != null) {
      value = value.substring(noiseMatch.end);
      continue;
    }

    if (before == value) {
      break;
    }
  }
  return _dropTerminalNoiseLines(value, prompt).trimLeft();
}

String _dropTerminalNoiseLines(String text, String prompt) {
  return text
      .split('\n')
      .where((line) => !_isTerminalNoiseLine(line, prompt))
      .join('\n');
}

bool _isTerminalNoiseLine(String line, String prompt) {
  final trimmedLine = line.trim();
  if (trimmedLine.isEmpty) {
    return false;
  }
  if (prompt.isNotEmpty && trimmedLine == prompt) {
    return true;
  }
  if (prompt.isNotEmpty && trimmedLine.startsWith(prompt)) {
    final afterPrompt = trimmedLine.substring(prompt.length).trimLeft();
    if (afterPrompt.isEmpty || _startsWithTerminalNoise(afterPrompt)) {
      return true;
    }
  }
  return _terminalNoiseLinePatterns.any((pattern) {
    return pattern.hasMatch(trimmedLine);
  });
}

bool _startsWithTerminalNoise(String text) {
  return _matchLeadingTerminalNoise(text.trimLeft()) != null;
}

RegExpMatch? _matchLeadingTerminalNoise(String text) {
  for (final pattern in _leadingTerminalNoisePatterns) {
    final match = pattern.firstMatch(text);
    if (match != null) {
      return match;
    }
  }
  return null;
}

final RegExp _terminalFramePrefixPattern = RegExp(
  '^[\\s\\|>_\\u2500-\\u257F]+',
);

final List<RegExp> _leadingTerminalNoisePatterns = <RegExp>[
  RegExp(r'^[^A-Za-z0-9]*Update available[\s\S]*?(?:Press enter to continue|$)',
      caseSensitive: false),
  RegExp(r'^Run npm install[\s\S]*?(?:release notes:|$)', caseSensitive: false),
  RegExp(r'^(?:OpenAI Codex|\(v[\d.]+\)|model:\s*|directory:\s*)[^\n]*',
      caseSensitive: false),
  RegExp(
      '^(?:gpt[-\\w.]*\\s*(?:low|medium|high)?\\s*[\\u00B7\\u2022]\\s*~?[^\\n]*)',
      caseSensitive: false),
  RegExp(r'^[^A-Za-z0-9]*MCP startup incomplete[^\n]*', caseSensitive: false),
  RegExp(r'^Starting MCP servers(?:\s*\([^)]+\))?:?[^\n]*',
      caseSensitive: false),
];

final List<RegExp> _terminalNoiseLinePatterns = <RegExp>[
  RegExp(r'^[^A-Za-z0-9]*Update available', caseSensitive: false),
  RegExp(r'^(?:Release notes:|Press enter to continue|Run npm install)',
      caseSensitive: false),
  RegExp(r'^(?:OpenAI Codex|\(v[\d.]+\)|model:|directory:)',
      caseSensitive: false),
  RegExp('^gpt[-\\w.]*\\s*(?:low|medium|high)?\\s*[\\u00B7\\u2022]\\s*~?',
      caseSensitive: false),
  RegExp(r'^[^A-Za-z0-9]*MCP startup incomplete', caseSensitive: false),
  RegExp(r'^Starting MCP servers', caseSensitive: false),
  RegExp(r'^\(\d+/\d+\):', caseSensitive: false),
];
