import 'database_helper.dart';
import 'proxy_listener.dart';
import 'facades.dart';
import 'theme.dart';

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

  
  Future<List<ListenerBase>> getSubscribers() async {
    final db = await dbHelper.database;
    final subscriptions = await db.query(
      'Subscription',
      where: 'artist_id = ?',
      whereArgs: [artistId],
    );

    final subscribers = <ListenerBase>[];
    for (final sub in subscriptions) {
      final userId = sub['user_id'] as int;
      try {
        final userMap = await Facades.loadUserById(userId);

        final proxy = ProxyListener(
          userID: userMap['user_id'] as int,
          username: userMap['user_name'] as String,
          theme: userMap['theme'] as KoeTheme,
        );

        await proxy.loadFromDB();

        subscribers.add(proxy);
      } catch (e) {
        rethrow;
      }
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
}







