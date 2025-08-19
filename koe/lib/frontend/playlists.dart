// lib/frontend/playlists.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../backend/listener.dart' as klistener;
import '../backend/playlist.dart';
import '../backend/song.dart';
import '../backend/koe_palette.dart';
import '../backend/theme.dart';
import '../backend/audio_player_manager.dart';

class PlaylistsPage extends StatefulWidget {
  final klistener.Listener listener;
  final KoeTheme currentTheme;

  const PlaylistsPage({
    super.key,
    required this.listener,
    required this.currentTheme,
  });

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

/// Temporary local playlist used while creating (negative id)
class _LocalPlaylist {
  final int id;
  final String name;
  _LocalPlaylist({required this.id, required this.name});
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final Map<int, Playlist> _playlistsCache = {};
  final Set<int> _expandedPlaylists = {};
  Song? _currentlyPlayingSong;

  // local optimistic playlists created through the UI (not yet persisted)
  final List<_LocalPlaylist> _localPlaylists = [];
  int _nextTempId = -1;

  @override
  void initState() {
    super.initState();
    // Pre-load all playlists to show names immediately
    _preloadPlaylists();
  }

  Future<void> _preloadPlaylists() async {
    final backendPlaylistIds = widget.listener.playlists ?? [];
    for (int id in backendPlaylistIds) {
      if (!_playlistsCache.containsKey(id)) {
        final p = Playlist(playlistId: id);
        _playlistsCache[id] = p;
      }
    }
    setState(() {});
  }

  Future<void> _refreshPlaylistCache(int playlistId) async {
    try {
      // Remove from cache
      _playlistsCache.remove(playlistId);

      // Create fresh instance
      final newPlaylist = Playlist(playlistId: playlistId);
      await newPlaylist.initialized;
      _playlistsCache[playlistId] = newPlaylist;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error refreshing playlist cache: $e');
    }
  }

  Color _paletteMain() {
    try {
      return KoePalette.shade(widget.currentTheme.paletteName, 'main');
    } catch (_) {
      return Colors.blue;
    }
  }

  Color _paletteDark() {
    try {
      return KoePalette.shade(widget.currentTheme.paletteName, 'dark');
    } catch (_) {
      return Colors.blueGrey.shade700;
    }
  }

  void _onExpansionChanged(bool expanded, int playlistId) {
    if (expanded) {
      _expandedPlaylists.add(playlistId);
      if (playlistId > 0 && !_playlistsCache.containsKey(playlistId)) {
        final p = Playlist(playlistId: playlistId);
        _playlistsCache[playlistId] = p;
        // Force a rebuild to show loading state immediately
        setState(() {});
      } else {
        setState(() {}); // local or already cached
      }
    } else {
      _expandedPlaylists.remove(playlistId);
      setState(() {});
    }
  }

  Future<void> _togglePlay(Song song) async {
    if (!mounted) return;

    try {
      final mgr = AudioPlayerManager.instance;
      // determine if this exact song is currently playing
      final isPlayingThis =
          mgr.currentSong?.songId == song.songId &&
          (mgr.player.playing == true); // <- adjust if your API differs

      if (isPlayingThis) {
        // If it's playing -> pause it
        await song.pause();
        if (mounted) {
          setState(() {});
        }
        return;
      }

      // If some other song is playing, pause it first (keeps currentSong intact for that song).
      if (mgr.currentSong != null && mgr.currentSong!.songId != song.songId) {
        await mgr.player.pause();
      }

      // Start or resume requested song.
      await song.play();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Play/pause error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play/pause the track')),
        );
      }
    }
  }

  Widget _buildSongTile(Song song, {int? playlistId}) {
    final mgr = AudioPlayerManager.instance;

    // More robust isPlaying check: both same song AND player.playing == true
    bool isPlaying = false;
    try {
      isPlaying =
          mgr.currentSong?.songId == song.songId &&
          (mgr.player.playing == true);
    } catch (_) {
      isPlaying = mgr.currentSong?.songId == song.songId;
    }

    final textColor = Colors.black;

    Widget songTile = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        ),
        iconSize: 30,
        onPressed: () => _togglePlay(song),
      ),
      onTap: () => _togglePlay(song),
    );

    // Wrap with GestureDetector for long press if it's in a playlist
    if (playlistId != null) {
      return GestureDetector(
        onLongPress: () => _showDeleteSongDialog(playlistId, song),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent, width: 1),
          ),
          child: songTile,
        ),
      );
    }

    return songTile;
  }

  Widget _buildPlaylistSongsArea(int playlistId) {
    if (playlistId < 0) {
      // local optimistic playlist: no songs
      return SizedBox(
        height: 72,
        child: Center(
          child: Text(
            'No songs in this playlist.',
            style: TextStyle(
              color: widget.currentTheme.isDarkMode
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ),
      );
    }

    final playlist = _playlistsCache[playlistId];
    if (playlist == null) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<void>(
      future: playlist.initialized,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 72,
            child: Center(
              child: Text(
                'Failed to load playlist.',
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          );
        } else {
          final songs = playlist.songs;

          return Column(
            children: [
              // Add Songs button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showAddSongsDialog(playlistId, playlist.playlistName),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Songs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Songs list or empty state
              if (songs.isEmpty)
                SizedBox(
                  height: 72,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note_outlined,
                          size: 32,
                          color: widget.currentTheme.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No songs in this playlist.',
                          style: TextStyle(
                            color: widget.currentTheme.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...songs.map(
                  (s) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.black12),
                      ),
                    ),
                    child: _buildSongTile(s, playlistId: playlistId),
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Future<void> _createPlaylistWithBackend(String name) async {
    final paletteMain = _paletteMain();

    // show optimistic temp playlist
    final tempId = _nextTempId;
    _nextTempId -= 1;
    final temp = _LocalPlaylist(id: tempId, name: name);
    _localPlaylists.insert(0, temp);
    setState(() {});

    // snapshot of prior backend ids (if any)
    final beforeIds = Set<int>.from(widget.listener.playlists ?? []);

    // show loading feedback
    final snack = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating playlist "$name"...'),
        duration: const Duration(days: 1),
      ),
    );

    try {
      // call the listener method you provided
      await widget.listener.createPlaylist(name);

      // hide loading snack
      snack.close();

      // compare new ids to find created id
      final afterIds = Set<int>.from(widget.listener.playlists ?? []);
      final diff = afterIds.difference(beforeIds);

      if (diff.isNotEmpty) {
        final createdId = diff.first;
        // remove temp placeholder
        _localPlaylists.removeWhere((p) => p.id == tempId);

        // ensure playlist instance will be created (lazy)
        _playlistsCache[createdId] = Playlist(playlistId: createdId);

        // ensure UI refreshes (place new id will appear via widget.listener.playlists)
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "$name" created.'),
            backgroundColor: paletteMain,
          ),
        );
      } else {
        // backend didn't expose new id; just remove temp and refresh UI
        _localPlaylists.removeWhere((p) => p.id == tempId);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist created (refresh if it does not appear).'),
          ),
        );
      }
    } catch (e) {
      // error: remove temp and show message
      snack.close();
      _localPlaylists.removeWhere((p) => p.id == tempId);
      setState(() {});
      debugPrint('Create playlist error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create playlist.')),
      );
    }
  }

  Future<void> _showCreatePlaylistDialog() async {
    final TextEditingController ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create playlist'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Playlist name'),
            autofocus: true,
            onSubmitted: (_) => Navigator.of(ctx).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(ctx).pop();
                  _createPlaylistWithBackend(name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a playlist name.'),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSongsDialog(int playlistId, String playlistName) async {
    // Get all available songs
    List<Song> allSongs = [];
    try {
      final songMaps = await Song.getSongs();
      allSongs = songMaps.map((map) => Song.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading songs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load songs.')),
          );
        }
      }
      return;
    }

    // Force refresh the playlist cache to get the most up-to-date data
    await _refreshPlaylistCache(playlistId);

    // Get current playlist songs to show which are already added
    final playlist = _playlistsCache[playlistId];
    Set<int> existingSongIds = {};
    if (playlist != null) {
      try {
        existingSongIds = playlist.songs.map((s) => s.songId).toSet();
      } catch (e) {
        debugPrint('Error getting existing songs: $e');
        existingSongIds = {};
      }
    }

    // Filter out songs that are already in the playlist
    final availableSongs = allSongs
        .where((song) => !existingSongIds.contains(song.songId))
        .toList();

    if (availableSongs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All songs are already in this playlist.'),
            ),
          );
        }
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        Set<int> selectedSongIds = {};

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add songs to "$playlistName"'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    Text(
                      'Select songs to add:',
                      style: TextStyle(
                        color: widget.currentTheme.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableSongs.length,
                        itemBuilder: (context, index) {
                          final song = availableSongs[index];
                          final isSelected = selectedSongIds.contains(
                            song.songId,
                          );

                          return CheckboxListTile(
                            title: Text(
                              song.songName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              song.artistName ?? 'Unknown artist',
                              style: TextStyle(
                                color: widget.currentTheme.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedSongIds.add(song.songId);
                                } else {
                                  selectedSongIds.remove(song.songId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedSongIds.isEmpty
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await _addSongsToPlaylist(
                            playlistId,
                            availableSongs
                                .where(
                                  (s) => selectedSongIds.contains(s.songId),
                                )
                                .toList(),
                          );
                        },
                  child: Text(
                    'Add ${selectedSongIds.length} song${selectedSongIds.length == 1 ? '' : 's'}',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addSongsToPlaylist(int playlistId, List<Song> songs) async {
    if (songs.isEmpty) return;

    final playlist = _playlistsCache[playlistId];
    if (playlist == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Playlist not found.')));
      }
      return;
    }

    // Show loading feedback
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Adding ${songs.length} song${songs.length == 1 ? '' : 's'} to playlist...',
            ),
            duration: const Duration(days: 1),
          ),
        );
      }
    }

    try {
      // Add songs to playlist
      for (final song in songs) {
        await playlist.addSong(song);
      }

      // Refresh the playlist cache completely
      await _refreshPlaylistCache(playlistId);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${songs.length} song${songs.length == 1 ? '' : 's'} to playlist.',
              ),
              backgroundColor: _paletteMain(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error adding songs to playlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add songs: ${e.toString()}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteSongDialog(int playlistId, Song song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Remove Song'),
          content: Text(
            'Remove "${song.songName}" from this playlist?',
            style: TextStyle(
              color: widget.currentTheme.isDarkMode
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _removeSongFromPlaylist(playlistId, song);
    }
  }

  Future<void> _removeSongFromPlaylist(int playlistId, Song song) async {
    final playlist = _playlistsCache[playlistId];
    if (playlist == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Playlist not found.')));
      }
      return;
    }

    try {
      await playlist.removeSong(song);

      // Refresh the playlist cache completely
      await _refreshPlaylistCache(playlistId);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${song.songName}" from playlist.'),
              backgroundColor: _paletteMain(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error removing song from playlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove song: ${e.toString()}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmAndDeletePlaylist(
    int playlistId,
    String displayName,
  ) async {
    final isLocal = playlistId < 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete playlist'),
          content: Text('Delete "$displayName"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (isLocal) {
      // remove optimistic local playlist
      _localPlaylists.removeWhere((p) => p.id == playlistId);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playlist removed.')));
      return;
    }

    try {
      await widget.listener.deletePlaylist(playlistId);
      // cleanup cache + update UI. Assume listener.playlists will be updated by deletePlaylist method.
      _playlistsCache.remove(playlistId);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playlist deleted.')));
    } catch (e) {
      debugPrint('Delete playlist error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete playlist.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paletteMain = _paletteMain();
    final paletteDark = _paletteDark();
    final backendPlaylistIds = widget.listener.playlists ?? [];

    // Render local optimistic playlists first, then backend playlists (backend order preserved)
    final allIds = [..._localPlaylists.map((p) => p.id), ...backendPlaylistIds];

    if (allIds.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Text(
              'no playlists yet :( you can easily make one though',
              style: TextStyle(
                color: widget.currentTheme.isDarkMode
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Add Playlist button (still shown when empty)
          _buildAddPlaylistButton(paletteMain),
        ],
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: allIds.length,
          itemBuilder: (context, index) {
            final id = allIds[index];

            // Local temporary playlist
            if (id < 0) {
              final local = _localPlaylists.firstWhere((p) => p.id == id);
              return GestureDetector(
                onLongPress: () =>
                    _confirmAndDeletePlaylist(local.id, local.name),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey('playlist_local_${local.id}'),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      collapsedBackgroundColor:
                          paletteDark, // Always dark header
                      backgroundColor: paletteDark, // Always dark header
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        local.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: widget.currentTheme.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to view songs',
                        style: TextStyle(
                          color: widget.currentTheme.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down),
                      onExpansionChanged: (expanded) =>
                          _onExpansionChanged(expanded, local.id),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                paletteMain, // Main color for expanded content
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                              left: 8,
                              right: 8,
                            ),
                            child: _buildPlaylistSongsArea(local.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Backend playlist
            return GestureDetector(
              onLongPress: () async {
                // attempt to get a name for display (from cache if available)
                final cached = _playlistsCache[id];
                final name = (cached != null && cached.playlistName.isNotEmpty)
                    ? cached.playlistName
                    : 'Playlist #$id';
                await _confirmAndDeletePlaylist(id, name);
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: ValueKey('playlist_$id'),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    collapsedBackgroundColor: paletteDark, // Always dark header
                    backgroundColor: paletteDark, // Always dark header
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: FutureBuilder<void>(
                      future: _playlistsCache[id]?.initialized,
                      builder: (context, snap) {
                        final playlist = _playlistsCache[id];

                        if (snap.connectionState == ConnectionState.waiting) {
                          // Show loading state
                          return Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.currentTheme.isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: widget.currentTheme.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          );
                        }

                        if (snap.hasError || playlist == null) {
                          // Show error state with playlist ID
                          return Text(
                            'Playlist #$id',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: widget.currentTheme.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          );
                        }

                        // Show the actual playlist name
                        final titleText = playlist.playlistName.isNotEmpty
                            ? playlist.playlistName
                            : 'Playlist #$id';
                        return Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: widget.currentTheme.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      },
                    ),
                    subtitle: Text(
                      'Tap to view songs',
                      style: TextStyle(
                        color: widget.currentTheme.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_down),
                    onExpansionChanged: (expanded) =>
                        _onExpansionChanged(expanded, id),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: paletteMain, // Main color for expanded content
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                            left: 8,
                            right: 8,
                          ),
                          child: _buildPlaylistSongsArea(id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Add Playlist button
        _buildAddPlaylistButton(paletteMain),
      ],
    );
  }

  Widget _buildAddPlaylistButton(Color paletteMain) {
    return Align(
      alignment: const Alignment(
        0.9,
        0.9,
      ), // near bottom-right but inset slightly
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, right: 20.0),
        child: GestureDetector(
          onTap: _showCreatePlaylistDialog,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: paletteMain,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 36, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
