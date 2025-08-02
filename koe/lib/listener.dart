import 'user.dart';
import 'database_helper.dart';

class Listener extends User {
  final List<String> playlists;
  final List<String> notifications;

  Listener({
    required super.userID,
    required super.username,
    required super.theme,
    this.playlists = const [],
    this.notifications = const [],
  });

  Future<void> createPlaylist(String playlistID) async {
    playlists.add(playlistID);
    
    final db = await DatabaseHelper().database;
    await db.insert('UserPlaylists', {
      'user_id': userID,
      'playlist_id': playlistID,
    });
  }

  Future<void> addNotification(String notification) async {
    final db = await DatabaseHelper().database;
    notifications.add(notification);
    
    await db.insert('Notifications', {
      'user_id': userID,
      'notification': notification,
    });
  }

  Future<void> deletePlaylist(String playlistID) async {
    playlists.remove(playlistID);
    
    final db = await DatabaseHelper().database;
    await db.delete(
      'UserPlaylists',
      where: 'user_id = ? AND playlist_id = ?',
      whereArgs: [userID, playlistID],
    );
  }
}