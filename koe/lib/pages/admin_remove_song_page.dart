// lib/pages/admin_remove_song_page.dart
import 'package:flutter/material.dart';
import '../backend/database_helper.dart';
import '../backend/song.dart';
import '../backend/admin.dart';

class AdminRemoveSongPage extends StatefulWidget {
  @override
  _AdminRemoveSongPageState createState() => _AdminRemoveSongPageState();
}

class _AdminRemoveSongPageState extends State<AdminRemoveSongPage> {
  List<Map<String, dynamic>> _rows = [];
  Set<int> _selected = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.rawQuery('''
      SELECT Songs.song_id, Songs.song_name, Songs.url, Songs.duration, Songs.genre, Artist.artist_name
      FROM Songs LEFT JOIN Artist ON Songs.artist_id = Artist.artist_id
      ORDER BY song_name ASC
    ''');
    setState(() {
      _rows = rows;
      _selected.clear();
    });
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm delete'),
        content: Text('Delete ${_selected.length} selected songs? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      // remove songs
      final admin = Admin(userID: 0, username: 'admin', theme: null as dynamic); // theme unused
      for (final id in _selected.toList()) {
        // create temporary Song wrapper for delete method
        final song = Song(songId: id.toString(), songName: '', url: '');
        await admin.removeSong(song);
      }
      await _loadSongs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Songs'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadSongs),
          if (_selected.isNotEmpty)
            IconButton(icon: Icon(Icons.delete_forever), onPressed: _loading ? null : _deleteSelected),
        ],
      ),
      body: _rows.isEmpty
          ? Center(child: Text('No songs found', style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _rows.length,
              itemBuilder: (ctx, i) {
                final r = _rows[i];
                final id = r['song_id'] as int;
                final artist = r['artist_name'] ?? 'Unknown';
                final title = r['song_name'] ?? '';
                final url = r['url'] ?? '';
                final selected = _selected.contains(id);

                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) _selected.remove(id); else _selected.add(id);
                  }),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white12 : Color(0xFF0B0C0D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selected ? Colors.redAccent : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Checkbox(value: selected, onChanged: (v) {
                          setState(() {
                            if (v == true) _selected.add(id); else _selected.remove(id);
                          });
                        }),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('$artist • ${r['duration'] ?? '-'}', style: TextStyle(color: Colors.white60)),
                            SizedBox(height: 2),
                            Text(url, style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
