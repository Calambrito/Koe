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

  @override
  void initState() {
    super.initState();
    _refreshState();
    // lightweight poll to catch changes from other screens' setState calls
    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _refreshState();
    });
  }

  void _refreshState() {
    final mgr = AudioPlayerManager.instance;
    Song? curr;
    bool playing = false;
    try {
      curr = mgr.currentSong;
      playing = mgr.player.playing == true;
    } catch (_) {
      curr = mgr.currentSong;
      // fallback: assume playing if currentSong non-null (not ideal but safe)
      playing = mgr.currentSong != null;
    }

    if (curr?.songId != _song?.songId || playing != _isPlaying) {
      setState(() {
        _song = curr;
        _isPlaying = playing;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final mgr = AudioPlayerManager.instance;
    if (_song == null) return;

    try {
      final isPlayingThis = mgr.currentSong?.songId == _song!.songId && (mgr.player.playing == true);
      if (isPlayingThis) {
        await mgr.player.pause();
      } else {
        // if same song loaded, resume; otherwise setUrl -> play via Song.play()
        if (mgr.currentSong?.songId == _song!.songId) {
          await mgr.player.play();
        } else {
          await _song!.play();
        }
      }
      // immediate UI feedback
      _refreshState();
    } catch (e) {
      debugPrint('NowPlaying toggle error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to toggle playback')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paletteMain = widget.currentTheme != null
        ? KoePalette.shade(widget.currentTheme!.paletteName, 'main')
        : Colors.blue;

    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: paletteMain,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // song info
          Expanded(
            child: _song == null
                ? const Text(
                    'Not playing',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _song!.songName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_song!.artistName ?? "Unknown artist"} • ${_song!.duration ?? ""}',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),

          // big play/pause
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 36,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: paletteMain,
              ),
              onPressed: _song == null ? null : _togglePlay,
            ),
          ),
        ],
      ),
    );
  }
}
