// lib/pages/playlists_page.dart
import 'package:flutter/material.dart';
import '../backend/listener.dart' as blistener;
import '../backend/database_helper.dart';
import 'playlist_detail_page.dart';

class PlaylistsPage extends StatefulWidget {
  final blistener.Listener listener;
  PlaylistsPage({required this.listener});

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  List<Map<String, dynamic>> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.query('Playlist', where: 'user_id = ?', whereArgs: [widget.listener.userID]);
    setState(() => _playlists = rows);
  }

  Future<void> _createPlaylist() async {
    final nameController = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Create Playlist'),
        content: TextField(controller: nameController, decoration: InputDecoration(labelText: 'Playlist name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, nameController.text.trim()), child: Text('Create')),
        ],
      ),
    );

    if (res != null && res.isNotEmpty) {
      await widget.listener.createPlaylist(res);
      await _loadPlaylists();
    }
  }

  Future<void> _renamePlaylist(int id) async {
    final db = await DatabaseHelper.getInstance().database;
    final row = await db.query('Playlist', where: 'playlist_id = ?', whereArgs: [id], limit: 1);
    final current = row.first['playlist_name'] as String? ?? '';
    final nameController = TextEditingController(text: current);
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Rename Playlist'),
        content: TextField(controller: nameController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, nameController.text.trim()), child: Text('Rename')),
        ],
      ),
    );

    if (res != null && res.isNotEmpty) {
      await db.update('Playlist', {'playlist_name': res}, where: 'playlist_id = ?', whereArgs: [id]);
      await _loadPlaylists();
    }
  }

  Future<void> _deletePlaylist(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete playlist?'),
        content: Text('Are you sure you want to delete this playlist?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.listener.deletePlaylist(id);
      await _loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          if (_playlists.isEmpty)
            Expanded(child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 64),
                    onPressed: _createPlaylist,
                  ),
                  SizedBox(height: 8),
                  Text('No playlists yet. Tap + to create one.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ))
          else
            Expanded(child: ListView.builder(
              itemCount: _playlists.length,
              itemBuilder: (ctx, i) {
                final p = _playlists[i];
                final id = p['playlist_id'] as int;
                final name = p['playlist_name'] as String? ?? 'Unnamed';
                return ListTile(
                  title: Text(name, style: TextStyle(color: Colors.white)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (s) {
                      if (s == 'rename') _renamePlaylist(id);
                      if (s == 'delete') _deletePlaylist(id);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaylistDetailPage(playlistId: id, playlistName: name)));
                  },
                );
              },
            )),
          SizedBox(height: 8),
          ElevatedButton.icon(onPressed: _createPlaylist, icon: Icon(Icons.add), label: Text('Create Playlist')),
        ],
      ),
    );
  }
}
