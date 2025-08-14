import 'discover.dart';
import 'user.dart';
import 'database_helper.dart';
import 'theme.dart';
import 'facades.dart';

class Listener extends User {
  List<int>? _playlists;
  List<String>? _notifications;
  List<String>? _artists;
  final Discover _discover = Discover();

  Listener._internal({
    required super.userID,
    required super.username,
    required super.theme,
  });

  // Factory constructor that loads user data and playlists/etc.
  static Future<Listener> create(int userID) async {
    final userMap = await Facades.loadUserById(userID);

    final listener = Listener._internal(
      userID: userMap['user_id'] as int,
      username: userMap['user_name'] as String,
      theme: userMap['theme'] as KoeTheme,
    );

    await listener.loadAll();
    return listener;
  }

  List<int> get playlists => _playlists ?? [];
  List<String> get notifications => _notifications ?? [];
  List<String> get artists => _artists ?? [];
  Discover get discover => _discover;

  Future<String> getUsername() async {
    final dbHelper = DatabaseHelper.getInstance();
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

  Future<void> loadAll() async {
    _playlists = await Facades.loadPlaylists(userID);
    _notifications = await Facades.loadNotifications(userID);
    _artists = await Facades.loadArtists();
  }

  Future<void> createPlaylist(String playlistName) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;
    final playlistId = await db.insert('Playlist', {
      'playlist_name': playlistName,
      'user_id': userID,
    });

    _playlists ??= [];
    _playlists!.add(playlistId);
  }

  Future<void> addNotification(String message) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;
    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });

    _notifications ??= [];
    _notifications!.add(message);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final dbHelper = DatabaseHelper.getInstance();
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
