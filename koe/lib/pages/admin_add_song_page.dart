// lib/pages/admin_add_song_page.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../backend/database_helper.dart';
import '../backend/admin.dart';
import '../backend/theme.dart';
import '../backend/audio_player_manager.dart';

class AdminAddSongPage extends StatefulWidget {
  @override
  _AdminAddSongPageState createState() => _AdminAddSongPageState();
}

class _AdminAddSongPageState extends State<AdminAddSongPage> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _genreController = TextEditingController();

  List<String> _artists = [];
  String? _selectedArtist;
  bool _loading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.query('Artist', orderBy: 'artist_name ASC');
    setState(() {
      _artists = rows.map((r) => r['artist_name'] as String).toList();
      if (_artists.isNotEmpty) _selectedArtist = _artists.first;
    });
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '';
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    final ss = s.toString().padLeft(2, '0');
    return '$m:$ss';
  }

  Future<void> _fetchDuration(String url) async {
    setState(() {
      _status = 'Fetching duration...';
    });
    try {
      // use audio manager to set url and read duration
      await AudioPlayerManager.instance.setUrl(url);
      // wait a bit for duration to be populated
      await Future.delayed(Duration(milliseconds: 200));
      final dur = AudioPlayerManager.instance.player.duration;
      setState(() {
        _status = 'Duration: ${_formatDuration(dur)}';
      });
    } catch (e) {
      setState(() {
        _status = 'Could not fetch duration: ${e.toString()}';
      });
    }
  }

  Future<void> _addSongPressed() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    final genre = _genreController.text.trim();
    final artist = _selectedArtist;

    if (name.isEmpty || url.isEmpty || artist == null || artist.isEmpty) {
      setState(() => _status = 'Please fill required fields');
      return;
    }

    setState(() => _loading = true);

    try {
      // get duration
      await AudioPlayerManager.instance.setUrl(url);
      await Future.delayed(Duration(milliseconds: 200));
      final dur = AudioPlayerManager.instance.player.duration;
      final durStr = dur != null ? '${dur.inMinutes}:${dur.inSeconds.remainder(60).toString().padLeft(2, '0')}' : null;

      // create an Admin object temporarily (you might want to pass admin props; using dummy)
      final admin = Admin(userID: 0, username: 'admin', theme: KoeTheme.green);
      await admin.addSong(
        songName: name,
        url: url,
        duration: durStr,
        genre: genre.isEmpty ? null : genre,
        artistName: artist,
      );

      setState(() {
        _status = 'Song added successfully';
        _nameController.clear();
        _urlController.clear();
        _genreController.clear();
      });
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(color: Colors.white70);
    return Scaffold(
      appBar: AppBar(title: Text('Add Song')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Song Name', labelStyle: label, filled: true),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'URL', labelStyle: label, filled: true),
              onEditingComplete: () {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) _fetchDuration(url);
              },
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedArtist,
                    items: _artists.map((a) => DropdownMenuItem(child: Text(a), value: a)).toList(),
                    onChanged: (v) => setState(() => _selectedArtist = v),
                    decoration: InputDecoration(labelText: 'Artist', labelStyle: label, filled: true),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh artists',
                  icon: Icon(Icons.refresh),
                  onPressed: _loadArtists,
                )
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: _genreController,
              decoration: InputDecoration(labelText: 'Genre (optional)', labelStyle: label, filled: true),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _addSongPressed,
              child: _loading ? CircularProgressIndicator() : Text('Add Song'),
            ),
            SizedBox(height: 12),
            if (_status != null) Text(_status!, style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
