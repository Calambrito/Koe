import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_manager.dart';

class PlayerScreen extends StatefulWidget {
  final String songUrl;
  final String songName;

  const PlayerScreen({super.key, 
    required this.songUrl,
    required this.songName,
  });

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayerManager _audioManager = AudioPlayerManager.instance;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioManager.setUrl(widget.songUrl);
    _audioManager.player.playerStateStream.listen((playerState) {
      setState(() => _isPlaying = playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        _audioManager.player.seek(Duration.zero);
        _audioManager.player.pause();
      }
    });
  }

  void _togglePlayPause() async {
    _isPlaying 
      ? await _audioManager.player.pause()
      : await _audioManager.player.play();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.songName)),
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