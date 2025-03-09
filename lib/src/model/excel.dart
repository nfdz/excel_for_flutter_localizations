// ignore_for_file: public_member_api_docs

class ExcelFile {
  const ExcelFile({required this.translations, required this.fuzzy});
  final Map<String, ExcelTranslations> translations;
  final Map<String, bool> fuzzy;
}

class ExcelTranslations {
  const ExcelTranslations({required this.locale, required this.items});
  final String locale;
  final Map<String, String> items;
}
