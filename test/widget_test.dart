import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/main.dart';

void main() {
  testWidgets('Home screen renders welcome text and opens navigation drawer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Habisin'), findsOneWidget);
    expect(find.text('Selamat Datang!'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    final drawer = find.byType(Drawer);
    expect(drawer, findsOneWidget);
    expect(
      find.descendant(of: drawer, matching: find.text('Home')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: drawer, matching: find.text('Saved Meals')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: drawer, matching: find.text('History')),
      findsOneWidget,
    );
  });
}
