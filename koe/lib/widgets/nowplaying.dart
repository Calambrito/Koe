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

                  // Time display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
