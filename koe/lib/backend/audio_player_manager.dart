import 'package:just_audio/just_audio.dart';
import 'package:koe/backend/song.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;

  AudioPlayer get player => _player;

  AudioPlayerManager._internal();

  bool get isPlaying {
    try {
      // Just check if the player is playing - don't worry about processing state
      return _player.playing;
    } catch (e) {
      print('AudioPlayerManager: Error checking playing state: $e');
      return false;
    }
  }

  static AudioPlayerManager get instance => _instance;

  Future<void> setUrl(String url) async {
    try {
      print('AudioPlayerManager: Setting URL: $url');
      await _player.setUrl(url);
      print('AudioPlayerManager: URL set successfully');
    } catch (e) {
      print('AudioPlayerManager: Error setting URL $url: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      print('AudioPlayerManager: Starting playback');
      await _player.play();
      print('AudioPlayerManager: Playback started successfully');
    } catch (e) {
      print('AudioPlayerManager: Error starting playback: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      print('AudioPlayerManager: Pausing playback');
      await _player.pause();
      print('AudioPlayerManager: Playback paused successfully');
    } catch (e) {
      print('AudioPlayerManager: Error pausing playback: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
