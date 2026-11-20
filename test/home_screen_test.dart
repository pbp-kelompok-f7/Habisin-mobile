import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:habisin_mobile/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen menampilkan judul dan tombol planner',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyHomePage()));

    expect(find.text('Habisin'), findsOneWidget);
    expect(find.text('Meals Planner'), findsOneWidget);
    expect(find.text('Buka Meals Planner'), findsOneWidget);
  });
}