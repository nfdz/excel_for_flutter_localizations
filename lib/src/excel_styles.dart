// ignore_for_file: public_member_api_docs

import 'package:excel/excel.dart';

class ExcelStyles {
  final bgColorDisabled = ExcelColor.fromHexString("#e0e0e0");
  final bgColorHeader = ExcelColor.fromHexString("#16537e");
  late final headerStyle = CellStyle(
    backgroundColorHex: bgColorHeader,
    bold: true,
    fontColorHex: ExcelColor.white,
    bottomBorder: Border(borderColorHex: ExcelColor.black, borderStyle: BorderStyle.Thick),
  );
  late final disabledStyle = CellStyle(
    backgroundColorHex: bgColorDisabled,
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Center,
    bottomBorder: Border(borderColorHex: ExcelColor.black, borderStyle: BorderStyle.Medium),
  );
  final translationStyle = CellStyle(
    textWrapping: TextWrapping.WrapText,
    verticalAlign: VerticalAlign.Center,
    bottomBorder: Border(borderColorHex: ExcelColor.black, borderStyle: BorderStyle.Medium),
  );
  final fuzzyStyle = CellStyle(
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    bottomBorder: Border(borderColorHex: ExcelColor.black, borderStyle: BorderStyle.Medium),
  );
}
