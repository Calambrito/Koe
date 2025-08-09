import 'package:koe/backend/discover.dart';
import 'discover.dart';
import 'user.dart';
import 'database_helper.dart';
import 'theme.dart';

class Listener extends User {
  List<int>? _playlists;
  List<String>? _notifications;
  List<String>? _artists;
  final Discover _discover = Discover();

  static final dbHelper = DatabaseHelper.getInstance();

  Listener({
    required super.userID,
    required super.username,
    required super.theme,
  });

  List<int> get playlists => _playlists ?? [];
  List<String> get notifications => _notifications ?? [];
  List<String> get artists => _artists ?? [];
  Discover get discover => _discover;
  


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
    );
  }

  static KoeTheme _stringToTheme(String? themeString) {
    if (themeString == null) return KoeTheme.green;
    return KoeTheme.values.firstWhere(
      (t) => t.name == themeString,
      orElse: () => KoeTheme.green,
    );
  }

  Future<String> getUsername() async {
    final db = await dbHelper.database;
    final userRow = await db.query(
      'User',
      where: 'user_id = ?',
      whereArgs: [userID],
      limit: 1,
    );
    if (userRow.isNotEmpty) {
      return userRow.first['user_name'] as String;
    }
    throw Exception('User not found');
  }

  Future<void> loadPlaylists() async {
    if (_playlists != null) return;

    final db = await dbHelper.database;
    final playlistsData = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userID],
    );

    _playlists = playlistsData.map((p) => p['playlist_id'] as int).toList();
  }

  Future<void> loadNotifications() async {
    if (_notifications != null) return;

    final db = await dbHelper.database;
    final notificationsData = await db.query(
      'Notification',
      columns: ['message'],
      where: 'user_id = ?',
      whereArgs: [userID],
    );

    _notifications = notificationsData.map((n) => n['message'] as String).toList();
  }

  Future<void> loadArtists() async {
    if (_artists != null) return;

    final db = await dbHelper.database;
    final artistsData = await db.query(
      'Artist',
      columns: ['artist_name'],
    );

    _artists = artistsData.map((a) => a['artist_name'] as String).toList();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadPlaylists(),
      loadNotifications(),
      loadArtists(),
    ]);
  }

  Future<void> createPlaylist(String playlistName) async {
    final db = await dbHelper.database;
    final playlistId = await db.insert('Playlist', {
      'playlist_name': playlistName,
      'user_id': userID,
    });

    _playlists ??= [];
    _playlists!.add(playlistId);
  }

  Future<void> addNotification(String message) async {
    final db = await dbHelper.database;
    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });

    _notifications ??= [];
    _notifications!.add(message);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await dbHelper.database;

    await db.delete(
      'Playlist_Songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    await db.delete(
      'Playlist',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    _playlists?.remove(playlistId);
  }
}
