// filepath: lib/backend/database_helper.dart
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper getInstance() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'music_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_name TEXT NOT NULL,
        password TEXT NOT NULL,
        is_admin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Artist (
        artist_id INTEGER PRIMARY KEY AUTOINCREMENT,
        artist_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE Songs (
        song_id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_name TEXT NOT NULL,
        url TEXT NOT NULL,
        duration TEXT,
        genre TEXT,
        artist_id INTEGER,
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist (
        playlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_name TEXT NOT NULL,
        user_id INTEGER,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Notification (
        notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        message TEXT,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Subscription (
        user_id INTEGER,
        artist_id INTEGER,
        PRIMARY KEY(user_id, artist_id),
        FOREIGN KEY(user_id) REFERENCES User(user_id),
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist_Songs (
        playlist_id INTEGER,
        song_id INTEGER,
        PRIMARY KEY(playlist_id, song_id),
        FOREIGN KEY(playlist_id) REFERENCES Playlist(playlist_id),
        FOREIGN KEY(song_id) REFERENCES Songs(song_id)
      )
    ''');

    // Seed some data
    final artist1 = await db.insert('Artist', {
      'artist_name': 'John Doe',
    });

    final artist2 = await db.insert('Artist', {
      'artist_name': 'NEFFEX',
    });

    await db.insert('Songs', {
      'song_name': 'Sample Song 1',
      'url': 'https://example.com/song1.mp3',
      'duration': '3:45',
      'genre': 'Pop',
      'artist_id': artist1,
    });

    await db.insert('Songs', {
      'song_name': 'Another Tune',
      'url': 'https://example.com/song2.mp3',
      'duration': '4:10',
      'genre': 'Rock',
      'artist_id': artist1,
    });

    // FIXED: artist_id must be the integer id (artist2), not a string.
    await db.insert('Songs', {
      'song_name': 'As You Fade Away',
      'url':
          'https://happysoulmusic.com/wp-content/grand-media/audio/As_You_Fade_Away_-_NEFFEX.mp3',
      'duration': '4:16',
      'genre': 'Pop',
      'artist_id': artist2,
    });

  int debugUserId;
  final existingDebug = await db.query(
    'User',
    columns: ['user_id'],
    where: 'user_name = ?',
    whereArgs: ['a'],
  );

  if (existingDebug.isNotEmpty) {
    debugUserId = existingDebug.first['user_id'] as int;
  } else {
    debugUserId = await db.insert('User', {
      'user_name': 'a',
      'password': 'a',
      'is_admin': 0,
    });
  }

  // --- seed notifications for debug user 'a' only if none exist (avoids duplicates) ---
  final countResult = await db.rawQuery(
    'SELECT COUNT(*) AS count FROM Notification WHERE user_id = ?',
    [debugUserId],
  );
  final existingNotifsCount = countResult.isNotEmpty
      ? int.tryParse(countResult.first.values.first.toString()) ?? 0
      : 0;

  if (existingNotifsCount == 0) {
    await db.insert('Notification', {
      'user_id': debugUserId,
      'message': 'Welcome to Koe! Check out our curated playlists.',
    });
    await db.insert('Notification', {
      'user_id': debugUserId,
      'message': 'New single from The Echoes just dropped — listen now!',
    });
    await db.insert('Notification', {
      'user_id': debugUserId,
      'message': 'Your playlist "Chill Vibes" reached 100 followers! 🎉',
    });
    await db.insert('Notification', {
      'user_id': debugUserId,
      'message': 'Concert near you: Luna Park — tickets available.',
    });
    await db.insert('Notification', {
      'user_id': debugUserId,
      'message': 'Recommended for you: Your Discover mix is ready.',
    });
  }

  // optional debug output to verify seeding
  final afterCountRes = await db.rawQuery(
    'SELECT COUNT(*) AS count FROM Notification WHERE user_id = ?',
    [debugUserId],
  );
  final notifCount = afterCountRes.isNotEmpty
      ? int.tryParse(afterCountRes.first.values.first.toString()) ?? 0
      : 0;
  debugPrint('Seeded notifications for debug user "a" (user_id=$debugUserId): $notifCount rows');
}

  Future<Map<String, dynamic>> idToSong(int songId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Songs',
      where: 'song_id = ?',
      whereArgs: [songId],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      throw Exception('Song with ID $songId not found');
    }
  }

  static Future<List<Map<String, dynamic>>> showcaseSongs(Database db) async {
  try {
    final List<Map<String, dynamic>> songs = await db.query(
      'Songs',
      columns: ['song_id', 'song_name', 'url', 'duration', 'genre', 'artist_id'],
      limit: 30,
    );

    return songs;
  } catch (e) {
    debugPrint('Error fetching songs: $e');
    return [];
  }
}
}
