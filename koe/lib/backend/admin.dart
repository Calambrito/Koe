import 'admin_listener_adapter.dart';
import 'database_helper.dart';
import 'song.dart';
import 'theme.dart';
import 'discover.dart';

class Admin {
  final AdminListenerAdapter _adapter;
  static final dbHelper = DatabaseHelper.getInstance();

  Admin._(this._adapter);

  static Future<Admin> create(int userId) async {
    final adapter = await AdminListenerAdapter.forUserId(userId);
    return Admin._(adapter);
  }

  static Future<Admin> createByUsername(String username) async {
    final adapter = await AdminListenerAdapter.forUserName(username);
    return Admin._(adapter);
  }

  // Delegate user properties to adapter
  int get userID => _adapter.userID;
  int get id => _adapter.userID;
  String get username => _adapter.username;
  String get name => _adapter.username;
  KoeTheme get theme => _adapter.theme;

  // Implement Listener-like methods for UI compatibility
  List<int> get playlists => _adapter.playlists;
  List<String> get notifications => _adapter.notifications;
  List<String> get artists => [];
  Discover get discover => Discover();

  Future<void> loadAll() async {
    // Admin doesn't need to load additional data
  }

  Future<void> createPlaylist(String playlistName) async {
    await _adapter.userCreatePlaylist(playlistName);
  }

  Future<void> deletePlaylist(int playlistId) async {
    await _adapter.userDeletePlaylist(playlistId);
  }

  // Admin-specific methods for music management
  Future<int> addSong({
    required String songName,
    required String url,
    String? duration,
    String? genre,
    required String artistName,
  }) async {
    final db = await dbHelper.database;

    final artistRows = await db.query(
      'Artist',
      where: 'artist_name = ?',
      whereArgs: [artistName],
      limit: 1,
    );

    int artistId;
    if (artistRows.isNotEmpty) {
      artistId = artistRows.first['artist_id'] as int;
    } else {
      artistId = await db.insert('Artist', {'artist_name': artistName});
    }

    final songId = await db.insert('Songs', {
      'song_name': songName,
      'url': url,
      'duration': duration,
      'genre': genre,
      'artist_id': artistId,
    });

    return songId;
  }

  Future<List<Map<String, dynamic>>> batchAddSongs(
    List<Map<String, String>> songs,
  ) async {
    final db = await dbHelper.database;
    final results = <Map<String, dynamic>>[];

    await db.transaction((txn) async {
      for (final songData in songs) {
        try {
          final artistName = songData['artistName'] ?? '';
          final songName = songData['songName'] ?? '';
          final url = songData['url'] ?? '';
          final duration = songData['duration'];
          final genre = songData['genre'];

          if (artistName.isEmpty || songName.isEmpty || url.isEmpty) {
            results.add({
              'success': false,
              'songName': songName,
              'artistName': artistName,
              'error': 'Missing required fields',
            });
            continue;
          }

          // Check if artist exists
          final artistRows = await txn.query(
            'Artist',
            where: 'artist_name = ?',
            whereArgs: [artistName],
            limit: 1,
          );

          int artistId;
          if (artistRows.isNotEmpty) {
            artistId = artistRows.first['artist_id'] as int;
          } else {
            artistId = await txn.insert('Artist', {'artist_name': artistName});
          }

          // Check if song already exists
          final existingSong = await txn.query(
            'Songs',
            where: 'song_name = ? AND artist_id = ?',
            whereArgs: [songName, artistId],
            limit: 1,
          );

          if (existingSong.isNotEmpty) {
            results.add({
              'success': false,
              'songName': songName,
              'artistName': artistName,
              'error': 'Song already exists',
            });
            continue;
          }

          final songId = await txn.insert('Songs', {
            'song_name': songName,
            'url': url,
            'duration': duration,
            'genre': genre,
            'artist_id': artistId,
          });

          results.add({
            'success': true,
            'songId': songId,
            'songName': songName,
            'artistName': artistName,
          });
        } catch (e) {
          results.add({
            'success': false,
            'songName': songData['songName'] ?? '',
            'artistName': songData['artistName'] ?? '',
            'error': e.toString(),
          });
        }
      }
    });

    return results;
  }

  Future<List<Song>> getAllSongs() async {
    final db = await dbHelper.database;
    final songs = await db.rawQuery('''
      SELECT s.*, a.artist_name 
      FROM Songs s 
      LEFT JOIN Artist a ON s.artist_id = a.artist_id 
      ORDER BY s.song_name ASC
    ''');

    return songs.map((map) => Song.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllArtists() async {
    final db = await dbHelper.database;
    return await db.query('Artist', orderBy: 'artist_name ASC');
  }

  Future<void> removeSong(Song song) async {
    final db = await dbHelper.database;

    await db.delete(
      'Playlist_Songs',
      where: 'song_id = ?',
      whereArgs: [song.songId],
    );

    await db.delete('Songs', where: 'song_id = ?', whereArgs: [song.songId]);
  }

  Future<void> removeArtist(int artistId) async {
    final db = await dbHelper.database;

    // Get all songs by this artist
    final songs = await db.query(
      'Songs',
      where: 'artist_id = ?',
      whereArgs: [artistId],
    );

    // Remove songs from playlists first
    for (final song in songs) {
      await db.delete(
        'Playlist_Songs',
        where: 'song_id = ?',
        whereArgs: [song['song_id']],
      );
    }

    // Remove all songs by this artist
    await db.delete('Songs', where: 'artist_id = ?', whereArgs: [artistId]);

    // Remove the artist
    await db.delete('Artist', where: 'artist_id = ?', whereArgs: [artistId]);
  }
}
