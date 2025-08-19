// lib/widgets/nowplaying.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../backend/audio_player_manager.dart';
import '../backend/song.dart';
import '../backend/koe_palette.dart';
import '../backend/theme.dart';

class NowPlayingBar extends StatefulWidget {
  final KoeTheme? currentTheme;

  const NowPlayingBar({super.key, this.currentTheme});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> {
  Song? _song;
  bool _isPlaying = false;
  Timer? _pollTimer;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _refreshState();
    // Simple polling for updates
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) _refreshState();
    });
  }

  void _refreshState() {
    if (!mounted) return;

    final mgr = AudioPlayerManager.instance;
    Song? curr;
    bool playing = false;

    try {
      curr = mgr.currentSong;
      playing = mgr.player.playing == true;
      _currentPosition = mgr.player.position;
      _duration = mgr.player.duration ?? Duration.zero;
    } catch (_) {
      curr = mgr.currentSong;
      playing = mgr.currentSong != null;
    }

    if (curr?.songId != _song?.songId || playing != _isPlaying) {
      setState(() {
        _song = curr;
        _isPlaying = playing;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _togglePlay() async {
    if (!mounted || _song == null) return;

    try {
      final mgr = AudioPlayerManager.instance;
      final isPlayingThis =
          mgr.currentSong?.songId == _song!.songId &&
          (mgr.player.playing == true);

      if (isPlayingThis) {
        await mgr.player.pause();
      } else {
        if (mgr.currentSong?.songId == _song!.songId) {
          await mgr.player.play();
        } else {
          await _song!.play();
        }
      }
      _refreshState();
    } catch (e) {
      debugPrint('Toggle play error: $e');
    }
  }

  Future<void> _playPreviousSong() async {
    if (!mounted) return;

    try {
      // Get all available songs from the database
      final songMaps = await Song.getSongs();
      final allSongs = songMaps.map((map) => Song.fromMap(map)).toList();

      if (allSongs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No songs available')));
        return;
      }

      final currentSong = _song;
      if (currentSong == null) {
        // If no song is playing, play the first song
        await _togglePlay();
        return;
      }

      // Find current song index
      final currentIndex = allSongs.indexWhere(
        (s) => s.songId == currentSong.songId,
      );
      if (currentIndex == -1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Current song not found')));
        return;
      }

      // Calculate previous index
      final previousIndex = currentIndex > 0
          ? currentIndex - 1
          : allSongs.length - 1;
      final previousSong = allSongs[previousIndex];

      // Play the previous song
      await previousSong.play();
      _refreshState();
    } catch (e) {
      debugPrint('Previous song error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play previous song')),
        );
      }
    }
  }

  Future<void> _playNextSong() async {
    if (!mounted) return;

    try {
      // Get all available songs from the database
      final songMaps = await Song.getSongs();
      final allSongs = songMaps.map((map) => Song.fromMap(map)).toList();

      if (allSongs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No songs available')));
        return;
      }

      final currentSong = _song;
      if (currentSong == null) {
        // If no song is playing, play the first song
        await _togglePlay();
        return;
      }

      // Find current song index
      final currentIndex = allSongs.indexWhere(
        (s) => s.songId == currentSong.songId,
      );
      if (currentIndex == -1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Current song not found')));
        return;
      }

      // Calculate next index
      final nextIndex = currentIndex < allSongs.length - 1
          ? currentIndex + 1
          : 0;
      final nextSong = allSongs[nextIndex];

      // Play the next song
      await nextSong.play();
      _refreshState();
    } catch (e) {
      debugPrint('Next song error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play next song')),
        );
      }
    }
  }

  Future<void> _restartSong() async {
    if (!mounted || _song == null) return;

    try {
      final mgr = AudioPlayerManager.instance;

      // Check if the current song is playing
      final isCurrentSong = mgr.currentSong?.songId == _song!.songId;

      if (isCurrentSong) {
        // If it's the current song, seek to beginning and play
        await mgr.player.seek(Duration.zero);
        if (!mgr.player.playing) {
          await mgr.player.play();
        }
      } else {
        // If it's not the current song, restart it from beginning
        await _song!.play();
      }

      _refreshState();
    } catch (e) {
      debugPrint('Restart song error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unable to restart song')));
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paletteMain = widget.currentTheme != null
        ? KoePalette.shade(widget.currentTheme!.paletteName, 'main')
        : const Color(0xFF6B46C1);

    // If no song is playing, show minimal bar
    if (_song == null) {
      return Container(
        height: 64,
        color: paletteMain,
        child: const Center(
          child: Text(
            'No music playing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Calculate progress
    final progressPercent = _duration.inMilliseconds > 0
        ? (_currentPosition.inMilliseconds / _duration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Container(
      height: 80,
      color: paletteMain,
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 3,
            width: double.infinity,
            color: Colors.white.withOpacity(0.3),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(color: Colors.white),
            ),
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Song info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _song!.songName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _song!.artistName ?? "Unknown artist",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Previous button
                  GestureDetector(
                    onTap: _playPreviousSong,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Play/pause button
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: paletteMain,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Next button
                  GestureDetector(
                    onTap: _playNextSong,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Restart button
                  GestureDetector(
                    onTap: _restartSong,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.replay, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
