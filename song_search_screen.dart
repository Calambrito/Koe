
import 'package:flutter/material.dart';

import '../backend/database_helper.dart';
import '../backend/search_strategy.dart';
import '../backend/search_context.dart';
import '../backend/artist_search.dart';
import '../backend/genre_search.dart';
import '../backend/song_search.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  late SongSearchContext searchContext;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  String currentSearchLabel = 'Search by song name';

  final Map<String, SongSearchStrategy> strategies = {
    'Song Name': SongNameSearchStrategy(),
    'Artist Name': ArtistSearchStrategy(),
    'Genre': GenreSearchStrategy(),
  };

  String selectedStrategyKey = 'Song Name';

  @override
  void initState() {
    super.initState();
    searchContext = SongSearchContext();
    searchContext.setStrategy(strategies[selectedStrategyKey]!);
  }

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await searchContext.search(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changeStrategy(String key) {
    final strategy = strategies[key];
    if (strategy == null) return;

    setState(() {
      selectedStrategyKey = key;
      searchContext.setStrategy(strategy);
      currentSearchLabel = 'Search by $key'.toLowerCase().replaceAllMapped(
          RegExp(r'\b\w'), (match) => match.group(0)!.toUpperCase());
      searchResults = [];
    });
  }

/*  Widget _buildResultItem(Map<String, dynamic> song) {
    return ListTile(
      title: Text(song['song_name'] ?? 'Unknown'),
      subtitle: Text('Genre: ${song['genre'] ?? 'N/A'}'),
    );
  }*/
  Widget _buildResultItem(Map<String, dynamic> song) {
  final songName = song['song_name'] ?? 'Unknown';
  final artistName = song['artist_name'] ?? 'Unknown Artist';
  final genre = song['genre'] ?? 'N/A';

  return ListTile(
    title: Text(songName),
    subtitle: Text('Artist: $artistName | Genre: $genre'),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Songs')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Dropdown to select search strategy
            DropdownButton<String>(
              value: selectedStrategyKey,
              items: strategies.keys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(key),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _changeStrategy(value);
                }
              },
            ),

            const SizedBox(height: 12),

            // Search input
            TextField(
              decoration: InputDecoration(
                labelText: currentSearchLabel,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _search,
            ),

            const SizedBox(height: 12),

            if (isLoading) const CircularProgressIndicator(),

            if (!isLoading)
              Expanded(
                child: searchResults.isEmpty
                    ? const Center(child: Text('No songs found'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildResultItem(searchResults[index]);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import '../backend/database_helper.dart';

class SongSearchScreen extends StatefulWidget {
  const SongSearchScreen({super.key});

  @override
  State<SongSearchScreen> createState() => _SongSearchScreenState();
}

class _SongSearchScreenState extends State<SongSearchScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.getInstance();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await dbHelper.searchSongs(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
 void _changeStrategy(SongSearchStrategy strategy) {
  setState(() {
    searchContext.setStrategy(strategy);
    searchResults = [];

    if (strategy is SongNameSearchStrategy) {
      currentSearchLabel = 'Search by song name';
    } else if (strategy is ArtistSearchStrategy) {
      currentSearchLabel = 'Search by artist name';
    } else if (strategy is GenreSearchStrategy) {
      currentSearchLabel = 'Search by genre';
    }
  });
}

  Widget _buildResultItem(Map<String, dynamic> song) {
    return ListTile(
      title: Text(song['song_name'] ?? 'Unknown'),
      subtitle: Text('Genre: ${song['genre'] ?? 'N/A'}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Songs')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search song by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading)
              Expanded(
                child: searchResults.isEmpty
                    ? const Center(child: Text('No songs found'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildResultItem(searchResults[index]);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

}*/
