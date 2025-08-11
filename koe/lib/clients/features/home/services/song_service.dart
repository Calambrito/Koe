import 'package:koe/backend/song.dart';

/// Service class for handling song-related operations
/// TODO: Replace mock data with actual API calls to backend
class SongService {
  static final SongService _instance = SongService._internal();

  SongService._internal();

  static SongService get instance => _instance;

  /// Fetches songs for the "Made for you" section
  /// TODO: Replace with actual API call to backend
  Future<List<Song>> getMadeForYouSongs() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with actual API call
    // Example: return await ApiService.instance.getMadeForYouSongs();

    return [
      Song(
        songId: 1,
        songName: 'Alone',
        url: 'mock_url_1',
        artistName: 'Alan Walker',
        genre: 'Electronic',
      ),
      Song(
        songId: 2,
        songName: 'Let me love you',
        url: 'mock_url_2',
        artistName: 'Justin Bieber feat DJ Snake',
        genre: 'Pop',
      ),
      Song(
        songId: 3,
        songName: 'Let me love you',
        url: 'mock_url_3',
        artistName: 'Justin Bieber feat DJ Snake',
        genre: 'Pop',
      ),
      Song(
        songId: 4,
        songName: 'Let me love you',
        url: 'mock_url_4',
        artistName: 'Justin Bieber feat DJ Snake',
        genre: 'Pop',
      ),
    ];
  }

  /// Fetches songs for the "Top picks for you" section
  /// TODO: Replace with actual API call to backend
  Future<List<Song>> getTopPicksSongs() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with actual API call
    // Example: return await ApiService.instance.getTopPicksSongs();

    return [
      Song(
        songId: 5,
        songName: 'Alone',
        url: 'mock_url_5',
        artistName: 'Alan Walker',
        genre: 'Electronic',
      ),
      Song(
        songId: 6,
        songName: 'Shape of You',
        url: 'mock_url_6',
        artistName: 'Ed Sheeran',
        genre: 'Pop',
      ),
      Song(
        songId: 7,
        songName: 'Blinding Lights',
        url: 'mock_url_7',
        artistName: 'The Weeknd',
        genre: 'Pop',
      ),
    ];
  }

  /// Searches for songs by query
  /// TODO: Replace with actual API call to backend
  Future<List<Song>> searchSongs(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: Replace with actual API call
    // Example: return await ApiService.instance.searchSongs(query);

    // Mock search results
    final allSongs = await getMadeForYouSongs();
    return allSongs
        .where(
          (song) =>
              song.songName.toLowerCase().contains(query.toLowerCase()) ||
              (song.artistName?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  /// Gets songs by artist
  /// TODO: Replace with actual API call to backend
  Future<List<Song>> getSongsByArtist(String artistName) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with actual API call
    // Example: return await ApiService.instance.getSongsByArtist(artistName);

    final allSongs = await getMadeForYouSongs();
    return allSongs
        .where(
          (song) =>
              song.artistName?.toLowerCase().contains(
                artistName.toLowerCase(),
              ) ??
              false,
        )
        .toList();
  }

  /// Gets songs by genre
  /// TODO: Replace with actual API call to backend
  Future<List<Song>> getSongsByGenre(String genre) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with actual API call
    // Example: return await ApiService.instance.getSongsByGenre(genre);

    final allSongs = await getMadeForYouSongs();
    return allSongs
        .where(
          (song) =>
              song.genre?.toLowerCase().contains(genre.toLowerCase()) ?? false,
        )
        .toList();
  }
}
