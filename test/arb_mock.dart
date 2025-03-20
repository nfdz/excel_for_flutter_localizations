import 'dart:io';

import 'package:excel_for_flutter_localizations/src/model/arb.dart';

var _rnd = 0;

extension DirectoryX on Directory {
  Directory createArbDir() {
    final dir = '$path${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${++_rnd}';
    return Directory(dir)..createSync();
  }

  File createArbFile(String content) {
    return File('$path${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_${++_rnd}_test.arb')
      ..writeAsStringSync(content);
  }
}

ArbDir mockArbDir({required String dirPath, required List<String> filePaths}) {
  return ArbDir(
    arbs: arbs(),
    filePaths: filePaths,
    dirPath: dirPath,
  );
}

Map<String, ArbFile> arbs({String? esHelloOverride}) => {
      'en': const ArbFile(
        locale: 'en',
        items: {
          'hello': 'hello',
          'testHello': 'Hello {name}',
          'finalTest': 'My final\n test',
        },
        tags: {
          'hello': 'landing',
          'testHello': 'landing',
        },
      ),
      'es': ArbFile(
        locale: esHelloOverride ?? 'es',
        items: {
          'hello': 'hola',
          'testHello': 'Hola {name}',
          'finalTest': 'Mi test\n final',
        },
        tags: {},
      ),
    };

const arbEn = r"""
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
}""";

const arbEs = r"""
{
  "@@locale": "es",
  "hello": "hola",
  "testHello": "Hola {name}",
  "finalTest": "Mi test\n final"
}""";

const arbNoLocale = r"""
{
  "hello": "hello",
  "testHello": "Hello {name}",
  "finalTest": "My final\n test"
}""";

const arbEmpty = """
{
  "@@locale": "en"
}""";
