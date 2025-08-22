import 'package:flutter_test/flutter_test.dart';
import 'package:koe/backend/song.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite FFI for pure Dart tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Song DB Workflow Regression Tests', () {
    late dynamic db;

    setUp(() async {
      // Open in-memory database
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);

      // Create Songs table
      await db.execute('''
        CREATE TABLE Songs (
          song_id INTEGER PRIMARY KEY,
          song_name TEXT NOT NULL,
          url TEXT NOT NULL,
          duration TEXT,
          genre TEXT,
          artist_id INTEGER,
          artist_name TEXT
        )
      ''');
    });

    tearDown(() async {
      await db.close();
    });

    test('Insert and retrieve a song', () async {
      // Arrange
      final song = Song(
        songId: 1,
        songName: 'Test Song',
        url: 'https://example.com/audio.mp3',
        duration: '03:00',
        genre: 'Pop',
        artistId: 123,
        artistName: 'Test Artist',
      );

      // Act
      await db.insert('Songs', song.toMap());
      final results = await db.query('Songs', where: 'song_id = ?', whereArgs: [1]);

      // Assert
      expect(results.length, 1);
      final fetchedSong = Song.fromMap(results.first);
      expect(fetchedSong.songId, song.songId);
      expect(fetchedSong.songName, song.songName);
      expect(fetchedSong.artistName, song.artistName);
    });

    test('Update a song', () async {
      final song = Song(
        songId: 2,
        songName: 'Old Song',
        url: 'https://example.com/old.mp3',
        duration: '02:00',
        genre: 'Rock',
        artistId: 101,
        artistName: 'Old Artist',
      );

      await db.insert('Songs', song.toMap());

      // Update
      final updatedSong = Song(
        songId: 2,
        songName: 'Updated Song',
        url: 'https://example.com/new.mp3',
        duration: '02:30',
        genre: 'Rock',
        artistId: 101,
        artistName: 'Updated Artist',
      );

      await db.update('Songs', updatedSong.toMap(), where: 'song_id = ?', whereArgs: [2]);

      final results = await db.query('Songs', where: 'song_id = ?', whereArgs: [2]);
      final fetched = Song.fromMap(results.first);

      expect(fetched.songName, 'Updated Song');
      expect(fetched.artistName, 'Updated Artist');
    });

    test('Delete a song', () async {
      final song = Song(
        songId: 3,
        songName: 'Delete Me',
        url: 'https://example.com/delete.mp3',
        duration: '01:30',
        genre: 'Pop',
        artistId: 200,
        artistName: 'Artist X',
      );

      await db.insert('Songs', song.toMap());

      // Delete
      await db.delete('Songs', where: 'song_id = ?', whereArgs: [3]);

      final results = await db.query('Songs', where: 'song_id = ?', whereArgs: [3]);
      expect(results.isEmpty, true);
    });
  });
}