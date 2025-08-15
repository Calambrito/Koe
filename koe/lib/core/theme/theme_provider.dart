import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color_palettes.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _paletteKey = 'color_palette';

  bool _isDarkMode = true;
  String _currentPalette = 'Default';

  bool get isDarkMode => _isDarkMode;
  String get currentPalette => _currentPalette;

  ThemeProvider() {
    _initializeTheme();
  }

  // Initialize theme with error handling
  Future<void> _initializeTheme() async {
    try {
      await _loadThemeFromPrefs();
    } catch (e) {
      // Fallback to default values if there's an error
      _isDarkMode = true;
      _currentPalette = 'Default';
      notifyListeners();
    }
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? true; // Default to dark mode
      _currentPalette =
          prefs.getString(_paletteKey) ?? 'Default'; // Default palette

      // Validate palette name
      if (!ColorPalettes.palettes.containsKey(_currentPalette)) {
        _currentPalette = 'Default';
      }

      notifyListeners();
    } catch (e) {
      // Fallback to default values if there's an error
      _isDarkMode = true;
      _currentPalette = 'Default';
      notifyListeners();
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      await prefs.setString(_paletteKey, _currentPalette);
    } catch (e) {
      // Ignore save errors to prevent crashes
      debugPrint('Error saving theme preferences: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveThemeToPrefs();
    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _saveThemeToPrefs();
      notifyListeners();
    }
  }

  // Set color palette
  Future<void> setPalette(String paletteName) async {
    try {
      // Validate palette name
      if (paletteName.isEmpty) {
        paletteName = 'Default';
      }

      // Check if palette exists
      if (!ColorPalettes.palettes.containsKey(paletteName)) {
        paletteName = 'Default';
      }

      if (_currentPalette != paletteName) {
        _currentPalette = paletteName;
        await _saveThemeToPrefs();
        notifyListeners();
      }
    } catch (e) {
      // Fallback to default palette if there's an error
      _currentPalette = 'Default';
      await _saveThemeToPrefs();
      notifyListeners();
    }
  }

  // Get current theme
  ThemeData get theme => _isDarkMode ? darkTheme : lightTheme;

  // Get current palette colors
  Color get primaryColor => ColorPalettes.getMainColor(_currentPalette);
  Color get lightColor => ColorPalettes.getLightColor(_currentPalette);
  Color get darkColor => ColorPalettes.getDarkColor(_currentPalette);

  // Dark theme
  ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 1),
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: lightColor,
      surface: const Color.fromRGBO(30, 30, 30, 1),
      onSurface: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromRGBO(52, 51, 67, 1),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromRGBO(18, 18, 18, 1),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color.fromRGBO(30, 30, 30, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  // Light theme
  ThemeData get lightTheme => ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(248, 248, 248, 1),
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: lightColor,
      surface: Colors.white,
      onSurface: const Color.fromRGBO(33, 33, 33, 1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromRGBO(224, 224, 224, 1),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
      foregroundColor: const Color.fromRGBO(33, 33, 33, 1),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
