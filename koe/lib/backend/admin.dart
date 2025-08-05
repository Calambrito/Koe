import 'user.dart';
import 'database_helper.dart';
import 'song.dart';
import 'generator.dart';

class Admin extends User {
  Admin({required super.userID, required super.username, required super.theme});
  static final idGen = IdGenerator.getInstance();
  static final dbHelper = DatabaseHelper.getInstance();
  
  Future<String> addSong({
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

    String artistId;
    if (artistRows.isNotEmpty) {
      artistId = artistRows.first['artist_id'] as String;
    } else {
     
      artistId = await idGen.generateNextArtistId();
      await db.insert('Artist', {
        'artist_id': artistId,
        'artist_name': artistName,
      });
    }

    
    final songId = await idGen.generateNextSongId();
    final song = Song(
      songId: songId,
      songName: songName,
      url: url,
      duration: duration,
      genre: genre,
      artistId: artistId,
    );

    await db.insert('Songs', song.toMap());
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
