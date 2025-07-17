import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player Demo',
      home: AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Load your audio source (replace with your URL or asset)
    _player.setUrl(
      'https://happysoulmusic.com/wp-content/grand-media/audio/As_You_Fade_Away_-_NEFFEX.mp3',
    );

    // Listen to player state changes
    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;

      // Update UI only if needed
      if (playing != _isPlaying) {
        setState(() {
          _isPlaying = playing;
        });
      }

      // If playback finished, reset button to 'play'
      if (processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
      // UI will update via listener
    } else {
      await _player.play();
      // UI will update via listener
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Player Demo')),
      body: Center(
        child: IconButton(
          iconSize: 64,
          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
          onPressed: _togglePlayPause,
        ),
      ),
    );
  }
}
