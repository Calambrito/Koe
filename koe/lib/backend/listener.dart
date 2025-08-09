import 'user.dart';
import 'database_helper.dart';
import 'theme.dart';

class Listener extends User {
  List<int> playlists;
  List<String> notifications;
  static final dbHelper = DatabaseHelper.getInstance();

  Listener({
    required super.userID,
    required super.username,
    required super.theme,
    List<int>? playlists,
    List<String>? notifications,
  })  : playlists = playlists ?? [],
        notifications = notifications ?? [] {
    _loadPlaylists();
    _loadNotifications();
  }

  // Static method to load user by ID
  static Future<Listener> loadUserById(int userId) async {
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
    return Listener(
      userID: user['user_id'] as int,
      username: user['user_name'] as String,
      theme: _stringToTheme(user['theme'] as String?),
      playlists: await _loadUserPlaylists(userId),
      notifications: await _loadUserNotifications(userId),
    );
  }

  static KoeTheme _stringToTheme(String? themeString) {
    if (themeString == null) return KoeTheme.green;
    return KoeTheme.values.firstWhere(
      (t) => t.name == themeString,
      orElse: () => KoeTheme.green,
    );
  }

  static Future<List<int>> _loadUserPlaylists(int userId) async {
    final db = await dbHelper.database;
    final playlistsData = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return playlistsData
        .map((p) => p['playlist_id'] as int)
        .toList();
  }

  static Future<List<String>> _loadUserNotifications(int userId) async {
    final db = await dbHelper.database;
    final notificationsData = await db.query(
      'Notification',
      columns: ['message'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return notificationsData
        .map((n) => n['message'] as String)
        .toList();
  }

  Future<void> _loadPlaylists() async {
    playlists = await _loadUserPlaylists(userID);
  }

  Future<void> _loadNotifications() async {
    notifications = await _loadUserNotifications(userID);
  }

  Future<void> createPlaylist(String playlistName) async {
    final db = await dbHelper.database;
    final playlistId = await db.insert('Playlist', {
      'playlist_name': playlistName,
      'user_id': userID,
    });
    playlists.add(playlistId);
  }

  Future<void> addNotification(String message) async {
    final db = await dbHelper.database;
    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });
    notifications.add(message);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await dbHelper.database;
    
    // Delete songs from playlist first
    await db.delete(
      'Playlist_Songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    
    // Then delete the playlist
    await db.delete(
      'Playlist',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    
    playlists.remove(playlistId);
  }
}