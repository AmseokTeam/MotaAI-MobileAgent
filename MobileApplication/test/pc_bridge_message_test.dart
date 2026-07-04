import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/core/pc_bridge/pc_bridge_message.dart';

void main() {
  test('PcBridgeMessage parses project list result', () {
    final message = PcBridgeMessage.fromJsonText('''
{
  "type": "project.list.result",
  "requestId": "req_1",
  "path": ".",
  "entries": [
    {"name": "lib", "path": "lib", "type": "directory"},
    {"name": "pubspec.yaml", "path": "pubspec.yaml", "type": "file", "size": 42}
  ]
}
''');

    expect(message.type, 'project.list.result');
    expect(message.requestId, 'req_1');
    expect(message.projectListing?.path, '.');
    expect(message.projectListing?.entries, hasLength(2));
    expect(message.projectListing?.entries.first.name, 'lib');
  });

  test('PcBridgeMessage parses project file result', () {
    final message = PcBridgeMessage.fromJsonText('''
{
  "type": "project.readFile.result",
  "requestId": "req_2",
  "path": "lib/main.dart",
  "content": "void main() {}",
  "language": "dart",
  "truncated": true
}
''');

    expect(message.projectFile?.path, 'lib/main.dart');
    expect(message.projectFile?.content, 'void main() {}');
    expect(message.projectFile?.language, 'dart');
    expect(message.projectFile?.truncated, isTrue);
  });

  test('PcBridgeMessage parses empty project git diff and request errors', () {
    final diffMessage = PcBridgeMessage.fromJsonText(
      '{"type":"project.gitDiff.result","requestId":"req_3","diff":""}',
    );
    final errorMessage = PcBridgeMessage.fromJsonText(
      '{"type":"error","requestId":"req_4","message":"读取失败"}',
    );

    expect(diffMessage.projectDiff, '');
    expect(errorMessage.requestId, 'req_4');
    expect(errorMessage.message, '读取失败');
  });
}
