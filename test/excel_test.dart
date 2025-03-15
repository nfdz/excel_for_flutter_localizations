import 'dart:io';

import 'package:excel_for_flutter_localizations/excel_for_flutter_localizations.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';
import 'package:test/test.dart';

import 'excel_mock.dart';

void main() {
  late final tempDir = Directory.systemTemp.createTempSync();

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  setUpAll(() {
    configLogger(verbose: true);
  });

  group("readExcelFile", () {
    test('when locale is present', () {
      final excelFile = tempDir.createExcelFile();

      final excel = readExcelFile(excelFile.path);

      expect(excel!.fuzzy.length, 0);
      expect(excel.translations.length, 2);
    });
  });
}
