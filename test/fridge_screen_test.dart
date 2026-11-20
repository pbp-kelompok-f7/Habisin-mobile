import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:habisin_mobile/features/fridge/screens/fridge_screen.dart';
import 'package:habisin_mobile/features/auth/services/auth_service.dart';
import 'package:habisin_mobile/features/fridge/models/fridge_item.dart';

Widget wrap(Widget child) => MaterialApp(home: child);

Future<void> addItem(WidgetTester tester, String name,
    {String qty = '1'}) async {
  final fab = find.byType(FloatingActionButton);
  if (fab.evaluate().isNotEmpty) {
    await tester.tap(fab);
  } else {
    await tester.tap(find.text('Add your first item'));
  }
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Nama bahan'), name);
  await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), qty);
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AuthService.instance.token = null;
    AuthService.instance.profile = null;
  });

  group('FridgeScreen', () {
    testWidgets('menampilkan empty state saat belum ada item',
        (tester) async {
      await tester.pumpWidget(wrap(const FridgeScreen()));

      expect(find.text('My Fridge'), findsOneWidget);
      expect(find.textContaining('No items in'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('avatar menampilkan "?" jika belum login', (tester) async {
      await tester.pumpWidget(wrap(const FridgeScreen()));
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('avatar menampilkan huruf pertama email', (tester) async {
      AuthService.instance.profile = {'email': 'adit@example.com'};
      await tester.pumpWidget(wrap(const FridgeScreen()));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('bisa menambah item lewat bottom sheet', (tester) async {
      await tester.pumpWidget(wrap(const FridgeScreen()));

      await addItem(tester, 'Susu', qty: '2');

      expect(find.text('Susu'), findsOneWidget);
      expect(find.text('2 pcs'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('pencarian memfilter item', (tester) async {
      await tester.pumpWidget(wrap(const FridgeScreen()));
      await addItem(tester, 'Susu');
      await addItem(tester, 'Telur');

      await tester.enterText(find.byType(TextField).first, 'tel');
      await tester.pump();

      expect(find.text('Telur'), findsOneWidget);
      expect(find.text('Susu'), findsNothing);

      await tester.enterText(find.byType(TextField).first, 'xyz');
      await tester.pump();
      expect(find.text('No matching items.'), findsOneWidget);
    });

    testWidgets('swipe ke kiri menghapus item', (tester) async {
      await tester.pumpWidget(wrap(const FridgeScreen()));
      await addItem(tester, 'Susu');

      await tester.drag(find.text('Susu'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Susu'), findsNothing);
    });
  });

  group('AddItemSheet validasi', () {
    testWidgets('nama kosong ditolak', (tester) async {
      await tester.pumpWidget(
          wrap(const Scaffold(body: AddItemSheet(space: FridgeSpace.fridge))));

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
    });

    testWidgets('jumlah 0 atau bukan angka ditolak', (tester) async {
      await tester.pumpWidget(
          wrap(const Scaffold(body: AddItemSheet(space: FridgeSpace.fridge))));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama bahan'), 'Apel');
      await tester.enterText(find.widgetWithText(TextFormField, 'Jumlah'), '0');
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Angka > 0'), findsOneWidget);
    });
  });
}