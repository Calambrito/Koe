import 'package:koe/backend/song.dart';
import 'package:koe/backend/audio_player_manager.dart';

/// Service class for handling audio playback operations
/// TODO: Enhance with more features like playlist, queue management, etc.
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  AudioPlayerService._internal();

  static AudioPlayerService get instance => _instance;

  // Current playing song
  Song? _currentSong;
  bool _isPlaying = false;

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  /// Plays a song
  /// TODO: Add more features like playlist support, queue management
  Future<void> playSong(Song song) async {
    try {
      // TODO: Add pre-playback logic (analytics, user preferences, etc.)

      // Set the song URL and play
      await AudioPlayerManager.instance.setUrl(song.url);
      await AudioPlayerManager.instance.player.play();

      _currentSong = song;
      _isPlaying = true;

      // TODO: Add post-playback logic (update UI, save to history, etc.)
      print('Now playing: ${song.songName} by ${song.artistName}');
    } catch (e) {
      // TODO: Handle error properly (show error message to user)
      print('Error playing song: $e');
      rethrow;
    }
  }

  /// Pauses the current song
  Future<void> pause() async {
    try {
      await AudioPlayerManager.instance.player.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing song: $e');
      rethrow;
    }
  }

  /// Resumes the current song
  Future<void> resume() async {
    try {
      await AudioPlayerManager.instance.player.play();
      _isPlaying = true;
    } catch (e) {
      print('Error resuming song: $e');
      rethrow;
    }
  }

  /// Stops the current song
  Future<void> stop() async {
    try {
      await AudioPlayerManager.instance.player.stop();
      _isPlaying = false;
      _currentSong = null;
    } catch (e) {
      print('Error stopping song: $e');
      rethrow;
    }
  }

  /// Seeks to a specific position in the song
  /// TODO: Add duration validation
  Future<void> seekTo(Duration position) async {
    try {
      await AudioPlayerManager.instance.player.seek(position);
    } catch (e) {
      print('Error seeking to position: $e');
      rethrow;
    }
  }

  /// Gets the current playback position
  Future<Duration?> getCurrentPosition() async {
    try {
      return AudioPlayerManager.instance.player.position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Gets the total duration of the current song
  Future<Duration?> getDuration() async {
    try {
      return AudioPlayerManager.instance.player.duration;
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }

  /// Sets the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await AudioPlayerManager.instance.player.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
      rethrow;
    }
  }

  /// Disposes the audio player
  Future<void> dispose() async {
    try {
      await AudioPlayerManager.instance.dispose();
      _currentSong = null;
      _isPlaying = false;
    } catch (e) {
      print('Error disposing audio player: $e');
      rethrow;
    }
  }
}


