import 'package:flutter/material.dart';
import '../backend/song.dart'; // Import your backend

class SongPlayerPage extends StatefulWidget {
  final Song song;
  const SongPlayerPage({super.key, required this.song});

  @override
  _SongPlayerPageState createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  bool _isPlaying = false;
  bool _isLoading = false;

  Future<void> _togglePlayback() async {
    setState(() => _isLoading = true);
    
    try {
      if (_isPlaying) {
        await widget.song.pause();
      } else {
        await widget.song.play();
      }
      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    widget.song.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.album, size: 200, color: Colors.grey),
          const SizedBox(height: 30),
          Text(
            widget.song.songName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.song.artistId ?? 'Unknown Artist',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 40,
                onPressed: () {},
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 60,
                      ),
                      onPressed: _togglePlayback,
                    ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 40,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}