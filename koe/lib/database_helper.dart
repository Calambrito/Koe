import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'generator.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

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
    // Create tables in proper order to satisfy foreign key constraints
    await db.execute('''
      CREATE TABLE User (
        user_id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        password TEXT NOT NULL,
        user_type INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Artist (
        artist_id TEXT PRIMARY KEY,
        artist_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Songs (
        song_id TEXT PRIMARY KEY,
        song_name TEXT NOT NULL,
        url TEXT NOT NULL,
        duration TEXT,
        genre TEXT,
        artist_id,
        FOREIGN KEY(artist_id) REFERENCES User(artist_id)
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

    final adminId = await getNextUserId();
    await db.insert('User', {
      'user_id': adminId,
      'user_name': 'CxlAdmin',
      'password': 'a212223',
      'is_admin': 1  // Mark as admin
    }); 
  }

  // ID Generation Methods
  Future<String> getNextUserId() async {
    final db = await database;
    final lastUser = await db.rawQuery(
      'SELECT user_id FROM User ORDER BY user_id DESC LIMIT 1'
    );
    
    final lastId = lastUser.isEmpty ? 'UZZ99' : lastUser.first['user_id'] as String;
    return IdGenerator.generateUserId(lastId);
  }

  Future<String> getNextSongId() async {
    final db = await database;
    final lastSong = await db.rawQuery(
      'SELECT song_id FROM Songs ORDER BY song_id DESC LIMIT 1'
    );
    
    final lastId = lastSong.isEmpty ? 'SZZ99' : lastSong.first['song_id'] as String;
    return IdGenerator.generateSongId(lastId);
  }

  // User CRUD Operations
  Future<String> addUser({
  required String userName,
  required String password,
  String? userType,
  bool isAdmin = false,
  }) async {
    final db = await database;

    // Check for existing username (case-insensitive by storage design)
    final existingUser = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Username "$userName" already exists');
    }

    final userId = await getNextUserId();
    
    await db.insert('User', {
      'user_id': userId,
      'user_name': userName.toLowerCase(),  // Store normalized lowercase
      'password': password,
      'user_type': userType,
      'isAdmin': 0
    });
    
    return userId;
  }

  // Song CRUD Operations
  Future<String> addSong(String songName, String url, {String? duration, String? genre}) async {
    final db = await database;
    final songId = await getNextSongId();
    
    await db.insert('Songs', {
      'song_id': songId,
      'song_name': songName,
      'url': url,
      'duration': duration,
      'genre': genre
    });
    
    return songId;
  }

  Future<bool> isAdmin(String userId) async {
  final db = await database;
  final result = await db.query(
    'User',
    columns: ['isAdmin'],
    where: 'user_id = ?',
    whereArgs: [userId],
    limit: 1,
  );
  
  return result.isNotEmpty && result.first['isAdmin'] == 1;
}

  // Other CRUD methods...
  Future<List<Map<String, dynamic>>> getSongs() async {
  final db = await database;
  return await db.query(
    'Songs',  // Your table name
    orderBy: 'song_name ASC',  // Optional: Sort alphabetically
  );
}
  Future<List<String>> playlistToSong(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Playlist_Songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    return List.generate(maps.length, (i) => maps[i]['song_id'] as String);
  }

    Future<Map<String, dynamic>> idToSong(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Songs',
      where: 'song_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      throw Exception('Song with ID $id not found');
    }
  }

  Future<String> getPlaylistName(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Playlist',
      columns: ['playlist_name'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['playlist_name'] as String;
    } else {
      throw Exception('Playlist with ID $playlistId not found');
    }
  }
}

