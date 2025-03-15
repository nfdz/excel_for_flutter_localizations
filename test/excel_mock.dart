import 'dart:io';

var _rnd = 0;

final testExcelFile = '${Directory.current.path}${Platform.pathSeparator}test${Platform.pathSeparator}excel_mock.xlsx';

extension DirectoryX on Directory {
  File createExcelFile() {
    return File(testExcelFile)
        .copySync('$path${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${++_rnd}_test.xlsx');
  }
}
