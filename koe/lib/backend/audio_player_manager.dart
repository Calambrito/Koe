import 'package:just_audio/just_audio.dart';
import 'package:koe/backend/song.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;

  AudioPlayer get player => _player;

  AudioPlayerManager._internal();

  static AudioPlayerManager get instance => _instance;

  Future<void> setUrl(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      print('AudioPlayerManager: Error setting URL $url: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
