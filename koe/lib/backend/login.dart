import 'database_helper.dart';
import 'generator.dart';

class LoginManager {
  static final dbHelper = DatabaseHelper.getInstance();
  static final idGen = IdGenerator.getInstance();

  // Add a new user to the database
  static Future<String> addUser({
    required String userName,
    required String password,
    bool isAdmin = false,
  }) async {
    final db = await dbHelper.database;

    // Check for existing username
    final existingUser = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Username "$userName" already exists');
    }

    final userId = await idGen.generateNextUserId();
    
    await db.insert('User', {
      'user_id': userId,
      'user_name': userName.toLowerCase(),
      'password': password,
      'is_admin': 0
    });
    
    return userId;
  }

  // Remove a user from the database
  static Future<void> removeUser(String userId) async {
    final db = await dbHelper.database;

    // Delete user's subscriptions
    await db.delete(
      'Subscription',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Delete user's notifications
    await db.delete(
      'Notification',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Get user's playlists
    final playlists = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Delete songs from each playlist
    for (final playlist in playlists) {
      final playlistId = playlist['playlist_id'] as String;
      await db.delete(
        'Playlist_Songs',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
    }

    // Delete user's playlists
    await db.delete(
      'Playlist',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Finally delete the user
    await db.delete(
      'User',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Authenticate user credentials
  static Future<String?> authenticate(
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

    return result.isNotEmpty ? result.first['user_id'] as String? : null;
  }

  // Check if user is admin
  static Future<bool> isAdmin(String userId) async {
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
}