# Koe Music Streaming App

A Flutter-based music streaming application with a modern dark theme UI, designed to be easily connected to a backend system.

## 🎵 Features

### ✅ Implemented
- **Modern Dark Theme UI** - Clean, Spotify-inspired design
- **Home Dashboard** - Music recommendations with "Made for you" and "Top picks for you" sections
- **Song Cards** - Beautiful song display with album art, title, artist, and lyrics tags
- **Bottom Navigation** - Home, Search, Your Library, and Premium tabs
- **Audio Player Service** - Ready for backend integration
- **Song Service** - Mock data service that can be easily replaced with API calls
- **Responsive Design** - Works on different screen sizes

### 🚧 Coming Soon
- User authentication (Login/Signup)
- Search functionality
- Library management
- Premium features
- Playlist creation
- User preferences

## 📁 Project Structure

```
lib/
├── clients/features/
│   ├── auth/                    # Authentication feature
│   │   ├── view/pages/         # Auth pages (login, signup)
│   │   └── widgets/            # Auth-specific widgets
│   └── home/                   # Home feature
│       ├── view/pages/         # Home pages
│       ├── widgets/            # Home-specific widgets
│       └── services/           # Home services
├── core/theme/                 # App theme and colors
└── backend/                    # Data models and database helpers
```

## 🎨 UI Components

### Song Card
- Album art thumbnail with dynamic colors
- Song title and artist name
- "LYRICS" tag
- Options button (three dots)
- Tap to play functionality

### Bottom Navigation
- Home (active by default)
- Search (placeholder)
- Your Library (placeholder)
- Premium (placeholder)

## 🔧 Backend Integration Guide

### 1. Song Service (`lib/clients/features/home/services/song_service.dart`)

**Current Implementation:**
```dart
// Mock data - replace with actual API calls
Future<List<Song>> getMadeForYouSongs() async {
  // TODO: Replace with actual API call
  // Example: return await ApiService.instance.getMadeForYouSongs();
}
```

**To Connect to Backend:**
1. Create an `ApiService` class
2. Replace mock data with HTTP requests
3. Update error handling
4. Add loading states

**Example API Integration:**
```dart
class ApiService {
  static const String baseUrl = 'https://your-api.com';
  
  Future<List<Song>> getMadeForYouSongs() async {
    final response = await http.get('$baseUrl/songs/recommended');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }
}
```

### 2. Audio Player Service (`lib/clients/features/home/services/audio_player_service.dart`)

**Current Implementation:**
- Uses `just_audio` package
- Handles play, pause, stop, seek operations
- Ready for backend integration

**To Connect to Backend:**
1. Update song URLs to point to your server
2. Add authentication headers for protected content
3. Implement streaming for large files
4. Add analytics tracking

### 3. Database Integration (`lib/backend/`)

**Current Implementation:**
- SQLite database with proper schema
- User, Artist, Song, Playlist tables
- Ready for local caching

**To Connect to Backend:**
1. Use as local cache for offline playback
2. Sync with remote database
3. Implement conflict resolution

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Dependencies
- `sqflite` - Local database
- `just_audio` - Audio playback
- `path_provider` - File system access
- `path` - Path manipulation

## 🎯 Next Steps for Backend Integration

### 1. API Service Layer
```dart
// Create lib/services/api_service.dart
class ApiService {
  // Authentication
  Future<User> login(String email, String password);
  Future<User> signup(String name, String email, String password);
  
  // Songs
  Future<List<Song>> getRecommendedSongs();
  Future<List<Song>> searchSongs(String query);
  Future<List<Song>> getSongsByArtist(String artistId);
  
  // User
  Future<List<Playlist>> getUserPlaylists();
  Future<void> createPlaylist(String name);
  Future<void> addSongToPlaylist(String playlistId, String songId);
}
```

### 2. State Management
```dart
// Add Provider or Riverpod for state management
dependencies:
  provider: ^6.0.0
  # or
  riverpod: ^2.0.0
```

### 3. Authentication Flow
```dart
// Create auth service
class AuthService {
  Future<User?> getCurrentUser();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
```

### 4. Error Handling
```dart
// Create error handling service
class ErrorService {
  void showError(String message);
  void showSuccess(String message);
  void showLoading();
}
```

## 🎨 Customization

### Colors
Edit `lib/core/theme/app_pallete.dart` to customize the color scheme:

```dart
class Pallete {
  static const Color backgroundColor = Color.fromRGBO(18, 18, 18, 1);
  static const Color gradient1 = Color.fromRGBO(187, 63, 221, 1);
  static const Color gradient2 = Color.fromRGBO(251, 109, 169, 1);
  // Add your custom colors here
}
```

### Theme
Edit `lib/core/theme/theme.dart` to customize the overall theme:

```dart
class AppTheme {
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    // Add your custom theme properties
  );
}
```

## 📱 Screenshots

The app features:
- Dark theme with gradient accents
- Clean song cards with album art
- Bottom navigation
- Responsive design

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
1. Check the TODO comments in the code
2. Review the backend integration guide
3. Create an issue for bugs or feature requests

---

**Note:** This is a frontend implementation ready for backend integration. All mock data and services are designed to be easily replaced with actual API calls.
