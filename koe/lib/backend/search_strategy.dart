import 'song.dart';
import 'database_helper.dart';

abstract class SongSearchStrategy {
  Future<List<Song>> search(String query);
}

class SongNameSearchStrategy implements SongSearchStrategy {
  final DatabaseHelper dbHelper = DatabaseHelper.getInstance();

  @override
  Future<List<Song>> search(String query) async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT Songs.*, Artist.artist_name
      FROM Songs
      JOIN Artist ON Songs.artist_id = Artist.artist_id
      WHERE Songs.song_name LIKE ?
    ''', ['%$query%']);

    return results.map((map) => Song.fromMap(map)).toList();
  }
}

class ArtistSearchStrategy implements SongSearchStrategy {
  final DatabaseHelper dbHelper = DatabaseHelper.getInstance();

  @override
  Future<List<Song>> search(String query) async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT Songs.*, Artist.artist_name
      FROM Songs
      JOIN Artist ON Songs.artist_id = Artist.artist_id
      WHERE Artist.artist_name LIKE ?
    ''', ['%$query%']);

    return results.map((map) => Song.fromMap(map)).toList();
  }
}

class GenreSearchStrategy implements SongSearchStrategy {
  final DatabaseHelper dbHelper = DatabaseHelper.getInstance();

  @override
  Future<List<Song>> search(String query) async {
    final db = await dbHelper.database;
    final results = await db.rawQuery('''
      SELECT Songs.*, Artist.artist_name
      FROM Songs
      JOIN Artist ON Songs.artist_id = Artist.artist_id
      WHERE Songs.genre LIKE ?
    ''', ['%$query%']);

    return results.map((map) => Song.fromMap(map)).toList();
  }
}
