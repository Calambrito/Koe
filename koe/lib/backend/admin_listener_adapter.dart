import 'listener.dart';
import 'database_helper.dart';
import 'theme.dart';

class AdminListenerAdapter {
  final Listener _listener;

  AdminListenerAdapter._(this._listener);

  // loading by userId
  static Future<AdminListenerAdapter> forUserId(String userId) async {
    final listener = await Listener.loadUserById(userId);
    return AdminListenerAdapter._(listener);
  }

  // loading by username
  static Future<AdminListenerAdapter> forUserName(String userName) async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception('User "$userName" not found');
    }

    final userId = rows.first['user_id'] as String;
    final listener = await Listener.loadUserById(userId);
    return AdminListenerAdapter._(listener);
  }

  // user info
  String get userID => _listener.userID;
  String get username => _listener.username;
  KoeTheme get theme => _listener.theme;

  List<String> get userPlaylists => _listener.playlists;
  List<String> get userNotifications => _listener.notifications;

  // user actions
  Future<void> userCreatePlaylist(String playlistID, String playlistName) =>
      _listener.createPlaylist(playlistID, playlistName);

  Future<void> userDeletePlaylist(String playlistID) =>
      _listener.deletePlaylist(playlistID);

  Future<void> userAddNotification(String message) =>
      _listener.addNotification(message);
}
