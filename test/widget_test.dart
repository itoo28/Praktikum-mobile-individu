import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:praktikum7_bertahap/main.dart';

void main() {
  testWidgets('Menampilkan data mahasiswa beserta IPK dan dapat menambah data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MahasiswaApp());

    expect(find.text('Praktikum 7: Data Mahasiswa'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('IPK 3.50'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('IPK 4.00'), findsOneWidget);

    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'NIM'), '2026003');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nama'), 'Budi');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Prodi'),
      'Sistem Informasi',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'IPK'), '3.75');

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('IPK 3.75'), findsOneWidget);
    expect(find.text('Data tersimpan: 3'), findsOneWidget);
  });
}
