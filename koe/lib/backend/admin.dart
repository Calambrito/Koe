import 'user.dart';
import 'database_helper.dart';
import 'song.dart';

class Admin extends User {
  Admin({required super.userID, required super.username, required super.theme});
  static final dbHelper = DatabaseHelper.getInstance();
  
  Future<int> addSong({
    required String songName,
    required String url,
    String? duration,
    String? genre,
    required String artistName, 
  }) async {
    final db = await dbHelper.database;

    final artistRows = await db.query(
      'Artist',
      where: 'artist_name = ?',
      whereArgs: [artistName],
      limit: 1,
    );

    int artistId;
    if (artistRows.isNotEmpty) {
      artistId = artistRows.first['artist_id'] as int;
    } else {
      artistId = await db.insert('Artist', {
        'artist_name': artistName,
      });
    }

    final songId = await db.insert('Songs', {
      'song_name': songName,
      'url': url,
      'duration': duration,
      'genre': genre,
      'artist_id': artistId,
    });
    
    return songId;
  }

  Future<void> removeSong(Song song) async {
    final db = await dbHelper.database;

    await db.delete(
      'Playlist_Songs',
      where: 'song_id = ?',
      whereArgs: [song.songId],
    );

    await db.delete('Songs', where: 'song_id = ?', whereArgs: [song.songId]);
  }
}