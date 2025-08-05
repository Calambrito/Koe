import 'package:flutter/material.dart';
import 'song_player.dart';
import '../backend/song.dart'; // Import your backend
import '../backend/listener.dart' as koelistener; // Import your backend
import '../widgets/song_card.dart';
import 'login_page.dart';

class UserHome extends StatefulWidget {
  final String userId;
  const UserHome({super.key, required this.userId});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<Song> _songs = [];
  bool _isLoading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSongs();
  }

  Future<void> _loadUserData() async {
    final listener = await koelistener.Listener.loadUserById(widget.userId);
    setState(() => _username = listener.username);
  }

  Future<void> _loadSongs() async {
    try {
      final song = Song(songId: '', songName: '', url: ''); // Dummy instance
      final songsData = await song.getSongs();
      setState(() {
        _songs = songsData.map((data) => Song.fromMap(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load songs: ${e.toString()}')),
      );
    }
  }

  void _navigateToPlayer(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongPlayerPage(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
          ? const Center(child: Text('No songs available'))
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) => SongCard(
                song: _songs[index],
                onTap: () => _navigateToPlayer(_songs[index]),
              ),
            ),
    );
  }
}
