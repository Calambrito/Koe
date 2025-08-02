import 'database_helper.dart';
import 'song.dart';

class Playlist {
  final String playlistId;
  String playlistName;
  List<Song> songs = [];

  Playlist({required this.playlistId, this.playlistName = ''}) {
    _initialize();
  }

  Future<void> _initialize() async {
    final dbHelper = DatabaseHelper();
    playlistName = await dbHelper.getPlaylistName(playlistId);
    await _loadSongs();
  }

  Future<void> _loadSongs() async {
    final dbHelper = DatabaseHelper();
    final songIds = await dbHelper.playlistToSong(playlistId);

    for (String id in songIds) {
      final songMap = await dbHelper.idToSong(id);
      songs.add(Song.fromMap(songMap));
    }
  }

  Future<void> addSong(Song song) async {
    songs.add(song);
  }

  Future<void> removeSong(Song song) async {
    songs.remove(song);
  }
}
