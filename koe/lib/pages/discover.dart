import 'dart:async';
import 'package:flutter/material.dart';
import '../backend/song.dart';
import '../backend/playlist.dart';
import '../backend/search_strategy.dart';
import '../backend/song_search.dart';
import '../backend/artist_search.dart';
import '../backend/genre_search.dart';
import '../backend/database_helper.dart';
import '../backend/audio_player_manager.dart';
import 'package:sqflite/sqflite.dart';

class DiscoverPage extends StatefulWidget {
  final dynamic discover;
  final List<int> playlists;
  final int userID;
  final Function(Song) onSongSelected;

  const DiscoverPage({
    super.key,
    required this.discover,
    required this.playlists,
    required this.userID,
    required this.onSongSelected,
  });

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  SongSearchStrategy _currentStrategy = SongNameSearchStrategy();
  bool _isLoading = false;
  final Map<int, String> _playlistNames = {};

  Song? _currentSong;
  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();
    _loadPlaylistNames();
    _searchController.addListener(_performSearch);

    // Listen for actual playback state
    _playingSub =
        AudioPlayerManager.instance.player.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isPlaying = playing);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _playingSub?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaylistNames() async {
    for (int id in widget.playlists) {
      try {
        final playlist = Playlist(playlistId: id);
        final name = await playlist.getPlaylistName(id);
        _playlistNames[id] = name;
      } catch (e) {
        _playlistNames[id] = 'Playlist $id';
      }
    }
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      widget.discover.setStrategy(_currentStrategy);
      final results = await widget.discover.search(query);
      setState(() => _searchResults = results);
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _playOrToggle(Song song) {
    // If tapping the same song, just toggle play/pause
    if (_currentSong != null && _currentSong!.songId == song.songId) {
      if (_isPlaying) {
        AudioPlayerManager.instance.player.pause();
      } else {
        AudioPlayerManager.instance.player.play();
      }
    } else {
      // Set current for UI feedback immediately
      setState(() => _currentSong = song);
      widget.onSongSelected(song);
    }
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.white),
                title: const Text('Subscribe to Artist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _subscribeToArtist(song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text('Add to Playlist',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog(song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _subscribeToArtist(Song song) async {
    if (song.artistId == null) return;
    try {
      final db = await DatabaseHelper.getInstance().database;
      await db.insert(
        'Subscription',
        {
          'user_id': widget.userID,
          'artist_id': song.artistId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subscribed to ${song.artistName ?? 'artist'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to subscribe'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddToPlaylistDialog(Song song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Add to Playlist',
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._playlistNames.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.value,
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _addSongToPlaylist(song, entry.key);
                    },
                  );
                }).toList(),
                const Divider(color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.add, color: Colors.white),
                  title: const Text('Create new playlist',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog(song);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(Song song) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Create Playlist',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _createPlaylistAndAddSong(nameController.text, song);
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPlaylistAndAddSong(String name, Song song) async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      final newPlaylistId = await db.insert(
        'Playlist',
        {
          'playlist_name': name,
          'user_id': widget.userID,
        },
      );
      await db.insert(
        'Playlist_Songs',
        {
          'playlist_id': newPlaylistId,
          'song_id': song.songId,
        },
      );
      setState(() => _playlistNames[newPlaylistId] = name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to new playlist "$name"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addSongToPlaylist(Song song, int playlistId) async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      await db.insert(
        'Playlist_Songs',
        {
          'playlist_id': playlistId,
          'song_id': song.songId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      final playlistName = _playlistNames[playlistId] ?? 'playlist';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to "$playlistName"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to playlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      hintText: 'Search songs...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<SongSearchStrategy>(
                  icon: const Icon(Icons.tune, color: Colors.white),
                  onSelected: (strategy) {
                    setState(() => _currentStrategy = strategy);
                    _performSearch();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SongNameSearchStrategy(),
                      child: const Text('By Song Name'),
                    ),
                    PopupMenuItem(
                      value: ArtistSearchStrategy(),
                      child: const Text('By Artist'),
                    ),
                    PopupMenuItem(
                      value: GenreSearchStrategy(),
                      child: const Text('By Genre'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Search for songs, artists, or genres'
                              : 'No results found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final song = _searchResults[index];
                          return _buildSongTile(song);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    final isThisPlaying =
        _currentSong != null && _currentSong!.songId == song.songId && _isPlaying;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
      title: Text(
        song.songName,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${song.artistName ?? 'Unknown'} • ${song.genre ?? 'No genre'}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(
          isThisPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        onPressed: () => _playOrToggle(song),
      ),
      onTap: () => _playOrToggle(song),
      onLongPress: () => _showSongOptions(song),
    );
  }
}
