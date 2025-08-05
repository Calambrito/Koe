import 'database_helper.dart';
import 'generator.dart';
import 'listener.dart';

class Artist {
  late final String artistId;
  final String artistName;
  static final idGen = IdGenerator.getInstance();
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
      artistId = result.first['artist_id'] as String;
    } else {
      artistId = await _createNewArtist();
    }
  }

  Future<String> _createNewArtist() async {
    final db = await dbHelper.database;
    final newId = idGen.generateNextArtistId();
    await db.insert('Artist', {'artist_id': newId, 'artist_name': artistName});

    return newId;
  }

  Future<List<Listener>> getSubscribers() async {
    final db = await dbHelper.database;
    final subscriptions = await db.query(
      'Subscription',
      where: 'artist_id = ?',
      whereArgs: [artistId],
    );

    final subscribers = <Listener>[];
    for (final sub in subscriptions) {
      final userId = sub['user_id'] as String;
      try {
        subscribers.add(await Listener.loadUserById(userId));
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
