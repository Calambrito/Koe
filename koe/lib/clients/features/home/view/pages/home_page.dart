import 'package:flutter/material.dart';
import 'package:koe/clients/features/home/widgets/song_card.dart';
import 'package:koe/core/theme/app_pallete.dart';
import 'package:koe/backend/song.dart';
import 'package:koe/clients/features/home/services/song_service.dart';
import 'package:koe/clients/features/home/services/audio_player_service.dart';
import 'package:koe/clients/features/home/view/pages/music_player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: Replace with actual data from backend
  List<Song> madeForYouSongs = [];
  List<Song> topPicksSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs(); // Load songs from service
  }

  /// Loads songs from the song service
  /// TODO: Replace with actual API calls to fetch songs from backend
  Future<void> _loadSongs() async {
    try {
      // Load both sections in parallel for better performance
      final results = await Future.wait([
        SongService.instance.getMadeForYouSongs(),
        SongService.instance.getTopPicksSongs(),
      ]);

      setState(() {
        madeForYouSongs = results[0];
        topPicksSongs = results[1];
      });
    } catch (e) {
      // TODO: Handle error properly (show error message to user)
      print('Error loading songs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Made for you section
                    _buildSectionHeader('Made for you'),
                    const SizedBox(height: 16),
                    _buildSongList(madeForYouSongs),

                    const SizedBox(height: 32),

                    // Top picks for you section
                    _buildSectionHeader('Top picks for you'),
                    const SizedBox(height: 16),
                    _buildSongList(topPicksSongs),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section header with the given title
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Pallete.whiteColor,
      ),
    );
  }

  /// Builds a list of song cards for the given songs
  Widget _buildSongList(List<Song> songs) {
    return Column(
      children: songs.map((song) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: SongCard(song: song, onTap: () => _handleSongTap(song)),
        );
      }).toList(),
    );
  }

  /// Handles when a song card is tapped
  /// Navigates to the music player page
  Future<void> _handleSongTap(Song song) async {
    try {
      // Navigate to music player page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MusicPlayerPage(
            song: song,
            sourceContext: 'SEARCH', // You can customize this based on context
          ),
        ),
      );
    } catch (e) {
      // TODO: Show error message to user
      print('Error navigating to music player: $e');
    }
  }
}
