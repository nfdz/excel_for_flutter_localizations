import 'dart:io';

import 'package:excel_for_flutter_localizations/excel_for_flutter_localizations.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';
import 'package:test/test.dart';

import 'arb_mock.dart';
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
    test('when file is valid', () {
      final excelFile = tempDir.createExcelFile();

      final excel = readExcelFile(excelFile.path);

      expect(excel!.fuzzy.length, 0);
      expect(excel.translations.length, 2);

      final enTranslations = excel.translations['en'];
      expect(enTranslations!.locale, 'en');
      expect(enTranslations.items.length, 3);
      expect(enTranslations.items['hello'], 'hello');
      expect(enTranslations.items['testHello'], 'Hello {name}');
      expect(enTranslations.items['finalTest'], 'My final\n test');

      final esTranslations = excel.translations['es'];
      expect(esTranslations!.locale, 'es');
      expect(esTranslations.items.length, 3);
      expect(esTranslations.items['hello'], 'hola');
      expect(esTranslations.items['testHello'], 'Hola {name}');
      expect(esTranslations.items['finalTest'], 'Mi test\n final');
    });

    test('when file is not valid', () {
      final invalidFile = tempDir.createInvalidExcel();
      final excel = readExcelFile(invalidFile.path);

      expect(excel, null);
    });

    test('when file does not exists', () {
      final excel = readExcelFile("${tempDir.path}${Platform.pathSeparator}thisdoesnotexists.xlsx");

      expect(excel, null);
    });
  });

  group("writeExcel", () {
    test('when there is nothing', () {
      const initialContent = "initial-content-excel";
      final excelFilePath = '${tempDir.createTempSync().path}${Platform.pathSeparator}test_excel.xlsx';
      final excelFile = File(excelFilePath)..writeAsStringSync(initialContent);

      writeExcel(excelFilePath: excelFilePath, arbs: {}, excelFile: null, arbTemplateLocale: "");

      expect(excelFile.existsSync(), true);
      expect(excelFile.readAsStringSync(), initialContent);
    });

    test('when there only ARB is present but template locale not', () {
      const initialContent = "initial-content-excel";
      final excelFilePath = '${tempDir.createTempSync().path}${Platform.pathSeparator}test_excel.xlsx';
      final excelFile = File(excelFilePath)..writeAsStringSync(initialContent);

      writeExcel(excelFilePath: excelFilePath, arbs: arbs(), excelFile: null, arbTemplateLocale: "??");

      expect(excelFile.existsSync(), true);
      expect(excelFile.readAsStringSync(), initialContent);
    });

    test('when there only ARB is present', () {
      const initialContent = "initial-content-excel";
      final excelFilePath = '${tempDir.createTempSync().path}${Platform.pathSeparator}test_excel.xlsx';
      final excelFile = File(excelFilePath)..writeAsStringSync(initialContent);

      writeExcel(excelFilePath: excelFilePath, arbs: arbs(), excelFile: null, arbTemplateLocale: "en");

      expect(excelFile.existsSync(), true);
      final excelSaved = readExcelFile(excelFile.path);

      expect(excelSaved!.fuzzy.length, 0);
      expect(excelSaved.translations.length, 2);

      final enTranslations = excelSaved.translations['en'];
      expect(enTranslations!.locale, 'en');
      expect(enTranslations.items.length, 3);
      expect(enTranslations.items['hello'], 'hello');
      expect(enTranslations.items['testHello'], 'Hello {name}');
      expect(enTranslations.items['finalTest'], 'My final\n test');

      final esTranslations = excelSaved.translations['es'];
      expect(esTranslations!.locale, 'es');
      expect(esTranslations.items.length, 3);
      expect(esTranslations.items['hello'], 'hola');
      expect(esTranslations.items['testHello'], 'Hola {name}');
      expect(esTranslations.items['finalTest'], 'Mi test\n final');
    });

    test('when there ARB and Excel are present', () {
      const initialContent = "initial-content-excel";
      final excelFilePath = '${tempDir.createTempSync().path}${Platform.pathSeparator}test_excel.xlsx';
      final excelFile = File(excelFilePath)..writeAsStringSync(initialContent);
      final excel = mockExcelFile();

      writeExcel(excelFilePath: excelFilePath, arbs: arbs(), excelFile: excel, arbTemplateLocale: "en");

      expect(excelFile.existsSync(), true);
      final excelSaved = readExcelFile(excelFile.path);

      expect(excelSaved!.fuzzy.length, 0);
      expect(excelSaved.translations.length, 2);

      final enTranslations = excelSaved.translations['en'];
      expect(enTranslations!.locale, 'en');
      expect(enTranslations.items.length, 3);
      expect(enTranslations.items['hello'], 'hello');
      expect(enTranslations.items['testHello'], 'Hello {name}');
      expect(enTranslations.items['finalTest'], 'My final\n test');

      final esTranslations = excelSaved.translations['es'];
      expect(esTranslations!.locale, 'es');
      expect(esTranslations.items.length, 3);
      expect(esTranslations.items['hello'], 'hola');
      expect(esTranslations.items['testHello'], 'Hola {name}');
      expect(esTranslations.items['finalTest'], 'Mi test\n final');
    });

    test('when there ARB and Excel have different translations', () {
      const esHelloOverrideArb = "Hola ha cambiado en el ARB!";
      const esHelloOverrideExcel = "Hola ha cambiado en el Excel!";
      const initialContent = "initial-content-excel";
      final excelFilePath = '${tempDir.createTempSync().path}${Platform.pathSeparator}test_excel.xlsx';
      final excelFile = File(excelFilePath)..writeAsStringSync(initialContent);
      final excel = mockExcelFile(esHelloOverride: esHelloOverrideExcel);

      writeExcel(
        excelFilePath: excelFilePath,
        arbs: arbs(esHelloOverride: esHelloOverrideArb),
        excelFile: excel,
        arbTemplateLocale: "en",
      );

      expect(excelFile.existsSync(), true);
      final excelSaved = readExcelFile(excelFile.path);
      expect(excelSaved!.fuzzy.length, 0);
      expect(excelSaved.translations.length, 2);
      final esTranslations = excelSaved.translations['es'];
      expect(esTranslations!.items['hello'], esHelloOverrideExcel);
    });
  });
}
