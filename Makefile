.DEFAULT_GOAL := publish-test
.PHONY: doc lint build test
# .SHELL=/bin/bash

prepare:
	@dart pub get

format-fix:
	@dart format --line-length=120 .

format-check:
	@dart format --line-length=120 --set-exit-if-changed .

lint: prepare
	@dart analyze

doc:
	@dart pub global run dartdoc

run-example:
	@cd example && dart ../bin/excel_for_flutter_localizations.dart -a l10n -e example.xlsx -t app_en.arb --verbose

build: prepare
	@mkdir -p build
	@dart compile exe bin/excel_for_flutter_localizations.dart -o build/excel_for_flutter_localizations
	@dart compile aot-snapshot bin/excel_for_flutter_localizations.dart -o build/excel_for_flutter_localizations.aot

#@dart test --reporter=expanded
test: prepare
	@rm -rf coverage
	@dart run coverage:test_with_coverage

coverage-check: test
	@dart scripts/check_coverage.dart coverage/lcov.info

active:
	@dart pub global activate --source path .

publish-test: build
	@dart pub publish --dry-run

publish: publish-test
	@dart pub publish --force
