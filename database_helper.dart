import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'generator.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final idGen = IdGenerator.getInstance();

  DatabaseHelper._internal();

  static DatabaseHelper getInstance() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database, set the path and open it
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'music_app.db');

    // Open database, version 1, with onCreate callback
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Called only once when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables with schema definitions
    await db.execute('''
      CREATE TABLE User (
        user_id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        password TEXT NOT NULL,
        theme TEXT DEFAULT 'green',
        is_admin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Artist (
        artist_id TEXT PRIMARY KEY,
        artist_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE Songs (
        song_id TEXT PRIMARY KEY,
        song_name TEXT NOT NULL,
        url TEXT NOT NULL,
        duration TEXT,
        genre TEXT,
        artist_id TEXT,
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist (
        playlist_id TEXT PRIMARY KEY,
        playlist_name TEXT NOT NULL,
        user_id TEXT,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Notification (
        notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Subscription (
        user_id TEXT,
        artist_id TEXT,
        PRIMARY KEY(user_id, artist_id),
        FOREIGN KEY(user_id) REFERENCES User(user_id),
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist_Songs (
        playlist_id TEXT,
        song_id TEXT,
        PRIMARY KEY(playlist_id, song_id),
        FOREIGN KEY(playlist_id) REFERENCES Playlist(playlist_id),
        FOREIGN KEY(song_id) REFERENCES Songs(song_id)
      )
    ''');

    // Insert initial data into Artist table
    await db.insert('Artist', {
      'artist_id': 'ARTIST1',
      'artist_name': 'John Doe',
    });

    // Insert the real artist "NEFFEX" into Artist table
    await db.insert('Artist', {
      'artist_id': 'NEFFEX',
      'artist_name': 'NEFFEX',
    });

    // Insert sample songs linked to ARTIST1
    await db.insert('Songs', {
      'song_id': 'SONG1',
      'song_name': 'Sample Song 1',
      'url': 'https://example.com/song1.mp3',
      'duration': '3:45',
      'genre': 'Pop',
      'artist_id': 'ARTIST1',
    });

    await db.insert('Songs', {
      'song_id': 'SONG2',
      'song_name': 'Another Tune',
      'url': 'https://example.com/song2.mp3',
      'duration': '4:10',
      'genre': 'Rock',
      'artist_id': 'ARTIST1',
    });

    // Insert your real song "As You Fade Away" linked to NEFFEX artist
    await db.insert('Songs', {
      'song_id': 'SONG5',
      'song_name': 'As You Fade Away',
      'url': 'https://happysoulmusic.com/wp-content/grand-media/audio/As_You_Fade_Away_-_NEFFEX.mp3',
      'duration': '4:16',
      'genre': 'Pop',
      'artist_id': 'NEFFEX',  // This must match the artist_id in Artist table
    });

    // Insert a sample user with admin privileges
    await db.insert('User', {
      'user_id': 'ADMIN0',
      'user_name': 'cxladmin',
      'password': 'a212223',
      'is_admin': 1,
    });
  }

   // Song and playlist operations
  Future<Map<String, dynamic>> idToSong(String songId) async {
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

 
}


/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'generator.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final idGen = IdGenerator.getInstance();
  
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
        user_id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        password TEXT NOT NULL,
        theme TEXT DEFAULT 'green',
        is_admin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Artist (
        artist_id TEXT PRIMARY KEY,
        artist_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE Songs (
        song_id TEXT PRIMARY KEY,
        song_name TEXT NOT NULL,
        url TEXT NOT NULL,
        duration TEXT,
        genre TEXT,
        artist_id TEXT,
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist (
        playlist_id TEXT PRIMARY KEY,
        playlist_name TEXT NOT NULL,
        user_id TEXT,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Notification (
        notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES User(user_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Subscription (
        user_id TEXT,
        artist_id TEXT,
        PRIMARY KEY(user_id, artist_id),
        FOREIGN KEY(user_id) REFERENCES User(user_id),
        FOREIGN KEY(artist_id) REFERENCES Artist(artist_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Playlist_Songs (
        playlist_id TEXT,
        song_id TEXT,
        PRIMARY KEY(playlist_id, song_id),
        FOREIGN KEY(playlist_id) REFERENCES Playlist(playlist_id),
        FOREIGN KEY(song_id) REFERENCES Songs(song_id)
      )
    ''');
await db.insert('Artist', {
  'artist_id': 'ARTIST1',
  'artist_name': 'John Doe',
});


await db.insert('Songs', {
  'song_id': 'SONG1',
  'song_name': 'Sample Song 1',
  'url': 'https://example.com/song1.mp3',
  'duration': '3:45',
  'genre': 'Pop',
  'artist_id': 'ARTIST1',
});

await db.insert('Songs', {
  'song_id': 'SONG2',
  'song_name': 'Another Tune',
  'url': 'https://example.com/song2.mp3',
  'duration': '4:10',
  'genre': 'Rock',
  'artist_id': 'ARTIST1',
});
await db.insert('Songs', {
    'song_id': 'SONG5',
    'song_name': 'As You Fade Away',
    'url': 'https://happysoulmusic.com/wp-content/grand-media/audio/As_You_Fade_Away_-_NEFFEX.mp3',
    'duration': '4:16',
    'genre': 'Pop',
    'artist_id': 'ARTIST1',
  });
    await db.insert('User', {
      'user_id': 'ADMIN0',
      'user_name': 'cxladmin',
      'password': 'a212223',
      'is_admin': 1
    }); 
  }






/*Future<List<Map<String, dynamic>>> searchSongs(String query) async {
  final db = await database;
  final results = await db.query(
    'Songs',
    where: 'song_name LIKE ? OR genre LIKE ?',
    whereArgs: ['%$query%', '%$query%'],
  );
  print('Search results for "$query": $results'); // Debug print
  return results;
}*/



  // Song and playlist operations
  Future<Map<String, dynamic>> idToSong(String songId) async {
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

  
}*/