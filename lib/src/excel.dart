import 'dart:io';

import 'package:excel/excel.dart';
import 'package:excel_for_flutter_localizations/src/excel_styles.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';
import 'package:excel_for_flutter_localizations/src/model/arb.dart';
import 'package:excel_for_flutter_localizations/src/model/excel.dart';
import 'package:path/path.dart';

const _rowHeader = 0;
const _colFuzzy = 0;
const _colTag = 1;
const _colKey = 2;
const _colTemplateValue = 3;
const _colFirstTranslationValue = 4;
final _styles = ExcelStyles();

/// Reads an Excel file.
ExcelFile? readExcelFile(String excelFilePath) {
  logVerbose("Processing $excelFilePath");

  final file = File(excelFilePath);
  if (!file.existsSync()) {
    logVerbose("File not found: $excelFilePath");
    return null;
  }

  final fileBytes = File(excelFilePath).readAsBytesSync();
  final excel = Excel.decodeBytes(fileBytes);

  final translations = <String, ExcelTranslations>{};
  final fuzzy = <String, bool>{};

  for (final sheet in excel.sheets.values) {
    final rowHeader = sheet.rows[_rowHeader];
    for (var translationColIndex = _colTemplateValue; translationColIndex < rowHeader.length; translationColIndex++) {
      final locale = rowHeader[translationColIndex]?.value?.toString();
      if (locale == null) {
        continue;
      }
      final items = <String, String>{};
      for (var rowIndex = _rowHeader + 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.rows[rowIndex];
        final key = row[_colKey]?.value?.toString();
        if (key == null) {
          continue;
        }
        final wasFuzzy = row[_colFuzzy]?.value?.toString().trim() ?? "";
        if (wasFuzzy.isNotEmpty) {
          fuzzy[key] = true;
        }
        final value = row[translationColIndex]?.value?.toString();
        if (value == null) {
          continue;
        }
        items[key] = _dequote(value);
      }

      if (items.isNotEmpty) {
        translations[locale] = ExcelTranslations(locale: locale, items: items);
      }
    }
  }
  return ExcelFile(translations: translations, fuzzy: fuzzy);
}

// TODO check if quote and dequote are needed
// String _dequote(String text) => text.replaceAll(r'\n', '\n');
// String? _quote(String? text) => text?.replaceAll('\n', r'\n');
String _dequote(String text) => text;
String? _quote(String? text) => text;

/// Writes an Excel file.
void writeExcel({
  required String excelFilePath,
  required ArbDir arbDir,
  required ExcelFile? excelFile,
  required String arbTemplateLocale,
}) {
  logVerbose("Updating Excel file: $excelFilePath");
  final excel = Excel.createExcel();
  final defaultSheet = excel.sheets.isNotEmpty ? excel.sheets.keys.first : null;

  final translationsLocales = _getTranslationsLocales(
    arbDir: arbDir,
    excelFile: excelFile,
    arbTemplateLocale: arbTemplateLocale,
  );

  final sheetObject = excel['Translations'];
  if (defaultSheet != null) {
    excel.delete(defaultSheet);
  }

  final headerCells = [
    TextCellValue('X'),
    TextCellValue('context'),
    TextCellValue('key'),
    TextCellValue(arbTemplateLocale),
    ...translationsLocales.map(TextCellValue.new),
  ];
  sheetObject.appendRow(headerCells);
  _styleHeaderCells(sheetObject, headerCells);

  var rowIdx = _rowHeader + 1;
  final templateArbFile = arbDir.arbs[arbTemplateLocale]!;
  final translationsKeys = _getTranslationsKeys(templateArbFile);
  for (final key in translationsKeys) {
    final row = <CellValue?>[]..length = 4 + translationsLocales.length;

    row[_colFuzzy] = TextCellValue(_isFuzzy(key, templateArbFile, excelFile) ? "X" : "");
    row[_colTag] = TextCellValue(templateArbFile.tags[key] ?? '');
    row[_colKey] = TextCellValue(key);
    row[_colTemplateValue] = TextCellValue(_quote(templateArbFile.items[key]) ?? '');

    for (var i = 0; i < translationsLocales.length; i++) {
      final locale = translationsLocales[i];
      final translation = excelFile?.translations[locale]?.items[key] ?? arbDir.arbs[locale]?.items[key];
      if (translation == null) {
        continue;
      }
      final cellValue = TextCellValue(_quote(translation) ?? '');
      row[_colFirstTranslationValue + i] = cellValue;
    }
    sheetObject.appendRow(row);
    _styleRowCells(sheetObject: sheetObject, rowIdx: rowIdx, maxTranslations: translationsLocales.length);
    rowIdx++;
  }

  sheetObject
    ..setColumnAutoFit(_colFuzzy)
    ..setColumnAutoFit(_colTag)
    ..setColumnAutoFit(_colKey)
    ..setColumnWidth(_colTemplateValue, 50);
  for (var i = 0; i < translationsKeys.length; i++) {
    sheetObject.setColumnWidth(_colFirstTranslationValue + i, 50);
  }

  final bytes = excel.save(fileName: basename(excelFilePath));
  if (bytes == null) {
    logError("Error generating excel. Cannot encode");
    return;
  }
  File(excelFilePath).writeAsBytesSync(bytes);
}

List<String> _getTranslationsLocales({
  required ArbDir arbDir,
  required ExcelFile? excelFile,
  required String arbTemplateLocale,
}) {
  final translationsLocalesSet = <String>{}..addAll(arbDir.arbs.keys);
  if (excelFile != null) {
    translationsLocalesSet.addAll(excelFile.translations.keys);
  }
  translationsLocalesSet.remove(arbTemplateLocale);
  return translationsLocalesSet.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

List<String> _getTranslationsKeys(ArbFile templateArbFile) {
  final keys = templateArbFile.items.keys;
  return keys.toList()
    ..sort((a, b) {
      final aTag = templateArbFile.tags[a] ?? "";
      final bTag = templateArbFile.tags[b] ?? "";
      if (aTag == bTag) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      } else {
        return aTag.toLowerCase().compareTo(bTag.toLowerCase());
      }
    });
}

bool _isFuzzy(String key, ArbFile templateArbFile, ExcelFile? excelFile) {
  if (excelFile == null) {
    return false;
  }
  if (templateArbFile.items[key] != excelFile.translations[templateArbFile.locale]?.items[key]) {
    return true;
  }
  return excelFile.fuzzy[key] ?? false;
}

void _styleHeaderCells(Sheet sheetObject, List<TextCellValue> headerCells) {
  for (var i = 0; i < headerCells.length; i++) {
    sheetObject.styleCell(columnIndex: i, rowIndex: _rowHeader, style: _styles.headerStyle);
  }
}

void _styleRowCells({
  required Sheet sheetObject,
  required int rowIdx,
  required int maxTranslations,
}) {
  sheetObject
    ..styleCell(columnIndex: _colFuzzy, rowIndex: rowIdx, style: _styles.fuzzyStyle)
    ..styleCell(columnIndex: _colTag, rowIndex: rowIdx, style: _styles.disabledStyle)
    ..styleCell(columnIndex: _colKey, rowIndex: rowIdx, style: _styles.disabledStyle)
    ..styleCell(columnIndex: _colTemplateValue, rowIndex: rowIdx, style: _styles.disabledStyle);

  for (var i = 0; i < maxTranslations; i++) {
    sheetObject.styleCell(
      columnIndex: _colFirstTranslationValue + i,
      rowIndex: rowIdx,
      style: _styles.translationStyle,
    );
  }
}

extension _SheetX on Sheet {
  void styleCell({
    required int columnIndex,
    required int rowIndex,
    required CellStyle style,
  }) {
    cell(
      CellIndex.indexByColumnRow(
        columnIndex: columnIndex,
        rowIndex: rowIndex,
      ),
    ).cellStyle = style;
  }
}
