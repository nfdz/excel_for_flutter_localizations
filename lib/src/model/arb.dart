// ignore_for_file: public_member_api_docs

class ArbDir {
  const ArbDir({required this.arbs, required this.filePaths, required this.dirPath});
  final Map<String, ArbFile> arbs;
  final List<String> filePaths;
  final String dirPath;
}

class ArbFile {
  const ArbFile({required this.locale, required this.items, required this.tags});
  final String locale;
  final Map<String, String> items;
  final Map<String, String> tags;
}
