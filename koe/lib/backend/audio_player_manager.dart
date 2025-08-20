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

      // Check if URL is accessible
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw Exception('Invalid URL format: $url');
      }

      await _player.setUrl(url);
      print('AudioPlayerManager: URL set successfully');
    } catch (e) {
      print('AudioPlayerManager: Error setting URL $url: $e');
      // Provide more specific error messages
      if (e.toString().contains('404')) {
        throw Exception('Audio file not found. Please check the URL.');
      } else if (e.toString().contains('CORS')) {
        throw Exception(
          'CORS error. The audio source does not allow cross-origin access.',
        );
      } else if (e.toString().contains('timeout')) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else {
        throw Exception('Failed to load audio: ${e.toString()}');
      }
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
