// lib/pages/discover_page.dart
import 'package:flutter/material.dart';
import '../backend/discover.dart';
import '../backend/song.dart';
import '../backend/song_search.dart';
import '../backend/genre_search.dart';
import '../backend/artist_search.dart';
import '../backend/database_helper.dart';
import '../backend/playlist.dart';
import '../backend/listener.dart' as blistener;

class DiscoverPage extends StatefulWidget {
  final blistener.Listener listener;
  DiscoverPage({required this.listener});

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchController = TextEditingController();
  List<Song> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _results = []; });

    final disc = Discover();
    if (q.toLowerCase().startsWith('by:')) {
      disc.setStrategy(ArtistSearchStrategy());
      await Future.delayed(Duration(milliseconds: 20));
      _results = await disc.search(q.substring(3).trim());
    } else if (q.toLowerCase().startsWith('genre:')) {
      disc.setStrategy(GenreSearchStrategy());
      _results = await disc.search(q.substring(6).trim());
    } else {
      disc.setStrategy(SongNameSearchStrategy());
      _results = await disc.search(q);
    }

    setState(() { _loading = false; });
  }

  Future<void> _showAddToPlaylist(Song song) async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.query('Playlist', where: 'user_id = ?', whereArgs: [widget.listener.userID]);
    final playlists = rows;
    String? picked;
    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) {
          return Container(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add to playlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (playlists.isEmpty) Text('No playlists. Create one below.'),
                ...playlists.map((p) {
                  return ListTile(
                    title: Text((p['playlist_name'] as String?) ?? 'Unnamed'),
                    onTap: () async {
                      final pid = p['playlist_id'] as int;
                      // add song to playlist
                      await db.insert('Playlist_Songs', {'playlist_id': pid, 'song_id': int.parse(song.songId)});
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to ${p['playlist_name']}')));
                    },
                  );
                }).toList(),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Create new playlist & add'),
                  onPressed: () async {
                    final nameController = TextEditingController();
                    final res = await showDialog<String>(context: context, builder: (_) => AlertDialog(
                      title: Text('New Playlist'),
                      content: TextField(controller: nameController),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, nameController.text.trim()), child: Text('Create')),
                      ],
                    ));
                    if (res != null && res.isNotEmpty) {
                      final pid = await db.insert('Playlist', {'playlist_name': res, 'user_id': widget.listener.userID});
                      await db.insert('Playlist_Songs', {'playlist_id': pid, 'song_id': int.parse(song.songId)});
                      Navigator.pop(context); // close bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created $res and added song')));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _subscribeToArtist(Song s) async {
    final db = await DatabaseHelper.getInstance().database;
    if (s.artistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unknown artist')));
      return;
    }
    try {
      await db.insert('Subscription', {'user_id': widget.listener.userID, 'artist_id': int.parse(s.artistId!)});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Subscribed to ${s.artistName}')));
      // optionally create playlist of that artist's songs in subscriptions page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Already subscribed or error')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _resultTile(Song s) {
    return GestureDetector(
      onLongPress: () async {
        await showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text('Add to playlist'), onTap: () { Navigator.pop(context); _showAddToPlaylist(s); }),
              ListTile(title: Text('Subscribe to artist'), onTap: () { Navigator.pop(context); _subscribeToArtist(s); }),
            ],
          ),
        );
      },
      child: ListTile(
        title: Text(s.songName, style: TextStyle(color: Colors.white)),
        subtitle: Text('${s.artistName ?? '-'} • ${s.duration ?? '-'}', style: TextStyle(color: Colors.white60)),
        trailing: IconButton(icon: Icon(Icons.play_arrow), onPressed: () => s.play()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search (use "by:artist", "genre:rock" or free text)',
                  filled: true,
                ),
                onSubmitted: (_) => _search(),
              )),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _search, child: Text('Search'))
            ],
          ),
        ),
        if (_loading) LinearProgressIndicator(),
        Expanded(
          child: _results.isEmpty
            ? Center(child: Text('No results - try searching', style: TextStyle(color: Colors.white70)))
            : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (ctx, i) => _resultTile(_results[i]),
              ),
        ),
      ],
    );
  }
}
