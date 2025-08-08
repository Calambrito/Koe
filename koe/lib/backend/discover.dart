import 'search_strategy.dart';
import 'song.dart';

class Discover {
  late SongSearchStrategy _strategy;

  void setStrategy(SongSearchStrategy strategy) {
    _strategy = strategy;
  }

  Future<List<Song>> search(String query) {
    return _strategy.search(query);
  }
}

/*import 'search_strategy.dart';
import 'song.dart';
class Discover {
  late SongSearchStrategy _strategy;

  void setStrategy(SongSearchStrategy strategy) {
    _strategy = strategy;
  }

  Future<List<Map<String, dynamic>>> search(String query) {
    return _strategy.search(query);
  }
}
*/

