import 'package:flutter/material.dart';

/// Enum of available palette names
enum KoeColorName {
  pumpkin,
  apricot,
  teal,
  blueberry,
  eggplant,
  dragonfruit,
  ocean,
  sunset,
  forest,
}

/// Each palette holds 3 shades of a color.
class KoePalette {
  static final Map<KoeColorName, Map<String, Color>> palettes = {
    KoeColorName.pumpkin: {
      'light': const Color(0xFFF6C1A6),
      'main': const Color(0xFFE76F2C),
      'dark': const Color(0xFFD45A1A),
    },
    KoeColorName.apricot: {
      'light': const Color(0xFFF6E1A3),
      'main': const Color(0xFFD99E3B),
      'dark': const Color(0xFFC68A2A),
    },
    KoeColorName.teal: {
      'light': const Color(0xFFBCE6E3),
      'main': const Color(0xFF319DA0),
      'dark': const Color(0xFF267A7D),
    },
    KoeColorName.blueberry: {
      'light': const Color(0xFFC5D8F0),
      'main': const Color(0xFF4267B2),
      'dark': const Color(0xFF34518E),
    },
    KoeColorName.eggplant: {
      'light': const Color(0xFFD9B7E5),
      'main': const Color(0xFFA349A4),
      'dark': const Color(0xFF823A83),
    },
    KoeColorName.dragonfruit: {
      'light': const Color(0xFFF8CCF0),
      'main': const Color(0xFFD46BFF),
      'dark': const Color(0xFFB055CC),
    },
    KoeColorName.ocean: {
      'light': const Color(0xFFB3E5FC),
      'main': const Color(0xFF2196F3),
      'dark': const Color(0xFF1976D2),
    },
    KoeColorName.sunset: {
      'light': const Color(0xFFFFCCBC),
      'main': const Color(0xFFFF5722),
      'dark': const Color(0xFFE64A19),
    },
    KoeColorName.forest: {
      'light': const Color(0xFFC8E6C9),
      'main': const Color(0xFF4CAF50),
      'dark': const Color(0xFF388E3C),
    },
  };

  /// Get colors by palette name
  static Map<String, Color> get(KoeColorName name) => palettes[name]!;

  /// Get a specific shade (light, main, dark)
  static Color shade(KoeColorName name, String shade) =>
      palettes[name]![shade]!;
}
