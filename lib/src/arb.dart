import 'dart:io';

import 'package:excel_for_flutter_localizations/src/json.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';
import 'package:excel_for_flutter_localizations/src/model/arb.dart';
import 'package:excel_for_flutter_localizations/src/model/excel.dart';
import 'package:path/path.dart';

/// The expected key for the locale in the ARB file.
const arbLocaleKey = "@@locale";

/// Reads the locale from an ARB file.
String? readArbFileLocale(File arbFile) {
  final fileContentString = arbFile.readAsStringSync();

  final fileContentJson = tryJsonDecode(fileContentString);
  if (fileContentJson is Map<String, dynamic>) {
    return fileContentJson[arbLocaleKey]?.toString();
  } else {
    logError("ARB file content not valid: ${arbFile.path}");
    return null;
  }
}

/// Reads the ARB files from a directory.
ArbDir? readArbDir(String arbDirPath) {
  final arbDir = Directory(arbDirPath);
  if (!arbDir.existsSync()) {
    logVerbose("ARB directory not found: $arbDirPath");
    return null;
  }

  final arbFiles = arbDir.listSync().whereType<File>().where((f) => extension(f.path) == '.arb');
  logVerbose("ARB files: ${arbFiles.map((f) => basename(f.path)).join(', ')}");
  final arbs = <String, ArbFile>{};
  for (final arbFile in arbFiles) {
    logVerbose("Processing ${basename(arbFile.path)}");
    final arb = _readArbFile(arbFile);
    if (arb != null) {
      arbs[arb.locale] = arb;
    }
  }
  return ArbDir(arbs: arbs, dirPath: arbDirPath, filePaths: arbFiles.map((f) => f.path).toList());
}

/// Reads an ARB file.
ArbFile? _readArbFile(File file) {
  final fileContentString = file.readAsStringSync();
  final fileContentJson = tryJsonDecode(fileContentString);
  final items = <String, String>{};
  final tags = <String, String>{};
  String? locale;
  if (fileContentJson is Map<String, dynamic>) {
    locale = fileContentJson[arbLocaleKey]?.toString();

    if (locale == null) {
      logError("ARB file not valid: no '$arbLocaleKey' found in ${file.path}");
      return null;
    }

    for (final e in fileContentJson.entries) {
      if (e.key.startsWith('@')) {
        continue;
      }
      final meta = fileContentJson['@${e.key}'];
      items[e.key] = e.value.toString();
      if (meta is Map) {
        final tag = meta['context'];
        if (tag is String) {
          tags[e.key] = tag;
        }
      }
    }

    if (items.isEmpty) {
      logVerbose("ARB file is empty: ${file.path}");
      return null;
    }

    return ArbFile(locale: locale, items: items, tags: tags);
  } else {
    logError("ARB file content not valid: ${file.path}");
    return null;
  }
}

/// Writes the ARB files to a directory.
void writeArbDir({
  required ArbDir arbDir,
  required ExcelFile? excel,
  required String arbTemplateLocale,
  required String arbTemplateFileName,
}) {
  if (excel == null) {
    logVerbose("No excel file to process, keep ARB directory as it is");
    return;
  }
  logVerbose("Processing excel into ARB directory");

  // Delete all ARB files except the template file.
  for (final filePath in arbDir.filePaths) {
    final fileName = basename(filePath);
    if (fileName != arbTemplateFileName) {
      File(filePath).deleteSync();
    }
  }

  final arbTemplate = arbDir.arbs[arbTemplateLocale]!;
  for (final translation in excel.translations.entries) {
    if (translation.key == arbTemplateLocale) {
      continue;
    }
    _writeArbFile(
      arbDirPath: arbDir.dirPath,
      arbTemplateFileName: arbTemplateFileName,
      arbTemplate: arbTemplate,
      translation: translation,
      oldArb: arbDir.arbs[translation.key],
    );
  }
}

/// Writes an ARB file.
void _writeArbFile({
  required MapEntry<String, ExcelTranslations> translation,
  required String arbTemplateFileName,
  required String arbDirPath,
  required ArbFile arbTemplate,
  required ArbFile? oldArb,
}) {
  final arbFile = arbTemplateFileName.replaceFirst(arbTemplate.locale, translation.value.locale);
  logVerbose("Updating $arbFile...");
  final tempArbFile = File("$arbDirPath${Platform.pathSeparator}$arbFile")..createSync();
  final arbContent = <String, String>{};
  arbContent[arbLocaleKey] = translation.value.locale;

  // Insert the translations following the template order.
  for (final key in arbTemplate.items.keys) {
    final value = translation.value.items[key] ?? oldArb?.items[key];
    if (value != null) {
      arbContent[key] = value;
    }
  }

  tempArbFile.writeAsStringSync(jsonPrettyEncode(arbContent));
}
