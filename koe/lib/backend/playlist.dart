import 'dart:async';
import 'database_helper.dart';
import 'song.dart';

class Playlist {
  final int playlistId;
  String playlistName;
  List<Song> songs = [];
  static final dbHelper = DatabaseHelper.getInstance();
  
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initialized => _initCompleter.future;

  Playlist({required this.playlistId, this.playlistName = ''}) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      playlistName = await getPlaylistName(playlistId);
      await _loadSongs();
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
      rethrow;
    }
  }

  Future<void> _loadSongs() async {
    final songIds = await playlistToSong(playlistId);
    songs.clear();
    
    for (int id in songIds) {
      final songMap = await dbHelper.idToSong(id);
      songs.add(Song.fromMap(songMap));
    }
  }

  Future<List<int>> playlistToSong(int playlistId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Playlist_Songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    return List.generate(maps.length, (i) => maps[i]['song_id'] as int);
  }

  Future<void> addSong(Song song) async {
    songs.add(song);
    await dbHelper.database.then((db) => db.insert(
      'Playlist_Songs',
      {
        'playlist_id': playlistId,
        'song_id': song.songId
      },
    ));
  }

  Future<void> removeSong(Song song) async {
    songs.remove(song);
    await dbHelper.database.then((db) => db.delete(
      'Playlist_Songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, song.songId],
    ));
  }

  static Future<String> getPlaylistName(int playlistId) async {
    final db = await dbHelper.database;
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