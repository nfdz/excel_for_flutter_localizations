import 'dart:convert';

const _spaces = '  ';
const _encoder = JsonEncoder.withIndent(_spaces);

/// Encodes a JSON object to a pretty JSON string.
String jsonPrettyEncode(dynamic json) => _encoder.convert(json);
