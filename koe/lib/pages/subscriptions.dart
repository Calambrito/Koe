import 'package:flutter/material.dart';
import '../backend/artist.dart';
import '../backend/song.dart';

class SubscriptionsPage extends StatefulWidget {
  final List<String> artists;
  final Function(Song) onSongSelected;

  const SubscriptionsPage({
    super.key,
    required this.artists,
    required this.onSongSelected,
  });

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final Map<String, List<Song>> _artistSongsMap = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArtistSongs();
  }

  Future<void> _loadArtistSongs() async {
    try {
      for (String artistName in widget.artists) {
        final songs = await Song.getSongsByArtist(artistName);
        _artistSongsMap[artistName] = songs;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load artist songs: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _artistSongsMap.clear();
    });
    await _loadArtistSongs();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_artistSongsMap.isEmpty) {
      return const Center(child: Text('No subscriptions found'));
    }

    return ListView.builder(
      itemCount: _artistSongsMap.length,
      itemBuilder: (context, index) {
        final artistName = _artistSongsMap.keys.elementAt(index);
        final songs = _artistSongsMap[artistName]!;
        return _buildArtistSection(artistName, songs);
      },
    );
  }

  Widget _buildArtistSection(String artistName, List<Song> songs) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.people),
        title: Text(
          artistName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${songs.length} ${songs.length == 1 ? 'song' : 'songs'}'),
        children: [
          if (songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No songs available for this artist'),
            )
          else
            ...songs.map((song) => _buildSongTile(song)).toList(),
        ],
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(song.songName),
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () => widget.onSongSelected(song),
      ),
      onTap: () => widget.onSongSelected(song),
    );
  }
}