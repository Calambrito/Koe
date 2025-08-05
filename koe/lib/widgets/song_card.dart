import 'package:flutter/material.dart';
import '../backend/song.dart'; // Import your backend

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const Icon(Icons.music_note, size: 40),
        title: Text(
          song.songName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(song.artistId ?? 'Unknown Artist'),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}