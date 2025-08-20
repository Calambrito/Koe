// lib/frontend/user_portal.dart
import 'package:flutter/material.dart';
import '../backend/listener.dart' as klistener;
import '../backend/theme.dart';
import '../backend/koe_palette.dart';
import '../backend/audio_player_manager.dart';
import 'login_page.dart';
import '../widgets/settings_panel.dart';
import '../widgets/custom_nav_tabs.dart';
import 'notifications.dart';
import 'playlists.dart';
import 'discover.dart';
import 'subscriptions.dart';
import '../widgets/nowplaying.dart'; // <-- new import

class UserPortal extends StatefulWidget {
  final klistener.Listener listener;

  const UserPortal({super.key, required this.listener});

  @override
  State<UserPortal> createState() => _UserPortalState();
}

class _UserPortalState extends State<UserPortal> {
  bool _showSettings = false;
  late KoeTheme _currentTheme;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.listener.theme;
  }

  void _toggleSettings() => setState(() => _showSettings = !_showSettings);

  void _saveSettings() {
    setState(() {
      _showSettings = false;
      widget.listener.theme = _currentTheme;
    });
  }

  void _logout() async {
    try {
      // Stop and reset the audio player when logging out
      final audioManager = AudioPlayerManager.instance;
      await audioManager.reset();
    } catch (e) {
      print('Error stopping audio on logout: $e');
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _openSubscriptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionsPage(
          listener: widget.listener,
          currentTheme: _currentTheme,
        ),
      ),
    );
  }

  void _updateTheme(KoeTheme theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return PlaylistsPage(
          listener: widget.listener,
          currentTheme: _currentTheme,
        );
      case 1:
        return DiscoverPage(
          listener: widget.listener,
          currentTheme: _currentTheme,
        );
      case 2:
        return NotificationsPage(
          listener: widget.listener,
          currentTheme: _currentTheme,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = KoePalette.get(_currentTheme.paletteName);

    return Scaffold(
      backgroundColor: _currentTheme.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koe',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 38,
                  color: _currentTheme.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: _toggleSettings,
                onLongPress: _toggleSettings,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentTheme.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hello ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _currentTheme.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: widget.listener.username,
                          style: TextStyle(
                            fontSize: 20,
                            color: colorPalette['main']!,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNavTabs(
                selectedIndex: _selectedTabIndex,
                onTabSelected: _onTabSelected,
                currentTheme: _currentTheme,
              ),
              Expanded(
                child: Container(
                  // Add bottom padding to avoid overlap with now playing bar
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
          if (_showSettings)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              right: 0,
              top: 0,
              bottom: 80, // Account for NowPlayingBar height
              width: MediaQuery.of(context).size.width * 0.85,
              child: SettingsPanel(
                currentTheme: _currentTheme,
                updateTheme: _updateTheme,
                saveSettings: _saveSettings,
                logout: _logout,
                onSubscriptionsTap: _openSubscriptions,
              ),
            ),

          // Now playing bar pinned to bottom (visible across tabs)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NowPlayingBar(currentTheme: _currentTheme),
          ),
        ],
      ),
    );
  }
}
