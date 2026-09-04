// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luach_chanoch/main.dart';

void main() {
  testWidgets('shows the Luach Chanoch onboarding on a first launch', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const EnochDayApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Luach Chanoch'), findsOneWidget);
  });
}
