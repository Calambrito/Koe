import 'song.dart';

abstract class SongSearchStrategy {
  Future<List<Song>> search(String query);
}


