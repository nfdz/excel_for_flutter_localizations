// Usage: dart check_coverage.dart path/to/lcov.info

import 'dart:io';

// TODO(nfdz): Change this value to the minimum coverage required.
const minCoverage = 1;

void main(List<String> args) async {
  final lcovFilePath = args[0];

  final coverage = _computeCoverageSync(lcovFilePath);
  final coverageString = coverage.toStringAsFixed(2);
  stdout.writeln('Total test coverage: $coverageString%');

  if (coverage < minCoverage) {
    stdout.writeln('[ERROR] Invalid coverage: $coverageString% < $minCoverage% (minimum)');
    exit(1);
  } else {
    exit(0);
  }
}

double _computeCoverageSync(String lcovFilePath) {
  final lcovResult = Process.runSync('lcov', ['--summary', lcovFilePath]);
  final lcovSummary = lcovResult.stdout as String;
  final lcovLinesLine = lcovSummary.split("\n").firstWhere((element) => element.contains("lines)"));
  final linesCoveragePercentage = lcovLinesLine.split(' ').map((e) => e.trim()).firstWhere((e) => e.contains("%"));
  return double.parse(linesCoveragePercentage.replaceAll("%", ""));
}
