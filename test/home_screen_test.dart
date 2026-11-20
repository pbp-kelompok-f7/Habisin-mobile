import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen menampilkan judul dan kartu fitur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyHomePage()));

    expect(find.text('Habisin'), findsOneWidget);
    expect(find.text('Community Reviews'), findsOneWidget);
    expect(find.text('Saved Meals & History'), findsOneWidget);
  });
}
