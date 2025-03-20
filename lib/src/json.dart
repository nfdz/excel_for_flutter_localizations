import 'dart:convert';

import 'package:excel_for_flutter_localizations/src/logger.dart';

const _spaces = '  ';
const _encoder = JsonEncoder.withIndent(_spaces);

/// Encodes a JSON object to a pretty JSON string.
String jsonPrettyEncode(dynamic json) => _encoder.convert(json);

/// Try to decode a string that represents a JSON object.
dynamic tryJsonDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (e) {
    logVerbose("JSON decode error: $e");
    return null;
  }
}
