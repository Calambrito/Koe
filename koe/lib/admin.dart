import 'user.dart';
import 'database_helper.dart';
import 'song.dart';

class Admin extends User {
  Admin({
    required super.userID,
    required super.username,
    required super.theme,
  });

  Future<String> addSong({
    required String songName,
    required String url,
    String? duration,
    String? genre,
    String? artistId,
  }) async {
    final dbHelper = DatabaseHelper();
    final songId = await dbHelper.getNextSongId();
    
    final song = Song(
      songId: songId,
      songName: songName,
      url: url,
      duration: duration,
      genre: genre,
      artistId: artistId,
    );

    final db = await dbHelper.database;
    await db.insert('Songs', song.toMap());
    
    return songId;
  }

  Future<void> removeSong(Song song) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    
    await db.delete(
      'Playlist_Songs',
      where: 'song_id = ?',
      whereArgs: [song.songId],
    );
    
    await db.delete(
      'Songs',
      where: 'song_id = ?',
      whereArgs: [song.songId],
    );
  }
}