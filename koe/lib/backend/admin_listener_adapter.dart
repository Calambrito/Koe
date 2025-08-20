import 'listener.dart';
import 'database_helper.dart';
import 'theme.dart';

class AdminListenerAdapter {
  final Listener _listener;

  AdminListenerAdapter._(this._listener);

  // loading by user id
  static Future<AdminListenerAdapter> forUserId(int userId) async {
    final listener = await Listener.create(userId);
    return AdminListenerAdapter._(listener);
  }

  // loading by username
  static Future<AdminListenerAdapter> forUserName(String userName) async {
    final db = await DatabaseHelper.getInstance().database;

    // Special handling for admin user - don't convert to lowercase
    final whereArgs = userName == '99999999999'
        ? [userName]
        : [userName.toLowerCase()];

    final rows = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: whereArgs,
      limit: 1,
    );

    if (rows.isEmpty) {
      throw Exception('User "$userName" not found');
    }

    final userId = rows.first['user_id'] as int;
    final listener = await Listener.create(userId);
    return AdminListenerAdapter._(listener);
  }

  // user info
  int get userID => _listener.userID;
  String get username => _listener.username;
  KoeTheme get theme => _listener.theme;

  // Expose the underlying Listener for UI compatibility
  Listener get listener => _listener;

  List<int> get playlists => _listener.playlists;
  List<String> get notifications => _listener.notifications;

  // user methods
  Future<void> userCreatePlaylist(String playlistName) =>
      _listener.createPlaylist(playlistName);

  Future<void> userDeletePlaylist(int playlistId) =>
      _listener.deletePlaylist(playlistId);
}
