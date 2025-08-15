import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light; // light or dark

  final Map<String, Map<String, Color>> palettes = {
    'Pumpkin': {
      'light': const Color(0xFFF6C1A6),
      'main': const Color(0xFFE76F2C),
    },
    'Apricot': {
      'light': const Color(0xFFF6E1A3),
      'main': const Color(0xFFD99E3B),
    },
    'Apple': {
      'light': const Color(0xFFC7E7B3),
      'main': const Color(0xFF4FB244),
    },
    'Teal': {
      'light': const Color(0xFFBCE6E3),
      'main': const Color(0xFF319DA0),
    },
    'Blueberry': {
      'light': const Color(0xFFC5D8F0),
      'main': const Color(0xFF4267B2),
    },
    'Eggplant': {
      'light': const Color(0xFFD9B7E5),
      'main': const Color(0xFFA349A4),
    },
    'Dragonfruit': {
      'light': const Color(0xFFF8CCF0),
      'main': const Color(0xFFD46BFF),
    },
  };

  String currentPalette = 'Dragonfruit';

  @override
  Widget build(BuildContext context) {
    final paletteLight = palettes[currentPalette]!['light']!;
    final paletteMain = palettes[currentPalette]!['main']!;

    return MaterialApp(
      title: 'Koe',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Koe'),
            actions: [
              // Theme toggle
              IconButton(
                icon: Icon(
                  themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    themeMode = themeMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  });
                },
              ),
              // Palette selector
              DropdownButton<String>(
                value: currentPalette,
                underline: const SizedBox(),
                dropdownColor: themeMode == ThemeMode.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                icon: Icon(
                  Icons.color_lens,
                  color: themeMode == ThemeMode.light
                      ? Colors.black
                      : Colors.white,
                ),
                items: palettes.keys
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p,
                            style: TextStyle(
                              color: themeMode == ThemeMode.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentPalette = value;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    'Hello John',
                    style: TextStyle(color: paletteMain),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              labelColor:
                  themeMode == ThemeMode.light ? Colors.black : Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: paletteMain,
              tabs: const [
                Tab(text: 'Playlists'),
                Tab(text: 'Discover'),
                Tab(text: 'Notifications'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildPlaylists(paletteLight, paletteMain),
              const Center(child: Text('Discover tab')),
              const Center(child: Text('Notifications tab')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylists(Color lightColor, Color mainColor) {
    return ListView(
      children: [
        _buildPlaylistTile(
          icon: Icons.history,
          title: 'Recently Played',
          subtitle: '4 songs',
          faceColor: mainColor,
          insideColor: lightColor,
          songs: [
            {'title': 'Alone', 'artist': 'Alan Walker'},
            {'title': 'Let me love you', 'artist': 'Justin Bieber feat DJ Snake'},
            {'title': 'Let me love you', 'artist': 'Justin Bieber feat DJ Snake'},
            {'title': 'Let me love you', 'artist': 'Justin Bieber feat DJ Snake'},
          ],
        ),
        _buildPlaylistTile(
          icon: Icons.favorite,
          title: 'Favorites',
          subtitle: '3 songs',
          faceColor: mainColor,
          insideColor: lightColor,
          songs: [
            {'title': 'Song A', 'artist': 'Artist 1'},
            {'title': 'Song B', 'artist': 'Artist 2'},
            {'title': 'Song C', 'artist': 'Artist 3'},
          ],
        ),
        _buildPlaylistTile(
          icon: Icons.fitness_center,
          title: 'Workout Mix',
          subtitle: '3 songs',
          faceColor: mainColor,
          insideColor: lightColor,
          songs: [
            {'title': 'Song D', 'artist': 'Artist 4'},
            {'title': 'Song E', 'artist': 'Artist 5'},
            {'title': 'Song F', 'artist': 'Artist 6'},
          ],
        ),
        _buildPlaylistTile(
          icon: Icons.spa,
          title: 'Chill Vibes',
          subtitle: '4 songs',
          faceColor: mainColor,
          insideColor: lightColor,
          songs: [
            {'title': 'Song G', 'artist': 'Artist 7'},
            {'title': 'Song H', 'artist': 'Artist 8'},
            {'title': 'Song I', 'artist': 'Artist 9'},
            {'title': 'Song J', 'artist': 'Artist 10'},
          ],
        ),
      ],
    );
  }

  Widget _buildPlaylistTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color faceColor,
  required Color insideColor,
  required List<Map<String, String>> songs,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // always black text inside
        ),
      ),
      child: ExpansionTile(
        collapsedBackgroundColor: faceColor, // stays dark
        backgroundColor: faceColor, // face remains dark even when expanded
        leading: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.15),
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black87),
        ),
        children: [
          Container(
            color: insideColor, // lighter background for songs only
            child: Column(
              children: songs
                  .map((song) => ListTile(
                        title: Text(song['title']!,
                            style: const TextStyle(color: Colors.black)),
                        subtitle: Text(song['artist']!,
                            style: const TextStyle(color: Colors.black54)),
                        trailing: const Icon(Icons.play_arrow, color: Colors.black),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

}
