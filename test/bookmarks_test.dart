import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habisin_mobile/features/bookmarks/models/bookmarks_store.dart';
import 'package:habisin_mobile/main.dart';

void main() {
  test('category names must be filled, short and unique', () {
    final store = BookmarksStore.sample();
    final breakfast = store.categories[1];

    expect(store.validateName('   '), isNotNull);
    expect(store.validateName('x' * 41), isNotNull);
    expect(store.validateName('sarapan'), isNotNull);
    expect(store.validateName(' Sarapan ', editing: breakfast), isNull);
    expect(store.validateName('Makan malam'), isNull);

    final dinner = store.create('  Makan malam ');
    expect(dinner.name, 'Makan malam');
    store.rename(dinner, 'Camilan');
    expect(store.categories.last.name, 'Camilan');
    store.delete(dinner);
    expect(store.categories.map((c) => c.name), isNot(contains('Camilan')));
  });

  testWidgets('Manage bookmark categories and recipes from the Bookmarks tab', (
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
    await tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Bookmarks'),
      ),
    );
    expect(find.text('2 resep tersimpan'), findsOneWidget);
    expect(find.text('Sup Ayam Wortel Kentang'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nasi');
    await tester.pumpAndSettle();
    expect(find.text('Sup Ayam Wortel Kentang'), findsNothing);
    expect(find.text('Nasi Goreng Sisa Sayur'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'durian');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada resep yang cocok.'), findsOneWidget);
    await tap(find.text('Tampilkan semua resep'));

    await tap(
      find.byTooltip('Hapus Sup Ayam Wortel Kentang dari Siap dimasak'),
    );
    expect(find.text('1 resep tersimpan'), findsOneWidget);
    await tap(find.text('Urungkan'));
    expect(find.text('2 resep tersimpan'), findsOneWidget);

    await tap(find.text('Sarapan'));
    expect(find.text('Omelet Bayam Keju'), findsOneWidget);
    expect(find.text('Sup Ayam Wortel Kentang'), findsNothing);

    await tap(find.text('Baru'));
    await tester.enterText(find.byType(TextField).last, 'sarapan');
    await tap(find.text('Simpan'));
    expect(find.text('Kategori "sarapan" sudah ada.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Camilan');
    await tap(find.text('Simpan'));
    expect(find.text('Belum ada resep di kategori ini.'), findsOneWidget);

    await tap(find.byTooltip('Ganti nama kategori'));
    await tester.enterText(find.byType(TextField).last, 'Camilan sore');
    await tap(find.text('Simpan'));
    expect(find.text('Camilan sore'), findsWidgets);

    await tap(find.byTooltip('Hapus kategori'));
    await tap(find.widgetWithText(FilledButton, 'Hapus'));
    expect(find.text('Camilan sore'), findsNothing);
    expect(find.text('2 resep tersimpan'), findsOneWidget);
  });
}
