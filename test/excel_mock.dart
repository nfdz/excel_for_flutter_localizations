import 'dart:io';

import 'package:excel_for_flutter_localizations/src/model/excel.dart';

var _rnd = 0;

final testExcelFile = '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}excel_mock.xlsx';

extension DirectoryX on Directory {
  File createExcelFile() {
    return File(testExcelFile)
        .copySync('$path${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${++_rnd}_test.xlsx');
  }

  File createInvalidExcel() {
    return File('$path${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${++_rnd}_test.arb')
      ..writeAsStringSync("invalid");
  }
}

ExcelFile mockExcelFile({String? esHelloOverride}) {
  return ExcelFile(
    fuzzy: {},
    translations: {
      'en': const ExcelTranslations(
        locale: 'en',
        items: {
          'hello': 'hello',
          'testHello': 'Hello {name}',
          'finalTest': 'My final\n test',
        },
      ),
      'es': ExcelTranslations(
        locale: 'es',
        items: {
          'hello': esHelloOverride ?? 'hola',
          'testHello': 'Hola {name}',
          'finalTest': 'Mi test\n final',
        },
      ),
    },
  );
}
