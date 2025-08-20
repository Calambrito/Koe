import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../backend/listener.dart' as klistener;
import '../backend/koe_palette.dart';
import '../backend/theme.dart';

class SubscriptionsPage extends StatefulWidget {
  final klistener.Listener listener;
  final KoeTheme currentTheme;

  const SubscriptionsPage({
    super.key,
    required this.listener,
    required this.currentTheme,
  });

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Map<String, dynamic>> _subscribedArtists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscribedArtists();
  }

  Future<void> _loadSubscribedArtists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final artists = await widget.listener.getSubscribedArtists();
      setState(() {
        _subscribedArtists = artists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscriptions: $e')),
        );
      }
    }
  }

  Future<void> _unsubscribeFromArtist(int artistId, String artistName) async {
    try {
      final success = await widget.listener.unsubscribeFromArtist(artistId);
      if (success) {
        setState(() {
          _subscribedArtists.removeWhere(
            (artist) => artist['artist_id'] == artistId,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsubscribed from $artistName')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to unsubscribe')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final KoeTheme theme = widget.currentTheme;
    final colorPalette = KoePalette.get(theme.paletteName);
    final backgroundColor = theme.isDarkMode ? Colors.black : Colors.white;
    final tileColor = colorPalette['light'] ?? Colors.grey[300]!;
    const borderRadius = BorderRadius.all(Radius.circular(14));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'My Subscriptions',
          style: TextStyle(
            color: theme.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _subscribedArtists.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 64,
                      color: theme.isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No subscriptions yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Subscribe to artists to get notified when they release new songs",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.isDarkMode
                            ? Colors.white54
                            : Colors.black45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _subscribedArtists.length,
                itemBuilder: (context, index) {
                  final artist = _subscribedArtists[index];
                  final artistName = artist['artist_name'] as String;
                  final artistId = artist['artist_id'] as int;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Material(
                      color: tileColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: borderRadius,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        leading: Icon(
                          LucideIcons.user,
                          size: 28,
                          color: Colors.black,
                        ),
                        title: Text(
                          artistName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: const Text(
                          'Subscribed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.unsubscribe,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _showUnsubscribeDialog(artistId, artistName),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showUnsubscribeDialog(int artistId, String artistName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsubscribe'),
          content: Text(
            'Are you sure you want to unsubscribe from $artistName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unsubscribeFromArtist(artistId, artistName);
              },
              child: const Text(
                'Unsubscribe',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
