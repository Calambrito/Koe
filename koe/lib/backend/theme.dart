import 'koe_palette.dart';

class KoeTheme {
  final KoeColorName paletteName;
  final bool isDarkMode;

  const KoeTheme({required this.paletteName, required this.isDarkMode});

  KoeTheme copyWith({KoeColorName? paletteName, bool? isDarkMode}) {
    return KoeTheme(
      paletteName: paletteName ?? this.paletteName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KoeTheme &&
          runtimeType == other.runtimeType &&
          paletteName == other.paletteName &&
          isDarkMode == other.isDarkMode;
}
