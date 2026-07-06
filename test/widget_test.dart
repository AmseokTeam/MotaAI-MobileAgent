import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:milo_ai/app/app.dart';

void main() {
  testWidgets('Mota shows agreement dialog on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiloAiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('用户协议与隐私协议说明'), findsOneWidget);

    await tester.tap(find.text('不同意'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('需要同意用户协议与隐私协议后才能继续使用 Mota。'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '同意并继续'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('用户协议与隐私协议说明'), findsNothing);
  });

  testWidgets('Mota app starts on the portrait chat page after agreement',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'hasAcceptedUserAgreement': true,
      'agreementVersion': '2026-07-01',
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MiloAiApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('用户协议与隐私协议说明'), findsNothing);
    expect(find.text('你想和Mota聊些什么？'), findsOneWidget);
    expect(find.text('输入你想说的话'), findsOneWidget);
    expect(find.text('对话'), findsOneWidget);
    expect(find.text('创意工坊'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('Move'), findsNothing);
    expect(find.text('BT'), findsNothing);
  });
}
