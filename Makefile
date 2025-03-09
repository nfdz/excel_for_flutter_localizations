.DEFAULT_GOAL := publish-test
.PHONY: doc lint build

format:
	@dart format --fix .

lint:
	@dart analyze

doc:
	@dart pub global run dartdoc

run-example:
	@cd example && dart ../bin/excel_for_flutter_localizations.dart -a l10n -e example.xlsx -t app_en.arb --verbose

build:
	@mkdir -p build
	@dart compile exe bin/excel_for_flutter_localizations.dart -o build/excel_for_flutter_localizations
	@dart compile aot-snapshot bin/excel_for_flutter_localizations.dart -o build/excel_for_flutter_localizations.aot

active:
	@dart pub global activate --source path .

publish-test: build
	@dart pub publish --dry-run

publish: publish-test
	@dart pub publish
