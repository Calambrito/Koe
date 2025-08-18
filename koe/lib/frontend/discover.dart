// lib/frontend/discover.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../backend/search_strategy.dart';
import '../backend/playlist.dart';
import '../backend/song.dart';
import '../backend/artist.dart';
import '../backend/listener.dart' as klistener;
import '../backend/koe_palette.dart';
import '../backend/theme.dart';
import '../backend/database_helper.dart';
import '../backend/audio_player_manager.dart';

class DiscoverPage extends StatefulWidget {
  final klistener.Listener listener;
  final KoeTheme currentTheme;

  const DiscoverPage({
    super.key,
    required this.listener,
    required this.currentTheme,
  });

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Song> _searchResults = [];
  final List<Song> _showcaseSongs = []; // showcase list
  SongSearchStrategy _currentStrategy = SongNameSearchStrategy();
  Song? _currentlyPlayingSong;
  bool _isSearching = false;

  Timer? _debounce;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadShowcaseSongs();

    // Poll the AudioPlayerManager to keep UI in sync with playback state.
    // This is defensive: if your audio lib provides a state stream, you can
    // replace this with a subscription for better efficiency.
    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _refreshPlaybackState();
    });
  }

  void _refreshPlaybackState() {
    final mgr = AudioPlayerManager.instance;
    try {
      final mgrSong = mgr.currentSong;
      // Only call setState when something changed to avoid excessive rebuilds.
      final changed = (mgrSong?.songId != _currentlyPlayingSong?.songId);
      if (changed) {
        setState(() {
          _currentlyPlayingSong = mgrSong;
        });
      }
    } catch (_) {
      // If something goes wrong reading the player, ignore — don't crash UI.
    }
  }

  Color _paletteMain() {
    try {
      return KoePalette.shade(widget.currentTheme.paletteName, 'main');
    } catch (_) {
      return Colors.blue;
    }
  }

  Future<void> _loadShowcaseSongs() async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      final raw = await DatabaseHelper.showcaseSongs(db);

      final songs = raw.map((map) => Song.fromMap(map)).toList();
      if (!mounted) return;

      setState(() {
        _showcaseSongs
          ..clear()
          ..addAll(songs.take(30));
      });
    } catch (e) {
      debugPrint("Error loading showcase songs: $e");
    }
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _searchResults.clear());
      await _loadShowcaseSongs();
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _currentStrategy.search(q);
      if (!mounted) return;
      setState(() {
        _searchResults
          ..clear()
          ..addAll(results);
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to perform search')),
      );
    }
  }

  Future<void> _togglePlay(Song song) async {
    try {
      final mgr = AudioPlayerManager.instance;
      // determine if this exact song is currently playing
      final isPlayingThis = mgr.currentSong?.songId == song.songId &&
          (mgr.player.playing == true); // <- adjust if your API differs

      if (isPlayingThis) {
        // If it's playing -> pause it
        await song.pause();
        setState(() {});
        return;
      }

      // If some other song is playing, pause it first (keeps currentSong intact for that song).
      if (mgr.currentSong != null && mgr.currentSong!.songId != song.songId) {
        await mgr.player.pause();
      }

      // Start or resume requested song.
      await song.play();
      setState(() {});
    } catch (e) {
      debugPrint('Play/pause error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to play/pause the track')),
      );
    }
  }

  void _changeSearchStrategy() {
    showDialog(
      context: context,
      builder: (ctx) {
        final strategies = [
          {'label': 'Song Name', 'strategy': SongNameSearchStrategy()},
          {'label': 'Artist', 'strategy': ArtistSearchStrategy()},
          {'label': 'Genre', 'strategy': GenreSearchStrategy()},
        ];

        return AlertDialog(
          title: const Text('Search by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: strategies.map((entry) {
              final isSelected = _currentStrategy.runtimeType ==
                  entry['strategy']!.runtimeType;

              return GestureDetector(
                onTap: () {
                  setState(() =>
                      _currentStrategy = entry['strategy'] as SongSearchStrategy);
                  Navigator.pop(ctx);
                  _search(_searchController.text); // re-run search
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? KoePalette.shade(
                            widget.currentTheme.paletteName, 'dark')
                        : KoePalette.shade(
                            widget.currentTheme.paletteName, 'light'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry['label'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStrategyIcon() {
    if (_currentStrategy is SongNameSearchStrategy) {
      return const Icon(Icons.music_note);
    } else if (_currentStrategy is ArtistSearchStrategy) {
      return const Icon(Icons.person);
    } else if (_currentStrategy is GenreSearchStrategy) {
      return const Icon(Icons.category);
    }
    return const Icon(Icons.search);
  }

  Widget _buildSongTile(Song song) {
    // Determine playing by asking the audio manager directly for the most reliable state.
    final mgr = AudioPlayerManager.instance;
    bool playing = false;
    try {
      playing = (mgr.currentSong?.songId == song.songId) && (mgr.player.playing == true);
    } catch (_) {
      // Fallback: compare currentSong only if `playing` property absent.
      playing = mgr.currentSong?.songId == song.songId;
    }

    final textColor = widget.currentTheme.isDarkMode ? Colors.white : Colors.black;

    return ListTile(
      tileColor: _paletteMain(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        song.songName,
        style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              '${song.artistName ?? "Unknown artist"} • ${song.genre ?? "Unknown genre"}',
              style: TextStyle(color: textColor.withOpacity(0.85)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (song.duration != null)
            Text(
              song.duration!,
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
        ),
        iconSize: 30,
        onPressed: () => _togglePlay(song),
      ),
      onTap: () => _togglePlay(song),
      onLongPress: () => _showSongOptions(song),
    );
  }

  Future<void> _showSongOptions(Song song) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to playlist'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylistDialog(song);
                },
              ),
              if (song.artistId != null)
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Subscribe to artist'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _subscribeToArtist(song.artistId!);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _subscribeToArtist(int artistId) async {
    try {
      final userId = widget.listener.id;
      await Artist.subscribe(artistId, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscribed to artist!')),
      );
    } catch (e) {
      debugPrint('Subscribe error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to subscribe to artist')),
      );
    }
  }

  Future<void> _showAddToPlaylistDialog(Song song) async {
    final playlistIds = widget.listener.playlists ?? [];
    if (playlistIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No playlists available')),
      );
      return;
    }

    final playlistNames = <int, String>{};
    for (final id in playlistIds) {
      try {
        final name = await Playlist.getPlaylistName(id);
        playlistNames[id] = name;
      } catch (e) {
        debugPrint('Error getting playlist name: $e');
        playlistNames[id] = 'Playlist #$id';
      }
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add to playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlistNames.length,
              itemBuilder: (context, index) {
                final id = playlistIds[index];
                return ListTile(
                  title: Text(playlistNames[id]!),
                  onTap: () {
                    Navigator.pop(ctx);
                    _addToPlaylist(song, id);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToPlaylist(Song song, int playlistId) async {
    try {
      Playlist pika = Playlist(playlistId: playlistId);
      await pika.addSong(song);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to playlist!')),
      );
    } catch (e) {
      debugPrint('Add to playlist error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to playlist')),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showingShowcase =
        _searchController.text.trim().isEmpty && _showcaseSongs.isNotEmpty;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: IconButton(
                icon: _buildStrategyIcon(),
                onPressed: _changeSearchStrategy,
                tooltip: 'Change search type',
              ),
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () {
                _search(value);
              });
            },
          ),
        ),

        // Results
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (showingShowcase)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _showcaseSongs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSongTile(_showcaseSongs[index]),
                );
              },
            ),
          )
        else if (_searchResults.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No results found',
                style: TextStyle(
                  color: widget.currentTheme.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: 18,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSongTile(_searchResults[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}
