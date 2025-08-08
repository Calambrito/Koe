
import 'search_strategy.dart';
import 'database_helper.dart';

class ArtistSearchStrategy implements SongSearchStrategy {
  final DatabaseHelper dbHelper = DatabaseHelper.getInstance();

  @override
  Future<List<Map<String, dynamic>>> search(String query) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT Songs.*, Artist.artist_name
      FROM Songs
      JOIN Artist ON Songs.artist_id = Artist.artist_id
      WHERE Artist.artist_name LIKE ?
    ''', ['%$query%']);
  }
}

