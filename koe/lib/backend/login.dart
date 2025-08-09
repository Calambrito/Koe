import 'database_helper.dart';

class LoginManager {
  static final dbHelper = DatabaseHelper.getInstance();

  static Future<int> addUser({
    required String userName,
    required String password,
    bool isAdmin = false,
  }) async {
    final db = await dbHelper.database;

    final existingUser = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Username "$userName" already exists');
    }
    
    return await db.insert('User', {
      'user_name': userName.toLowerCase(),
      'password': password,
      'is_admin': isAdmin ? 1 : 0
    });
  }

  static Future<void> removeUser(int userId) async {
    final db = await dbHelper.database;

    await db.delete(
      'Subscription',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await db.delete(
      'Notification',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final playlists = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    for (final playlist in playlists) {
      final playlistId = playlist['playlist_id'] as int;
      await db.delete(
        'Playlist_Songs',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
    }

    await db.delete(
      'Playlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await db.delete(
      'User',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  static Future<int?> authenticate(
    String username, 
    String password
  ) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'User',
      columns: ['user_id'],
      where: 'user_name = ? AND password = ?',
      whereArgs: [username.toLowerCase(), password],
      limit: 1,
    );

    return result.isNotEmpty ? result.first['user_id'] as int? : null;
  }

  static Future<bool> isAdmin(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'User',
      columns: ['is_admin'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    return result.isNotEmpty && result.first['is_admin'] == 1;
  }

  static Future<bool> userExists(String userName) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'User',
      columns: ['user_id'],
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}