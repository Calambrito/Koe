import 'database_helper.dart';
import 'facades.dart';
import 'theme.dart';
import 'discover.dart';
import 'user.dart';

class Listener extends User {
  Listener._internal({
    required super.userID,
    required super.username,
    required super.theme,
  });

 
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


  Future<void> loadAll() async {
    playlists = await Facades.loadPlaylists(userID);
    notifications = await Facades.loadNotifications(userID);
    artists = await Facades.loadArtists();
  }

  Future<void> createPlaylist(String playlistName) async {
    final db = await DatabaseHelper.getInstance().database;
    final playlistId = await db.insert('Playlist', {
      'playlist_name': playlistName,
      'user_id': userID,
    });
    playlists.add(playlistId);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await DatabaseHelper.getInstance().database;

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

    playlists.remove(playlistId);
  }
}


