import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/main.dart';

void main() {
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
    expect(find.text('Habisin'), findsOneWidget);
    await tap(find.text('Planner'));
    expect(find.byType(BackButton), findsNothing);
    await tap(find.text('Sen'));
    await tap(find.byTooltip('Tambah Sarapan'));
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

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
