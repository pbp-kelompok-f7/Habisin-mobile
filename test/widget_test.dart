import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/main.dart';

void main() {
  testWidgets('Home screen renders welcome text and opens navigation drawer', (
    WidgetTester tester,
  ) async {
  testWidgets('Plan breakfast, browse another week, then change and remove it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 950));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> tap(Finder target) async {
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const MyApp());
    await tap(find.text('Buka Meals Planner'));
    await tap(find.text('Sen'));
    await tap(find.byTooltip('Tambah Sarapan'));

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
    await tester.enterText(find.byType(TextField), 'bayam');
    await tester.pumpAndSettle();
    expect(find.text('Sup Ayam Wortel Kentang'), findsNothing);
    await tap(find.text('Omelet Bayam Keju'));
    expect(find.text('Omelet Bayam Keju'), findsOneWidget);
    expect(find.text('1 dari 21'), findsOneWidget);
    expect(find.text('bayam'), findsOneWidget);

    await tap(find.byTooltip('Minggu berikutnya'));
    expect(find.text('0 dari 21'), findsOneWidget);
    expect(find.text('Omelet Bayam Keju'), findsNothing);
    await tap(find.byTooltip('Minggu sebelumnya'));
    await tap(find.text('Sen'));
    expect(find.text('Omelet Bayam Keju'), findsOneWidget);

    await tap(find.byTooltip('Ganti Sarapan'));
    await tap(find.text('Nasi Goreng Sisa Sayur'));
    expect(find.text('Nasi Goreng Sisa Sayur'), findsOneWidget);
    expect(find.text('1 dari 21'), findsOneWidget);
    expect(find.text('bayam'), findsNothing);
    await tap(find.byTooltip('Hapus Sarapan'));
    expect(find.byTooltip('Tambah Sarapan'), findsOneWidget);
    expect(find.text('0 dari 21'), findsOneWidget);
    expect(find.text('Nasi Goreng Sisa Sayur'), findsNothing);
  });
}
