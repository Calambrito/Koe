// user_portal.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../backend/listener.dart' as klistener;
import 'discover.dart';
import 'playlists.dart';
import 'subscriptions.dart';
import 'notifications.dart';
import '../backend/song.dart';
import '../backend/audio_player_manager.dart';
import '../widgets/now_playing_bar.dart';

class UserPortal extends StatefulWidget {
  final klistener.Listener listener;
  const UserPortal({super.key, required this.listener});

  @override
  State<UserPortal> createState() => _UserPortalState();
}

enum HomeTab { playlists, subscriptions, discover, notifications }

class _UserPortalState extends State<UserPortal> {
  HomeTab _selected = HomeTab.playlists;
  Song? _currentSong;
  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSub;
  int? _loadingSongId;

  @override
  void initState() {
    super.initState();
    // Keep _isPlaying synced to actual player state
    _playingSub =
        AudioPlayerManager.instance.player.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isPlaying = playing);
    });
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    super.dispose();
  }

  Future<void> _playSong(Song song) async {
    try {
      // Toggle if same song tapped
      if (_currentSong != null && _currentSong!.songId == song.songId) {
        if (_isPlaying) {
          await AudioPlayerManager.instance.player.pause();
        } else {
          await AudioPlayerManager.instance.player.play();
        }
        return;
      }

      // Stop previous song
      if (_currentSong != null) {
        await AudioPlayerManager.instance.player.stop();
      }

      // Show NowPlayingBar immediately
      if (!mounted) return;
      setState(() {
        _currentSong = song;
        _isPlaying = false;
      });

      _loadingSongId = song.songId;

      // Load and play
      await AudioPlayerManager.instance.setUrl(song.url);
      if (_loadingSongId != song.songId) return;
      await AudioPlayerManager.instance.player.play();

      _loadingSongId = null;
    } catch (e) {
      print('Error playing song: $e');
      if (mounted) {
        setState(() {
          _currentSong = null;
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_currentSong == null) return;
    try {
      if (_isPlaying) {
        await AudioPlayerManager.instance.player.pause();
      } else {
        await AudioPlayerManager.instance.player.play();
      }
    } catch (e) {
      print('Error toggling playback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Koe",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushReplacementNamed('/'),
                    child: Text(
                      widget.listener.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: HomeTab.values.map((tab) {
                    final label = {
                      HomeTab.playlists: 'Playlists',
                      HomeTab.subscriptions: 'Subscriptions',
                      HomeTab.discover: 'Discover',
                      HomeTab.notifications: 'Notifications',
                    }[tab]!;
                    final isSelected = _selected == tab;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = tab),
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w200,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          child: Text(label),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Colors.grey),

            // Main content
            Expanded(child: _buildTabContent()),

            // Now playing bar
            if (_currentSong != null)
              NowPlayingBar(
                song: _currentSong!,
                isPlaying: _isPlaying,
                onPlayPause: _togglePlayPause,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selected) {
      case HomeTab.playlists:
        return PlaylistsPage(
          listener: widget.listener,
          onSongSelected: _playSong,
        );
      case HomeTab.subscriptions:
        return SubscriptionsPage(
          artists: widget.listener.artists,
          onSongSelected: _playSong,
        );
      case HomeTab.discover:
        return DiscoverPage(
          discover: widget.listener.discover,
          playlists: widget.listener.playlists,
          userID: widget.listener.userID,
          onSongSelected: _playSong,
        );
      case HomeTab.notifications:
        return NotificationsPage(
          notifications: widget.listener.notifications,
        );
    }
  }
}
