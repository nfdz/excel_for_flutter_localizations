import 'dart:io';

import 'package:excel_for_flutter_localizations/excel_for_flutter_localizations.dart';
import 'package:test/test.dart';

void main() {
  late final tempDir = Directory.systemTemp.createTempSync();

  File createArbFile(String content) =>
      File('${tempDir.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_test.arb')
        ..writeAsStringSync(content);

  tearDownAll(() async {
    tempDir.deleteSync(recursive: true);
  });

  test('readArbFileLocale', () {
    final arbEnFile = createArbFile(_arbEn);
    final locale = readArbFileLocale(arbEnFile);

    expect(locale, "en");

    arbEnFile.deleteSync();
  });
}

const _arbEn = r"""
{
    "@@locale": "en",
    "hello": "hello",
    "@hello": {
        "context": "landing"
    },
    "testHello": "Hello {name}",
    "@testHello": {
        "context": "landing",
        "placeholders": {
            "name": {
                "type": "String"
            }
        }
    },
    "finalTest": "My final\n test",
    "@finalTest": {}
}
""";
