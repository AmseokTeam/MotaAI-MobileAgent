import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/app.dart';

void main() {
  testWidgets('Milo app starts on the portrait chat page',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiloAiApp());

    expect(find.text('你想和Mota聊些什么？'), findsOneWidget);
    expect(find.text('输入你想说的话'), findsOneWidget);
    expect(find.text('对话'), findsOneWidget);
    expect(find.text('插件社区'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('Move'), findsNothing);
    expect(find.text('BT'), findsNothing);
  });
}
