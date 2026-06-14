import 'package:flutter_test/flutter_test.dart';

import 'package:milo_ai/app/app.dart';

void main() {
  testWidgets('Milo app starts on the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MiloAiApp());

    expect(find.text('Mota AI'), findsOneWidget);
    expect(find.text('和Mota语音对话'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Set'), findsOneWidget);
    expect(find.text('Move'), findsNothing);
    expect(find.text('BT'), findsNothing);
  });
}
