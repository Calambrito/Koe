import 'package:flutter/material.dart';
import 'package:koe/core/theme/app_pallete.dart';
import 'package:koe/backend/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongCard({super.key, required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Album art thumbnail
            _buildAlbumArt(),
            const SizedBox(width: 12),

            // Song information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song title
                  Text(
                    song.songName,
                    style: const TextStyle(
                      color: Pallete.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Lyrics tag and artist name
                  Row(
                    children: [
                      _buildLyricsTag(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          song.artistName ?? 'Unknown Artist',
                          style: const TextStyle(
                            color: Pallete.subtitleText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the album art thumbnail
  Widget _buildAlbumArt() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _getAlbumArtColor(),
      ),
      child: Center(
        child: Text(
          _getAlbumArtText(),
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the lyrics tag
  Widget _buildLyricsTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LYRICS',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Returns a color for the album art based on song name
  /// TODO: Replace with actual album art images from backend
  Color _getAlbumArtColor() {
    if (song.songName.toLowerCase().contains('alone')) {
      return const Color(0xFF2E7D32); // Green for Alone
    } else if (song.songName.toLowerCase().contains('let me love you')) {
      return const Color(0xFF546E7A); // Blue-gray for Let me love you
    } else if (song.songName.toLowerCase().contains('shape of you')) {
      return const Color(0xFF2E7D32); // Green for Shape of You
    } else if (song.songName.toLowerCase().contains('blinding lights')) {
      return const Color(0xFF6A1B9A); // Purple for Blinding Lights
    } else {
      // Fallback colors
      final colors = [
        const Color(0xFF2C3E50), // Dark blue-gray
        const Color(0xFF8B4513), // Dark brown
        const Color(0xFF4A148C), // Dark purple
        const Color(0xFF1B5E20), // Dark green
        const Color(0xFFB71C1C), // Dark red
      ];
      final hash = song.songName.hashCode;
      return colors[hash.abs() % colors.length];
    }
  }

  /// Returns text to display on album art
  /// TODO: Replace with actual album art images from backend
  String _getAlbumArtText() {
    if (song.songName.toLowerCase().contains('alone')) {
      return 'W\nALONE\nALAN';
    } else if (song.songName.toLowerCase().contains('let me love you')) {
      return 'LET ME\nLOVE YOU';
    } else if (song.songName.toLowerCase().contains('shape of you')) {
      return 'S';
    } else if (song.songName.toLowerCase().contains('blinding lights')) {
      return 'B';
    } else {
      // Fallback: show first letter of song name
      return song.songName.isNotEmpty ? song.songName[0].toUpperCase() : '?';
    }
  }
}
