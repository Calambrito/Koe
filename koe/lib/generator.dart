class IdGenerator {
  // Generate user ID in format UAXA12
  static String generateUserId(String lastId) {
    return _generateId(lastId, 'U');
  }

  // Generate song ID in format SAXA12
  static String generateSongId(String lastId) {
    return _generateId(lastId, 'S');
  }

  static String generatePlaylistId(String lastId) {
    return _generateId(lastId, 'P');
  }

  static String _generateId(String lastId, String prefix) {
    // Validate ID format
    if (lastId.length != 6 || 
        lastId[0] != prefix || 
        !_isAlpha(lastId.substring(1, 4)) || 
        !_isNumeric(lastId.substring(4))) {
      return '${prefix}AAA00'; // Fallback to initial value
    }

    // Extract components
    final alphaPart = lastId.substring(1, 4);
    final numericPart = lastId.substring(4);
    
    // Convert to workable values
    int number = int.parse(numericPart);
    String newAlpha = alphaPart;
    
    // Increment logic
    if (number < 99) {
      number++;
    } else {
      number = 0;
      newAlpha = _incrementAlpha(alphaPart);
    }

    return '$prefix$newAlpha${number.toString().padLeft(2, '0')}';
  }

  static String _incrementAlpha(String alpha) {
    final chars = alpha.codeUnits.toList();
    int pos = 2; // Start from rightmost character
    
    while (pos >= 0) {
      if (chars[pos] < 90) { // 90 = 'Z'
        chars[pos]++;
        break;
      } else {
        chars[pos] = 65; // 65 = 'A'
        pos--; // Carry to next position
      }
    }
    
    // Handle AAA -> AAZ -> ABA transition
    if (pos < 0) {
      return 'AAA'; // Reset after ZZZ
    }
    
    return String.fromCharCodes(chars);
  }

  static bool _isAlpha(String str) {
    return str.length == 3 &&
        str.codeUnits.every((c) => c >= 65 && c <= 90); // A-Z
  }

  static bool _isNumeric(String str) {
    return str.length == 2 &&
        str.codeUnits.every((c) => c >= 48 && c <= 57); // 0-9
  }
}