import 'package:flutter/material.dart';
import '../backend/playlist.dart';
import '../backend/song.dart';
import '../backend/listener.dart' as klistener;

class PlaylistsPage extends StatefulWidget {
  final klistener.Listener listener;
  final Function(Song) onSongSelected;

  const PlaylistsPage({
    super.key,
    required this.listener,
    required this.onSongSelected,
  });

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final Map<int, Playlist> _playlists = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlaylists();
  }

  Future<void> _initializePlaylists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.listener.loadPlaylists();

      for (int id in widget.listener.playlists) {
        final playlist = Playlist(playlistId: id);
        await playlist.initialized;
        _playlists[id] = playlist;
      }
    } catch (e) {
      _errorMessage = 'Failed to load playlists: ${e.toString()}';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _refreshPlaylists() async {
    _playlists.clear();
    await _initializePlaylists();
  }

  Future<void> _showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await widget.listener.createPlaylist(name);
      await _refreshPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlaylists,
        child: _buildContent(),
      ),
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
              onPressed: _refreshPlaylists,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_playlists.isEmpty) {
      return const Center(child: Text('No playlists found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 60),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists.values.elementAt(index);
        return _buildPlaylistTile(playlist);
      },
    );
  }

  Widget _buildPlaylistTile(Playlist playlist) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.queue_music),
        title: Text(
          playlist.playlistName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${playlist.songs.length} songs'),
        children: [
          if (playlist.songs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('This playlist is empty'),
            )
          else
            ...playlist.songs.map((song) => _buildSongTile(song)).toList(),
        ],
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(song.songName),
      subtitle: song.artistName != null
          ? Text(song.artistName!)
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () => widget.onSongSelected(song),
      ),
      onTap: () => widget.onSongSelected(song),
    );
  }
}
