import 'package:flutter/material.dart';

class ColorPalettes {
  static const Map<String, Map<String, Color>> palettes = {
    'Default': {
      'light': Color(0xFFF8CCF0), // Light purple
      'main': Color(0xFFD46BFF),   // Main purple
      'dark': Color(0xFFB055CC),   // Dark purple
    },
    'Pumpkin': {
      'light': Color(0xFFF6C1A6),
      'main': Color(0xFFE76F2C),
      'dark': Color(0xFFD45A1A),
    },
    'Apricot': {
      'light': Color(0xFFF6E1A3),
      'main': Color(0xFFD99E3B),
      'dark': Color(0xFFC68A2A),
    },
    'Apple': {
      'light': Color(0xFFC7E7B3),
      'main': Color(0xFF4FB244),
      'dark': Color(0xFF3D8A35),
    },
    'Teal': {
      'light': Color(0xFFBCE6E3),
      'main': Color(0xFF319DA0),
      'dark': Color(0xFF267A7D),
    },
    'Blueberry': {
      'light': Color(0xFFC5D8F0),
      'main': Color(0xFF4267B2),
      'dark': Color(0xFF34518E),
    },
    'Eggplant': {
      'light': Color(0xFFD9B7E5),
      'main': Color(0xFFA349A4),
      'dark': Color(0xFF823A83),
    },
    'Dragonfruit': {
      'light': Color(0xFFF8CCF0),
      'main': Color(0xFFD46BFF),
      'dark': Color(0xFFB055CC),
    },
    'Ocean': {
      'light': Color(0xFFB3E5FC),
      'main': Color(0xFF2196F3),
      'dark': Color(0xFF1976D2),
    },
    'Sunset': {
      'light': Color(0xFFFFCCBC),
      'main': Color(0xFFFF5722),
      'dark': Color(0xFFE64A19),
    },
    'Forest': {
      'light': Color(0xFFC8E6C9),
      'main': Color(0xFF4CAF50),
      'dark': Color(0xFF388E3C),
    },
  };

  static List<String> get paletteNames => palettes.keys.toList();

  static Color getLightColor(String paletteName) {
    return palettes[paletteName]?['light'] ?? palettes['Default']!['light']!;
  }

  static Color getMainColor(String paletteName) {
    return palettes[paletteName]?['main'] ?? palettes['Default']!['main']!;
  }

  static Color getDarkColor(String paletteName) {
    return palettes[paletteName]?['dark'] ?? palettes['Default']!['dark']!;
  }

  static Map<String, Color> getPalette(String paletteName) {
    return palettes[paletteName] ?? palettes['Default']!;
  }
}
