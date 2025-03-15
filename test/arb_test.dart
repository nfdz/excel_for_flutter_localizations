import 'dart:io';

import 'package:excel_for_flutter_localizations/excel_for_flutter_localizations.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';
import 'package:test/test.dart';

import 'arb_mock.dart';

void main() {
  late final tempDir = Directory.systemTemp.createTempSync();

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  setUpAll(() {
    configLogger(verbose: true);
  });

  group("readArbFileLocale", () {
    test('when locale is present', () {
      final arbEnFile = tempDir.createArbFile(arbEn);

      final locale = readArbFileLocale(arbEnFile);

      expect(locale, "en");
    });

    test('when file is corrupt', () {
      final invalidFile = tempDir.createArbFile("invalid content");

      final locale = readArbFileLocale(invalidFile);

      expect(locale, null);
    });

    test('when file does not have locale', () {
      final arbFile = tempDir.createArbFile(arbNoLocale);

      final locale = readArbFileLocale(arbFile);

      expect(locale, null);
    });
  });

  group("readArbDir", () {
    test('when EN and ES are present', () {
      final testArbDir = tempDir.createArbDir();
      final arbEnFile = testArbDir.createArbFile(arbEn);
      final arbEsFile = testArbDir.createArbFile(arbEs);

      final arbDir = readArbDir(testArbDir.path);

      expect(arbDir.dirPath, testArbDir.path);
      expect(arbDir.filePaths.length, 2);
      expect(arbDir.filePaths.contains(arbEnFile.path), true);
      expect(arbDir.filePaths.contains(arbEsFile.path), true);
      expect(arbDir.arbs.length, 2);

      final actualArbEn = arbDir.arbs['en'];
      expect(actualArbEn!.locale, 'en');
      expect(actualArbEn.items.length, 3);
      expect(actualArbEn.items['hello'], 'hello');
      expect(actualArbEn.items['testHello'], 'Hello {name}');
      expect(actualArbEn.items['finalTest'], 'My final\n test');
      expect(actualArbEn.tags.length, 2);
      expect(actualArbEn.tags['hello'], 'landing');
      expect(actualArbEn.tags['testHello'], 'landing');

      final actualArbEs = arbDir.arbs['es'];
      expect(actualArbEs!.locale, 'es');
      expect(actualArbEs.items.length, 3);
      expect(actualArbEs.items['hello'], 'hola');
      expect(actualArbEs.items['testHello'], 'Hola {name}');
      expect(actualArbEs.items['finalTest'], 'Mi test\n final');
      expect(actualArbEs.tags.length, 0);
    });

    test('when file is corrupt', () {
      final testArbDir = tempDir.createArbDir();
      final arbFile = testArbDir.createArbFile("invalid content");

      final arbDir = readArbDir(testArbDir.path);

      expect(arbDir.dirPath, testArbDir.path);
      expect(arbDir.filePaths.length, 1);
      expect(arbDir.filePaths.first, arbFile.path);
      expect(arbDir.arbs.length, 0);
    });

    test('when file does not have locale', () {
      final testArbDir = tempDir.createArbDir();
      final arbFile = testArbDir.createArbFile(arbNoLocale);

      final arbDir = readArbDir(testArbDir.path);

      expect(arbDir.dirPath, testArbDir.path);
      expect(arbDir.filePaths.length, 1);
      expect(arbDir.filePaths.first, arbFile.path);
      expect(arbDir.arbs.length, 0);
    });

    test('when file has no translations', () {
      final testArbDir = tempDir.createArbDir();
      final arbFile = testArbDir.createArbFile(arbEmpty);

      final arbDir = readArbDir(testArbDir.path);

      expect(arbDir.dirPath, testArbDir.path);
      expect(arbDir.filePaths.length, 1);
      expect(arbDir.filePaths.first, arbFile.path);
      expect(arbDir.arbs.length, 0);
    });
  });
}
