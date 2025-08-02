import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      home: const SongListScreen(),
    );
  }
}

class SongListScreen extends StatefulWidget {
  const SongListScreen({super.key});

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await _dbHelper.getSongs();
    setState(() => _songs = songs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            title: Text(song['name']),
            subtitle: Text(song['url']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(
                  songUrl: song['url'],
                  songName: song['name'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}