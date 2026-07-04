import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/core/pc_bridge/pc_bridge_controller.dart';
import 'package:milo_ai/app/core/pc_bridge/pc_bridge_message.dart';
import 'package:milo_ai/app/core/pc_bridge/pc_bridge_settings_store.dart';
import 'package:milo_ai/app/pages/home/widgets/mota_project_drawer.dart';

void main() {
  testWidgets('project drawer shows disconnected state', (tester) async {
    final controller = PcBridgeController(
      settingsStore: _FakePcBridgeSettingsStore(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_ProjectDrawerHarness(controller: controller));
    await tester.pump();

    expect(find.text('请先连接 PC Bridge'), findsOneWidget);
    expect(find.text('连接 MotaLink Agent 后即可浏览当前工作目录'), findsOneWidget);
  });

  testWidgets('project drawer renders tree, file content, and git diff',
      (tester) async {
    final controller = PcBridgeController(
      settingsStore: _FakePcBridgeSettingsStore(),
    );
    addTearDown(controller.dispose);
    controller.debugSetConnectedForProjectTest(_testSettings);

    await tester.pumpWidget(_ProjectDrawerHarness(controller: controller));
    controller.debugHandleMessage(PcBridgeMessage.fromJsonText('''
{
  "type": "project.list.result",
  "path": ".",
  "entries": [
    {"name": "lib", "path": "lib", "type": "directory"},
    {"name": "pubspec.yaml", "path": "pubspec.yaml", "type": "file", "size": 32}
  ]
}
'''));
    await tester.pump();

    expect(find.text('pubspec.yaml'), findsOneWidget);

    await tester.tap(find.text('pubspec.yaml'));
    controller.debugHandleMessage(PcBridgeMessage.fromJsonText('''
{
  "type": "project.readFile.result",
  "path": "pubspec.yaml",
  "content": "name: milo_ai\\n",
  "language": "yaml",
  "truncated": false
}
'''));
    await tester.pump();

    expect(find.textContaining('/tmp/mota'), findsOneWidget);
    expect(find.textContaining('pubspec.yaml'), findsWidgets);
    expect(find.byTooltip('复制代码'), findsOneWidget);

    await tester.tap(find.text('Diff'));
    await tester.pumpAndSettle();
    controller.debugHandleMessage(PcBridgeMessage.fromJsonText(r'''
{
  "type": "project.gitDiff.result",
  "diff": "diff --git a/lib/main.dart b/lib/main.dart\nindex 1111111..2222222 100644\n--- a/lib/main.dart\n+++ b/lib/main.dart\n@@ -1 +1 @@\n-void oldMain() {}\n+void main() {}\n"
}
'''));
    await tester.pump();

    expect(find.text('lib/main.dart'), findsOneWidget);
    expect(find.text('-void oldMain() {}'), findsOneWidget);
    expect(find.text('+void main() {}'), findsOneWidget);
  });
}

const _testSettings = PcBridgeSettings(
  host: '127.0.0.1',
  port: 8765,
  token: 'test-token',
  cli: 'codex',
  cwd: '/tmp/mota',
);

class _ProjectDrawerHarness extends StatelessWidget {
  const _ProjectDrawerHarness({required this.controller});

  final PcBridgeController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 820,
          child: MotaProjectDrawer(bridgeController: controller),
        ),
      ),
    );
  }
}

class _FakePcBridgeSettingsStore implements PcBridgeSettingsStore {
  PcBridgeSettings _settings = _testSettings;

  @override
  Future<PcBridgeSettings> readSettings() async => _settings;

  @override
  Future<void> writeSettings(PcBridgeSettings settings) async {
    _settings = settings;
  }
}
