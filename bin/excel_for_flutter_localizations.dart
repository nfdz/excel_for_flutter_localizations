import 'dart:io';

import 'package:args/args.dart';
import 'package:excel_for_flutter_localizations/excel_for_flutter_localizations.dart';
import 'package:excel_for_flutter_localizations/src/logger.dart';

const _pkgName = "excel_for_flutter_localizations";
const _pkgVersion = "1.0.0-dev";
const _argArbDir = "arb-dir";
const _argExcelFile = "excel-file";
const _argTemplateArbFile = "template-arb-file";
const _argVerbose = "verbose";

void main(List<String> args) {
  // Get the arguments
  final parser = _getParser();
  final ArgResults argResults;
  try {
    argResults = parser.parse(args);
  } catch (_) {
    _exitErrorArgs(parser);
  }

  final verbose = argResults.flag(_argVerbose);
  configLogger(verbose: verbose);

  final arbTemplateFile = argResults.option(_argTemplateArbFile);
  final arbDirPath = argResults.option(_argArbDir);
  final excelFilePath = argResults.option(_argExcelFile);

  // Validate the arguments
  if (arbTemplateFile == null || arbDirPath == null || excelFilePath == null) {
    logError("Missing required arguments");
    _exitErrorArgs(parser);
  }

  final arbTemplateFilePath = "$arbDirPath${Platform.pathSeparator}$arbTemplateFile";
  final arbFile = File(arbTemplateFilePath);
  if (!arbFile.existsSync()) {
    logError("ARB template file not found: $arbTemplateFilePath");
    exit(1);
  }

  // Process ARBs
  final arbTemplateLocale = readArbFileLocale(arbFile);
  if (arbTemplateLocale == null) {
    logError("ARB template file not valid: no '$arbLocaleKey' found in $arbTemplateFilePath");
    exit(1);
  }
  if (arbTemplateFilePath.split(arbTemplateLocale).length != 2) {
    logError("ARB template file not valid: '$arbLocaleKey' must be in the file name and cannot be repeated.");
    exit(1);
  }
  final arbDir = readArbDir(arbDirPath);

  // Process Excel
  final excel = readExcelFile(excelFilePath);

  // Update ARBs
  writeArbDir(
    arbDir: arbDir,
    excel: excel,
    arbTemplateLocale: arbTemplateLocale,
    arbTemplateFile: arbTemplateFile,
  );

  // Update Excel
  writeExcel(excelFile: excel, arbTemplateLocale: arbTemplateLocale, arbDir: arbDir, excelFilePath: excelFilePath);

  exit(0);
}

ArgParser _getParser() => ArgParser()
  ..addOption(_argArbDir, abbr: 'a', help: 'Path to the ARB files directory, eg: lib/l10n', mandatory: true)
  ..addOption(_argExcelFile, abbr: 'e', help: 'Path to the Excel file, eg: translations.xlsx', mandatory: true)
  ..addOption(_argTemplateArbFile, abbr: 't', help: 'ARB template file, eg: app_en.arb', mandatory: true)
  ..addFlag(_argVerbose, abbr: 'v', help: 'Print verbose output');

Never _exitErrorArgs(ArgParser parser) {
  stdout
    ..writeln('$_pkgName v$_pkgVersion\n')
    ..writeln('USAGE:')
    ..writeln(
      '  $_pkgName [ARGS]\n',
    )
    ..writeln('ARGS')
    ..writeln(parser.usage);
  exit(1);
}
