import 'database_helper.dart';
import 'proxylistener.dart';

class Artist {
  late final int artistId;
  final String artistName;
  static final dbHelper = DatabaseHelper.getInstance();

  Artist(this.artistName) {
    _initialize();
  }

  
  Future<void> _initialize() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'Artist',
      columns: ['artist_id'],
      where: 'artist_name = ?',
      whereArgs: [artistName],
      limit: 1,
    );

    if (result.isNotEmpty) {
      artistId = result.first['artist_id'] as int;
    } else {
      artistId = await _createNewArtist();
    }
  }

  Future<int> _createNewArtist() async {
    final db = await dbHelper.database;
    return await db.insert('Artist', {'artist_name': artistName});
  }

  
  Future<List<ProxyListener>> getSubscribers() async {
  final db = await dbHelper.database;
  final subscriptions = await db.query(
    'Subscription',
    where: 'artist_id = ?',
    whereArgs: [artistId],
  );

  final subscribers = <ProxyListener>[];
  for (final sub in subscriptions) {
    final userId = sub['user_id'] as int;
    final proxy = await ProxyListener.create(userId);
    subscribers.add(proxy);
  }

  return subscribers;
}

  Future<void> sendNewSongNotification() async {
    final subscribers = await getSubscribers();
    final message = '$artistName has uploaded a new song';

    for (final listener in subscribers) {
      await listener.addNotification(message);
    }
  }

  static Future<void> subscribe(int artistId, int userId) async {
    final db = await dbHelper.database;
    await db.insert(
      'Subscription',
      {
        'artist_id': artistId,
        'user_id': userId,
      },
    );
  }
}







