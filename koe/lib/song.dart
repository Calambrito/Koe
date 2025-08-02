import 'audio_player_manager.dart';

class Song {
  final String songId;
  final String songName;
  final String url;
  final String? duration;
  final String? genre;
  final String? artistId;

  // Constructor
  Song({
    required this.songId,
    required this.songName,
    required this.url,
    this.duration,
    this.genre,
    this.artistId,
  });

  // Alternative constructor from database map
  Song.fromMap(Map<String, dynamic> map) :
    songId = map['song_id'] as String,
    songName = map['song_name'] as String,
    url = map['url'] as String,
    duration = map['duration'] as String?,
    genre = map['genre'] as String?,
    artistId = map['artist_id'] as String?;

  // Convert to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'song_id': songId,
      'song_name': songName,
      'url': url,
      if (duration != null) 'duration': duration,
      if (genre != null) 'genre': genre,
      if (artistId != null) 'artist_id': artistId,
    };
  }

  // Playback control methods
  Future<void> play() async {
    try {
      await AudioPlayerManager.instance.setUrl(url);
      await AudioPlayerManager.instance.player.play();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pause() async {
    await AudioPlayerManager.instance.player.pause();
  }

  Future<void> stop() async {
    await AudioPlayerManager.instance.player.stop();
  }

}