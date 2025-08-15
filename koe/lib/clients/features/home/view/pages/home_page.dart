import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koe/backend/song.dart';
import 'package:koe/clients/features/home/services/song_service.dart';
import 'package:koe/clients/features/home/view/pages/music_player_page.dart';
import 'package:koe/core/theme/theme_provider.dart';
import 'package:koe/core/widgets/color_palette_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // TODO: Replace with actual data from backend
  List<Song> madeForYouSongs = [];
  List<Song> topPicksSongs = [];
  List<Song> recentlyPlayedSongs = [];
  List<Song> trendingSongs = [];
  List<Song> librarySongs = [];

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Notification state management
  List<Map<String, dynamic>> _notifications = [];

  // User name - replace with actual user data from backend
  final String _userName = 'John'; // This should come from user authentication

  // Custom tab selection
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSongs(); // Load songs from service
    _loadNotifications(); // Load notifications
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Loads songs from the song service
  /// TODO: Replace with actual API calls to fetch songs from backend
  Future<void> _loadSongs() async {
    try {
      // Load all sections in parallel for better performance
      final results = await Future.wait([
        SongService.instance.getMadeForYouSongs(),
        SongService.instance.getTopPicksSongs(),
        SongService.instance.getMadeForYouSongs(), // Using same data for demo
        SongService.instance.getTopPicksSongs(), // Using same data for demo
        SongService.instance.getMadeForYouSongs(), // Library songs
      ]);

      setState(() {
        madeForYouSongs = results[0];
        topPicksSongs = results[1];
        recentlyPlayedSongs = results[2];
        trendingSongs = results[3];
        librarySongs = results[4];
      });
    } catch (e) {
      // TODO: Handle error properly (show error message to user)
      print('Error loading songs: $e');
    }
  }

  /// Loads notifications
  void _loadNotifications() {
    // Sample notifications data - replace with actual data from backend
    _notifications = [
      {
        'id': '1',
        'title': 'New song from Alan Walker',
        'subtitle': 'Alone is now available',
        'icon': Icons.music_note,
        'color': Colors.blue,
      },
      {
        'id': '2',
        'title': 'Playlist updated',
        'subtitle': 'Your "Favorites" playlist has new songs',
        'icon': Icons.playlist_play,
        'color': Colors.green,
      },
      {
        'id': '3',
        'title': 'Artist followed',
        'subtitle': 'You are now following Ed Sheeran',
        'icon': Icons.person,
        'color': Colors.purple,
      },
      {
        'id': '4',
        'title': 'New album released',
        'subtitle': 'Shape of You album is now available',
        'icon': Icons.album,
        'color': Colors.orange,
      },
      {
        'id': '5',
        'title': 'Concert reminder',
        'subtitle': 'Ed Sheeran concert in 2 days',
        'icon': Icons.event,
        'color': Colors.red,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildHeader(context, isDarkMode),

            // Navigation tabs
            _buildCustomNavigationTabs(context, isDarkMode),

            // Tab content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildPlaylistsTab(context, isDarkMode),
                    _buildDiscoverTab(context, isDarkMode),
                    _buildNotificationsTab(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // App title - left aligned
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Koe',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),

          const Spacer(),

          // Hello [Name] - right aligned
          GestureDetector(
            onLongPress: () => _showUserOptionsDialog(context, isDarkMode),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Hello ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: _userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
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

  Widget _buildCustomNavigationTabs(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem(context, 0, 'Playlists', isDarkMode),
            _buildTabItem(context, 1, 'Discover', isDarkMode),
            _buildTabItem(context, 2, 'Notifications', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: isSelected ? 27 : 18,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist expansion tiles
          _buildPlaylistExpansionTiles(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPlaylistExpansionTiles(BuildContext context, bool isDarkMode) {
    // Sample playlist data - you can replace with actual data from backend
    final playlists = [
      {
        'name': 'Recently Played',
        'songs': madeForYouSongs,
        'icon': Icons.history,
      },
      {'name': 'Favorites', 'songs': topPicksSongs, 'icon': Icons.favorite},
      {
        'name': 'Workout Mix',
        'songs': trendingSongs,
        'icon': Icons.fitness_center,
      },
      {
        'name': 'Chill Vibes',
        'songs': recentlyPlayedSongs,
        'icon': Icons.nights_stay,
      },
    ];

    return Column(
      children: playlists.map((playlist) {
        return _buildPlaylistExpansionTile(
          context,
          playlist['name'] as String,
          playlist['songs'] as List<Song>,
          playlist['icon'] as IconData,
          isDarkMode,
        );
      }).toList(),
    );
  }

  Widget _buildPlaylistExpansionTile(
    BuildContext context,
    String playlistName,
    List<Song> songs,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        iconColor: Theme.of(context).colorScheme.onSurface,
        collapsedIconColor: Theme.of(context).colorScheme.onSurface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlistName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${songs.length} songs',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          // Songs list inside the expansion tile
          Column(
            children: songs.map((song) {
              return GestureDetector(
                onTap: () => _handleSongTap(song),
                onLongPress: () => _showDeleteDialog(song, playlistName),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF0F0F0F)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Song name and artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songName,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artistName ?? 'Unknown Artist',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play icon
                      Icon(
                        Icons.play_arrow,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search songs...',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                suffixIcon: Icon(
                  Icons.tune,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // All songs list with lazy loading
          Expanded(child: _buildAllSongsList(context, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildAllSongsList(BuildContext context, bool isDarkMode) {
    // Combine all songs from different sources for the discover page
    final allSongs = [
      ...madeForYouSongs,
      ...topPicksSongs,
      ...recentlyPlayedSongs,
      ...trendingSongs,
      ...librarySongs,
    ];

    // Filter songs based on search query
    final filteredSongs = _searchQuery.isEmpty
        ? allSongs
        : allSongs.where((song) {
            final songName = song.songName.toLowerCase();
            final artistName = (song.artistName ?? '').toLowerCase();
            return songName.contains(_searchQuery) ||
                artistName.contains(_searchQuery);
          }).toList();

    if (allSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No songs available',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchQuery.isNotEmpty && filteredSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No songs found for "$_searchQuery"',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different song or artist',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        return _buildSongListItem(context, song, isDarkMode);
      },
    );
  }

  Widget _buildSongListItem(BuildContext context, Song song, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _handleSongTap(song),
      onLongPress: () => _showSongOptionsDialog(song),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Song number or album art placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getAlbumArtColor(song),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  _getAlbumArtText(song),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Song details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.songName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artistName ?? 'Unknown Artist',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Play icon
            Icon(
              Icons.play_arrow,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Implement loading indicator when needed
  // Widget _buildLoadingIndicator() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     child: const Center(
  //       child: CircularProgressIndicator(
  //         color: Color(0xFF9C27B0),
  //         strokeWidth: 2,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNotificationsTab(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notifications list with swipe to clear
        Expanded(child: _buildNotificationsList(context, isDarkMode)),
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context, bool isDarkMode) {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Dismissible(
          key: Key(notification['id'] as String),
          background: _buildDismissBackground(),
          secondaryBackground: _buildDismissBackground(),
          onDismissed: (direction) {
            _removeNotification(notification['id'] as String);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationItem(
              context,
              notification['title'] as String,
              notification['subtitle'] as String,
              notification['icon'] as IconData,
              notification['color'] as Color,
              isDarkMode,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.delete, color: Colors.white, size: 24),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement horizontal section when needed
  // Widget _buildHorizontalSection(String title, List<Song> songs) {
  //   if (songs.isEmpty) return const SizedBox.shrink();
  //   // Implementation for horizontal song sections
  // }

  Color _getAlbumArtColor(Song song) {
    final songName = song.songName.toLowerCase();
    if (songName.contains('alone')) {
      return const Color(0xFF2E7D32); // Green
    } else if (songName.contains('let me love you')) {
      return const Color(0xFF546E7A); // Blue-gray
    } else if (songName.contains('shape of you')) {
      return const Color(0xFF2E7D32); // Green
    } else if (songName.contains('blinding lights')) {
      return const Color(0xFF6A1B9A); // Purple
    } else if (songName.contains('stay')) {
      return const Color(0xFF1565C0); // Blue
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

  String _getAlbumArtText(Song song) {
    final songName = song.songName.toLowerCase();
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
      return song.songName.isNotEmpty ? song.songName[0].toUpperCase() : '?';
    }
  }

  /// Handles when a song card is tapped
  /// Navigates to the music player page
  Future<void> _handleSongTap(Song song) async {
    try {
      // Navigate to music player page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              MusicPlayerPage(song: song, sourceContext: 'DISCOVER'),
        ),
      );
    } catch (e) {
      // TODO: Show error message to user
      print('Error navigating to music player: $e');
    }
  }

  /// Shows delete confirmation dialog for songs in playlists
  void _showDeleteDialog(Song song, String playlistName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Song',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${song.songName}" from "$playlistName"?',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSongFromPlaylist(song, playlistName);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Deletes a song from the playlist
  void _deleteSongFromPlaylist(Song song, String playlistName) {
    // TODO: Implement actual deletion logic with backend
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${song.songName} removed from $playlistName',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // TODO: Update the playlist data and refresh the UI
    // You would typically:
    // 1. Call backend API to remove song from playlist
    // 2. Update local state
    // 3. Refresh the UI
    print('Deleted ${song.songName} from $playlistName');
  }

  /// Shows options dialog for songs in discover tab
  void _showSongOptionsDialog(Song song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            song.songName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subscribe to artist option
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blue),
                title: const Text(
                  'Subscribe to Artist',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  'Follow ${song.artistName ?? 'Unknown Artist'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _subscribeToArtist(song);
                },
              ),
              // Add to playlist option
              ListTile(
                leading: const Icon(
                  Icons.playlist_add,
                  color: Color(0xFF9C27B0),
                ),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                subtitle: const Text(
                  'Add to existing or create new playlist',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPlaylistSelectionDialog(song);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows playlist selection dialog
  void _showPlaylistSelectionDialog(Song song) {
    // Sample playlists - replace with actual data from backend
    final playlists = [
      'Recently Played',
      'Favorites',
      'Workout Mix',
      'Chill Vibes',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add to Playlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create new playlist option
              ListTile(
                leading: const Icon(Icons.add, color: Color(0xFF9C27B0)),
                title: const Text(
                  'Create New Playlist',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCreatePlaylistDialog(song);
                },
              ),
              const Divider(color: Colors.grey),
              // Existing playlists
              ...playlists.map(
                (playlistName) => ListTile(
                  leading: const Icon(Icons.playlist_play, color: Colors.white),
                  title: Text(
                    playlistName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addSongToPlaylist(song, playlistName);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows create playlist dialog
  void _showCreatePlaylistDialog(Song song) {
    final playlistNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create New Playlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: playlistNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter playlist name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9C27B0)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                final playlistName = playlistNameController.text.trim();
                if (playlistName.isNotEmpty) {
                  Navigator.of(context).pop();
                  _createPlaylistAndAddSong(song, playlistName);
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Subscribe to artist functionality
  void _subscribeToArtist(Song song) {
    // TODO: Implement artist subscription with backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Subscribed to ${song.artistName ?? 'Unknown Artist'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    print('Subscribed to artist: ${song.artistName}');
  }

  /// Add song to existing playlist
  void _addSongToPlaylist(Song song, String playlistName) {
    // TODO: Implement adding song to playlist with backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${song.songName} added to $playlistName',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    print('Added ${song.songName} to playlist: $playlistName');
  }

  /// Create new playlist and add song
  void _createPlaylistAndAddSong(Song song, String playlistName) {
    // TODO: Implement playlist creation and song addition with backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Created playlist "$playlistName" and added ${song.songName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    print('Created playlist: $playlistName and added song: ${song.songName}');

    // TODO: Update the playlist data and refresh the UI
    // The new playlist should appear in the Playlists tab
  }

  /// Removes a notification from the frontend only
  void _removeNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere(
        (notification) => notification['id'] == notificationId,
      );
    });
    print('Notification removed from frontend: $notificationId');
  }

  /// Shows user options dialog (theme switch and logout)
  void _showUserOptionsDialog(BuildContext context, bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme switch option
                ListTile(
                  leading: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: isDarkMode ? Colors.yellow : Colors.blue,
                  ),
                  title: Text(
                    isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    themeProvider.toggleTheme();
                  },
                ),
                
                const Divider(),
                
                // Color palette selector
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ColorPaletteSelector(),
                ),
                
                const Divider(),
                
                // Logout option
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle logout functionality
  void _logout() {
    // TODO: Implement actual logout logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Logging out...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    print('User logged out');

    // TODO: Navigate to login page or clear user session
  }
}
