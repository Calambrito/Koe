// filepath: lib/backend/song.dart
import 'audio_player_manager.dart';
import 'database_helper.dart';

class Song {
  final int songId;
  final String songName;
  final String url;
  final String? duration;
  final String? genre;
  final int? artistId;
  final String? artistName;

  static final dbHelper = DatabaseHelper.getInstance();

  Song({
    required this.songId,
    required this.songName,
    required this.url,
    this.duration,
    this.genre,
    this.artistId,
    this.artistName,
  });

  // Construct from a DB map. Handles nullable artist fields.
  Song.fromMap(Map<String, dynamic> map)
    : songId = map['song_id'] as int,
      songName = map['song_name'] as String,
      url = map['url'] as String,
      duration = map['duration'] as String?,
      genre = map['genre'] as String?,
      // artist_id in DB is an integer or null
      artistId = map['artist_id'] is int ? map['artist_id'] as int : null,
      // artist_name may be returned by joined queries
      artistName = map['artist_name'] is String
          ? map['artist_name'] as String
          : null;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'song_id': songId,
      'song_name': songName,
      'url': url,
    };
    if (duration != null) map['duration'] = duration;
    if (genre != null) map['genre'] = genre;
    if (artistId != null) map['artist_id'] = artistId;
    if (artistName != null) map['artist_name'] = artistName;
    return map;
  }

  static Future<List<Map<String, dynamic>>> getSongs() async {
    final db = await dbHelper.database;
    return await db.query('Songs', orderBy: 'song_name ASC');
  }

  Future<void> play() async {
    final mgr = AudioPlayerManager.instance;
    try {
      print('Song.play(): Attempting to play song: ${songName} with URL: $url');

      // If this exact song is already loaded (currentSong) then just resume playback
      // (avoids calling setUrl again which would reset position).
      if (mgr.currentSong?.songId == songId) {
        print('Song.play(): Resuming existing song');
        await mgr.play();
        return;
      }

      // Otherwise: mark as current, load the URL and start playback.
      print('Song.play(): Loading new song URL');
      mgr.currentSong = this;
      await mgr.setUrl(url);

      // Small delay to ensure the player is ready
      await Future.delayed(const Duration(milliseconds: 100));

      print('Song.play(): Starting playback');
      await mgr.play();
      print('Song.play(): Playback started successfully');
    } catch (e) {
      print('Song.play(): Error playing song ${songName}: $e');
      // If we optimistically set currentSong above and playback failed, revert.
      if (AudioPlayerManager.instance.currentSong?.songId == songId) {
        AudioPlayerManager.instance.currentSong = null;
      }
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      // Pause the player but DO NOT clear currentSong so we can resume from the same position.
      await AudioPlayerManager.instance.pause();
      // Do not set currentSong = null here.
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Song && other.songId == songId);

  @override
  int get hashCode => songId.hashCode;

  static Future<List<Song>> getSongsByArtist(String artistName) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;

    final songMaps = await db.query(
      'Songs',
      where: 'artist_name = ?',
      whereArgs: [artistName],
    );

    return songMaps.map((map) => Song.fromMap(map)).toList();
  }

  Future<void> stop() async {
    await AudioPlayerManager.instance.player.stop();
  }
}
