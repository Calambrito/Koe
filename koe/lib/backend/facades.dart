import 'listener.dart';
import 'theme.dart';
import 'database_helper.dart';


class Facades {
  static Future<Map<String, dynamic>> loadUserById(int userId) async {
  final dbHelper = DatabaseHelper.getInstance();
  final db = await dbHelper.database;

  final userData = await db.query(
    'User',
    where: 'user_id = ?',
    whereArgs: [userId],
    limit: 1,
  );

  if (userData.isEmpty) {
    throw Exception('User with ID $userId not found');
  }

  final user = userData.first;
  return {
    'user_id': user['user_id'] as int,
    'user_name': user['user_name'] as String,
    'theme': _stringToTheme(user['theme'] as String?),
  };
}



  static KoeTheme _stringToTheme(String? themeString) {
    if (themeString == null) return KoeTheme.green;
    return KoeTheme.values.firstWhere(
      (t) => t.name == themeString,
      orElse: () => KoeTheme.green,
    );
  }

  static Future<List<int>> loadPlaylists(int userID) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;

    final playlistsData = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userID],
    );

    return playlistsData.map((p) => p['playlist_id'] as int).toList();
  }

  static Future<List<String>> loadNotifications(int userID) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;

    final notificationsData = await db.query(
      'Notification',
      columns: ['message'],
      where: 'user_id = ?',
      whereArgs: [userID],
    );

    return notificationsData.map((n) => n['message'] as String).toList();
  }

  static Future<List<String>> loadArtists() async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;

    final artistsData = await db.query(
      'Artist',
      columns: ['artist_name'],
    );

    return artistsData.map((a) => a['artist_name'] as String).toList();
  }


}