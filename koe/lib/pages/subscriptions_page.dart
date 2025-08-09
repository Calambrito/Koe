// lib/pages/subscriptions_page.dart
import 'package:flutter/material.dart';
import '../backend/listener.dart' as blistener;
import '../backend/database_helper.dart';
import '../backend/song.dart';

class SubscriptionsPage extends StatefulWidget {
  final blistener.Listener listener;
  SubscriptionsPage({required this.listener});

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Map<String, dynamic>> _artists = [];
  Map<int, List<Song>> _artistSongs = {};

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final db = await DatabaseHelper.getInstance().database;
    final subs = await db.rawQuery('''
      SELECT Artist.artist_id, Artist.artist_name
      FROM Subscription JOIN Artist ON Subscription.artist_id = Artist.artist_id
      WHERE Subscription.user_id = ?
    ''', [widget.listener.userID]);

    setState(() => _artists = subs);

    for (final a in _artists) {
      final aid = a['artist_id'] as int;
      final songs = await db.rawQuery('''
        SELECT Songs.*, Artist.artist_name FROM Songs JOIN Artist ON Songs.artist_id = Artist.artist_id
        WHERE Artist.artist_id = ?
      ''', [aid]);

      _artistSongs[aid] = songs.map((m) => Song.fromMap(m)).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_artists.isEmpty) {
      return Center(child: Text('No subscriptions yet', style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      itemCount: _artists.length,
      itemBuilder: (ctx, i) {
        final a = _artists[i];
        final aid = a['artist_id'] as int;
        final name = a['artist_name'] as String? ?? '';
        final songs = _artistSongs[aid] ?? [];
        return ExpansionTile(
          title: Text(name, style: TextStyle(color: Colors.white)),
          children: songs.map((s) => ListTile(
            title: Text(s.songName, style: TextStyle(color: Colors.white)),
            subtitle: Text(s.duration ?? '-', style: TextStyle(color: Colors.white60)),
            trailing: IconButton(icon: Icon(Icons.play_arrow), onPressed: () => s.play()),
          )).toList(),
        );
      },
    );
  }
}
