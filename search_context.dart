import 'search_strategy.dart';
class SongSearchContext {
  late SongSearchStrategy _strategy;

  void setStrategy(SongSearchStrategy strategy) {
    _strategy = strategy;
  }

  Future<List<Map<String, dynamic>>> search(String query) {
    return _strategy.search(query);
  }
}

