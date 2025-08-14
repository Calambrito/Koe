import 'package:flutter/material.dart';
import 'package:koe/backend/song.dart';
import 'package:koe/core/theme/app_pallete.dart';
import 'package:koe/clients/features/home/services/audio_player_service.dart';

class MusicPlayerPage extends StatefulWidget {
  final Song song;
  final String? sourceContext; // e.g., "SEARCH", "PLAYLIST", etc.

  const MusicPlayerPage({super.key, required this.song, this.sourceContext});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  bool isPlaying = true;
  bool isLiked = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = const Duration(
    minutes: 3,
    seconds: 36,
  ); // Default duration
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startProgressTimer();
  }

  void _initializePlayer() async {
    try {
      await AudioPlayerService.instance.playSong(widget.song);

      // Get actual duration from audio player
      final duration = await AudioPlayerService.instance.getDuration();
      if (duration != null) {
        setState(() {
          totalDuration = duration;
          isPlaying = true;
        });
      }
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  void _startProgressTimer() async {
    // Get actual position and duration from audio player
    final position = await AudioPlayerService.instance.getCurrentPosition();
    final duration = await AudioPlayerService.instance.getDuration();

    if (mounted && position != null && duration != null) {
      setState(() {
        currentPosition = position;
        totalDuration = duration;
        progress = position.inMilliseconds / duration.inMilliseconds;
      });
    }

    // Continue updating every second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _startProgressTimer();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button and context
            _buildTopBar(),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Album art section
                    _buildAlbumArtSection(),

                    const SizedBox(height: 32),

                    // Song details section
                    _buildSongDetailsSection(),

                    const SizedBox(height: 32),

                    // Progress bar section
                    _buildProgressSection(),

                    const SizedBox(height: 40),

                    // Playback controls
                    _buildPlaybackControls(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Pallete.whiteColor,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Context information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAYING FROM ${widget.sourceContext ?? 'SEARCH'}',
                  style: const TextStyle(
                    color: Pallete.subtitleText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"${widget.song.songName}" in Songs',
                  style: const TextStyle(
                    color: Pallete.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArtSection() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _getAlbumArtColor(),
      ),
      child: Stack(
        children: [
          // Album art background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getAlbumArtColor(),
                      _getAlbumArtColor().withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _getAlbumArtText(),
                    style: const TextStyle(
                      color: Pallete.whiteColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // Artist names overlay
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              widget.song.artistName ?? 'Unknown Artist',
              style: const TextStyle(
                color: Pallete.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Song title overlay (large and centered)
          Positioned.fill(
            child: Center(
              child: Text(
                widget.song.songName.toUpperCase(),
                style: const TextStyle(
                  color: Pallete.whiteColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongDetailsSection() {
    return Row(
      children: [
        // Song title and artist
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.song.songName,
                style: const TextStyle(
                  color: Pallete.whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                widget.song.artistName ?? 'Unknown Artist',
                style: const TextStyle(
                  color: Pallete.subtitleText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Like button
        GestureDetector(
          onTap: () {
            setState(() {
              isLiked = !isLiked;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isLiked ? Colors.red : Pallete.whiteColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Pallete.whiteColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Pallete.whiteColor,
            inactiveTrackColor: Pallete.whiteColor.withOpacity(0.3),
            thumbColor: Pallete.whiteColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 3,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                progress = value;
                currentPosition = Duration(
                  milliseconds: (value * totalDuration.inMilliseconds).round(),
                );
              });
            },
            onChangeEnd: (value) async {
              // Seek to position in audio player when user finishes dragging
              final seekPosition = Duration(
                milliseconds: (value * totalDuration.inMilliseconds).round(),
              );
              try {
                await AudioPlayerService.instance.seekTo(seekPosition);
              } catch (e) {
                print('Error seeking to position: $e');
              }
            },
          ),
        ),

        const SizedBox(height: 8),

        // Time indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(currentPosition),
              style: const TextStyle(color: Pallete.whiteColor, fontSize: 14),
            ),
            Text(
              _formatDuration(totalDuration),
              style: const TextStyle(color: Pallete.whiteColor, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip backward button
        GestureDetector(
          onTap: () async {
            final newPosition = currentPosition - const Duration(seconds: 10);
            final seekPosition = newPosition.isNegative
                ? Duration.zero
                : newPosition;
            try {
              await AudioPlayerService.instance.seekTo(seekPosition);
            } catch (e) {
              print('Error skipping backward: $e');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.replay_10,
              color: Pallete.whiteColor,
              size: 32,
            ),
          ),
        ),

        // Play/Pause button
        GestureDetector(
          onTap: () async {
            setState(() {
              isPlaying = !isPlaying;
            });
            try {
              if (isPlaying) {
                await AudioPlayerService.instance.resume();
              } else {
                await AudioPlayerService.instance.pause();
              }
            } catch (e) {
              // Revert state if operation failed
              setState(() {
                isPlaying = !isPlaying;
              });
              print('Error toggling playback: $e');
            }
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Pallete.whiteColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Pallete.backgroundColor,
              size: 40,
            ),
          ),
        ),

        // Skip forward button
        GestureDetector(
          onTap: () async {
            final newPosition = currentPosition + const Duration(seconds: 10);
            final seekPosition = newPosition > totalDuration
                ? totalDuration
                : newPosition;
            try {
              await AudioPlayerService.instance.seekTo(seekPosition);
            } catch (e) {
              print('Error skipping forward: $e');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.forward_10,
              color: Pallete.whiteColor,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Color _getAlbumArtColor() {
    final songName = widget.song.songName.toLowerCase();
    if (songName.contains('alone')) {
      return const Color(0xFF2E7D32); // Green
    } else if (songName.contains('let me love you')) {
      return const Color(0xFF546E7A); // Blue-gray
    } else if (songName.contains('shape of you')) {
      return const Color(0xFF2E7D32); // Green
    } else if (songName.contains('blinding lights')) {
      return const Color(0xFF6A1B9A); // Purple
    } else if (songName.contains('stay')) {
      return const Color(0xFF1565C0); // Blue for Stay
    } else {
      // Fallback colors
      final colors = [
        const Color(0xFF2C3E50), // Dark blue-gray
        const Color(0xFF8B4513), // Dark brown
        const Color(0xFF4A148C), // Dark purple
        const Color(0xFF1B5E20), // Dark green
        const Color(0xFFB71C1C), // Dark red
      ];
      final hash = widget.song.songName.hashCode;
      return colors[hash.abs() % colors.length];
    }
  }

  String _getAlbumArtText() {
    final songName = widget.song.songName.toLowerCase();
    if (songName.contains('alone')) {
      return 'W\nALONE\nALAN';
    } else if (songName.contains('let me love you')) {
      return 'LET ME\nLOVE YOU';
    } else if (songName.contains('shape of you')) {
      return 'S';
    } else if (songName.contains('blinding lights')) {
      return 'B';
    } else if (songName.contains('stay')) {
      return 'STAY';
    } else {
      return widget.song.songName.isNotEmpty
          ? widget.song.songName[0].toUpperCase()
          : '?';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
