// lib/pages/playlist_detail_page.dart
import 'package:flutter/material.dart';
import '../backend/playlist.dart';
import '../backend/song.dart';

class PlaylistDetailPage extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  PlaylistDetailPage({required this.playlistId, required this.playlistName});

  @override
  _PlaylistDetailPageState createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  Playlist? _playlist;
  bool _shuffle = false;
  bool _loopSong = false;
  bool _loopPlaylist = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final p = Playlist(playlistId: widget.playlistId);
    // wait a small time to let it initialize
    await Future.delayed(Duration(milliseconds: 300));
    setState(() => _playlist = p);
  }

  Future<void> _removeSong(Song s) async {
    await _playlist?.removeSong(s);
    setState(() => _playlist?.songs.remove(s));
  }

  Future<void> _playSong(Song s) async {
    await s.play();
  }

  @override
  Widget build(BuildContext context) {
    if (_playlist == null) {
      return Scaffold(appBar: AppBar(title: Text(widget.playlistName)), body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(icon: Icon(_shuffle ? Icons.shuffle_on : Icons.shuffle), onPressed: () => setState(()=> _shuffle = !_shuffle)),
                IconButton(icon: Icon(_loopSong ? Icons.loop : Icons.repeat_one), onPressed: () => setState(()=> _loopSong = !_loopSong)),
                IconButton(icon: Icon(_loopPlaylist ? Icons.repeat_on : Icons.repeat), onPressed: () => setState(()=> _loopPlaylist = !_loopPlaylist)),
                Spacer(),
                Text('${_playlist!.songs.length} songs', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: _playlist!.songs.isEmpty
              ? Center(child: Text('No songs in this playlist', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                itemCount: _playlist!.songs.length,
                itemBuilder: (ctx, i) {
                  final s = _playlist!.songs[i];
                  return ListTile(
                    title: Text(s.songName, style: TextStyle(color: Colors.white)),
                    subtitle: Text('${s.artistName ?? ''} • ${s.duration ?? '-'}', style: TextStyle(color: Colors.white60)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'remove') _removeSong(s);
                      },
                      itemBuilder: (_) => [PopupMenuItem(value: 'remove', child: Text('Remove'))],
                    ),
                    onTap: () => _playSong(s),
                  );
                },
              ),
          )
        ],
      ),
    );
  }
}
