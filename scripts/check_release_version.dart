// Usage: dart check_release_version.dart refs/tags/1.2.3

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  // it could come with the prefix 'refs/tags/'
  final releaseVersion = args[0].replaceAll("refs/tags/", "").trim();
  stdout.writeln('Release version: $releaseVersion');

  final pkgVersion = await _getPackageVersion();
  stdout.writeln('Package version: $pkgVersion');

  if (releaseVersion != pkgVersion) {
    stdout.writeln('[ERROR] Invalid Release version: $releaseVersion != $pkgVersion');
    exit(1);
  } else {
    exit(0);
  }
}

Future<String> _getPackageVersion() async {
  final file = File('pubspec.yaml');
  final lines = await file.openRead().transform(utf8.decoder).transform(const LineSplitter()).toList();

  return lines.firstWhere((element) => element.startsWith("version")).split(":")[1].trim();
}
