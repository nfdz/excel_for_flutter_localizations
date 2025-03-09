import 'dart:io';

bool _verbose = false;

/// Config the internal logger.
void configLogger({required bool verbose}) => _verbose = verbose;

/// Log a verbose message in the stdout.
void logVerbose(String message) {
  if (_verbose) {
    stdout.writeln("[VERBOSE] $message");
  }
}

/// Log an error message in the stdout.
void logError(String message) {
  stdout.writeln("[ERROR] $message");
}
