// lib/pages/user_home_page.dart
import 'package:flutter/material.dart';
import '../backend/listener.dart' as blistener;
import 'playlists_page.dart';
import 'discover_page.dart';
import 'subscriptions_page.dart';
import 'notifications_page.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

enum HomeTab { playlists, subscriptions, discover, notifications }

class _UserHomePageState extends State<UserHomePage> {
  HomeTab _selected = HomeTab.playlists;
  int? _userId;
  String? _username;
  blistener.Listener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    _userId ??= args['userId'] as int?;
    _username ??= args['username'] as String?;
    if (_listener == null && _userId != null) {
      blistener.Listener.loadUserById(_userId!).then((l) {
        setState(() => _listener = l);
      }).catchError((e) {
        // ignore
      });
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // large Koe text (they said they'd toggle later - so easily changeable)
          Text('Koe', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
                  margin: EdgeInsets.only(right: 16),
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: isSelected ? 26 : 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    child: Text(label),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _bodyForTab() {
    if (_listener == null) {
      return Center(child: CircularProgressIndicator());
    }

    switch (_selected) {
      case HomeTab.playlists:
        return PlaylistsPage(listener: _listener!);
      case HomeTab.subscriptions:
        return SubscriptionsPage(listener: _listener!);
      case HomeTab.discover:
        return DiscoverPage(listener: _listener!);
      case HomeTab.notifications:
        return NotificationsPage(listener: _listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username ?? 'User'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: () => Navigator.of(context).pushReplacementNamed('/')),
        ],
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _bodyForTab()),
        ],
      ),
    );
  }
}
