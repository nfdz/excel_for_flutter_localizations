<h2 align="center">
  Excel for flutter_localizations
</h2>

<p align="center">
  <a href="https://github.com/nfdz/excel_for_flutter_localizations/actions">
    <img alt="Build Status" src="https://github.com/nfdz/excel_for_flutter_localizations/workflows/build/badge.svg">
  </a>
  <a href="https://pub.dartlang.org/packages/excel_for_flutter_localizations">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/excel_for_flutter_localizations.svg">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

---

## Overview

A Dart package that allows you to use a Excel as a localization platform alongside the standard Flutter library [flutter_localizations](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization).

The idea is to **keep it simple** until you perhaps need to use a more professional platform. In that case, the change will be immediate, without code migrations or problems.

### Breakdown of the Rules

- The source of truth is the ARB file declared as template (`template-arb-file`) → *This file will never be modified by this tool*
- When a translation entry is in the Excel and in the ARB file of its language → *The one in Excel will be used*
- When a translation entry is not present in the ARB template file → *It will be deleted from Excel and all other ARBs*
- When a translation entry is not present in Excel but is present in the translated ARBs → *The present translations will be used for the ARBs and for the Excel*
- When a translation entry has changed its text in the reference language (`template-arb-file`) → *This translation will be updated in the Excel*
  - Be careful because the rest of the languages ​​will continue to use the value they have in Excel. To update the translations, the idea is to go through the Excel.

#### New and Fuzzy Translations

The first column of the Excel will have an `X` when:
- The translation entry is new.
- The translation entry has changed in the reference language (`template-arb-file`).

#### Disabled Columns

There is a greyish background colour in the cells that should not be modified under any circumstances in the Excel file. The reason is that they will not produce any change in the ARBs and may be misleading. They are: `context`, `key`, `reference translation`.

## Install

```bash
dart pub global activate excel_for_flutter_localizations
```

## Usage

```bash
dart pub global run excel_for_flutter_localizations [ARGS]
```

#### Arguments

| Mandatory | Argument                     |  Description                                                                           |
|-----------|------------------------------|----------------------------------------------------------------------------------------|
| Yes       | -a, --arb-dir                | Path to the ARB files directory, eg: lib/l10n         |
| Yes       | -e, --excel-file             | Path to the Excel file, eg: translations.xlsx                |
| Yes       | -t, --template-arb-file      | ARB template file, eg: app_en.arb            |
| No        | -v, --verbose                | Print verbose output            |

#### Most Common Scenario

Using the same naming conventions as Flutter documentation.

```bash
dart pub global run excel_for_flutter_localizations -a lib/l10n -e translations.xlsx -t app_en.arb
```

## Example

```bash
cd example
dart ../bin/excel_for_flutter_localizations.dart -a l10n -e example.xlsx -t app_en.arb --verbose
```

### Screenshot

![Example Excel](https://github.com/user-attachments/assets/e6a70c6f-8902-4b18-8af8-64d7f32cf154)
