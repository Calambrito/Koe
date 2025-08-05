import 'database_helper.dart';

class IdGenerator {
  static final IdGenerator _instance = IdGenerator._internal();
  
  IdGenerator._internal();
  
  static IdGenerator getInstance() {
  return _instance;
  }
  
  final dbHelper = DatabaseHelper.getInstance();

  
  Future<String> generateNextUserId() async {
    final db = await dbHelper.database;
    final lastUser = await db.rawQuery(
      'SELECT user_id FROM User ORDER BY user_id DESC LIMIT 1'
    );
    final lastId = lastUser.isEmpty ? 'UZZZ99' : lastUser.first['user_id'] as String;
    return _generateId(lastId, 'U');
  }

  Future<String> generateNextSongId() async {
    final db = await dbHelper.database;
    final lastSong = await db.rawQuery(
      'SELECT song_id FROM Songs ORDER BY song_id DESC LIMIT 1'
    );
    final lastId = lastSong.isEmpty ? 'SZZZ99' : lastSong.first['song_id'] as String;
    return _generateId(lastId, 'S');
  }

  Future<String> generateNextPlaylistId() async {
    final db = await dbHelper.database;
    final lastPlaylist = await db.rawQuery(
      'SELECT playlist_id FROM Playlist ORDER BY playlist_id DESC LIMIT 1'
    );
    final lastId = lastPlaylist.isEmpty ? 'PZZZ99' : lastPlaylist.first['playlist_id'] as String;
    return _generateId(lastId, 'P');
  }
  
  Future<String> generateNextArtistId() async {
    final db = await dbHelper.database;
    final lastArtist = await db.rawQuery(
      'SELECT artist_id FROM Artist ORDER BY artist_id DESC LIMIT 1',
    );
    final lastId = lastArtist.isEmpty
        ? 'AZZZ99'
        : lastArtist.first['artist_id'] as String;
    return _generateId(lastId, 'A');
  }

  // --- PRIVATE HELPERS ---
  
  String _generateId(String lastId, String prefix) {
    if (lastId.length != 6 || 
        lastId[0] != prefix || 
        !_isAlpha(lastId.substring(1, 4)) || 
        !_isNumeric(lastId.substring(4))) {
      return '${prefix}AAA00';
    }

    final alphaPart = lastId.substring(1, 4);
    final numericPart = lastId.substring(4);
    
    int number = int.parse(numericPart);
    String newAlpha = alphaPart;
    
    if (number < 99) {
      number++;
    } else {
      number = 0;
      newAlpha = _incrementAlpha(alphaPart);
    }

    return '$prefix$newAlpha${number.toString().padLeft(2, '0')}';
  }

  String _incrementAlpha(String alpha) {
    final chars = alpha.codeUnits.toList();
    int pos = 2;
    
    while (pos >= 0) {
      if (chars[pos] < 90) {
        chars[pos]++;
        break;
      } else {
        chars[pos] = 65;
        pos--;
      }
    }
    
    if (pos < 0) {
      return 'AAA';
    }
    
    return String.fromCharCodes(chars);
  }

  bool _isAlpha(String str) {
    return str.length == 3 &&
        str.codeUnits.every((c) => c >= 65 && c <= 90);
  }

  bool _isNumeric(String str) {
    return str.length == 2 &&
        str.codeUnits.every((c) => c >= 48 && c <= 57);
  }
}