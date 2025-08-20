import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'facades.dart';
import 'theme.dart';
import 'user.dart';
import 'discover.dart';

class Listener extends User {
  Listener._internal({
    required super.userID,
    required super.username,
    required super.theme,
  });
  List<int> playlists = [];
  List<String> notifications = [];
  List<String> artists = [];
  final Discover discover = Discover();

  static Future<Listener> create(int userID) async {
    final userMap = await Facades.loadUserById(userID);

    final listener = Listener._internal(
      userID: userMap['user_id'] as int,
      username: userMap['user_name'] as String,
      theme: userMap['theme'] as KoeTheme,
    );

    await listener.loadAll();
    return listener;
  }

  int get id => userID;
  String get name => username;

  Future<void> loadAll() async {
    playlists = await Facades.loadPlaylists(userID);
    notifications = await Facades.loadNotifications(userID);
    debugPrint("here are notifs");
    for (var i = 0; i < notifications.length; i++) {
      debugPrint("Notification $i: ${notifications[i]}");
    }
    artists = await Facades.loadArtists();
  }

  Future<void> createPlaylist(String playlistName) async {
    final db = await DatabaseHelper.getInstance().database;
    final playlistId = await db.insert('Playlist', {
      'playlist_name': playlistName,
      'user_id': userID,
    });
    playlists.add(playlistId);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final db = await DatabaseHelper.getInstance().database;

    await db.delete(
      'Playlist_Songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    await db.delete(
      'Playlist',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    playlists.remove(playlistId);
  }

  Future<bool> removeNotification(int userId, String message) async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      final rows = await db.delete(
        'Notification',
        where: 'user_id = ? AND message = ?',
        whereArgs: [userId, message],
      );

      if (rows > 0 && userID == userId) {
        notifications.removeWhere((n) => n == message);
      }

      return rows > 0;
    } catch (e) {
      return false;
    }
  }

  // Get user's subscribed artists
  Future<List<Map<String, dynamic>>> getSubscribedArtists() async {
    final db = await DatabaseHelper.getInstance().database;
    final subscriptions = await db.rawQuery(
      '''
      SELECT a.artist_id, a.artist_name
      FROM Artist a
      JOIN Subscription s ON a.artist_id = s.artist_id
      WHERE s.user_id = ?
      ORDER BY a.artist_name
    ''',
      [userID],
    );

    return subscriptions;
  }

  // Unsubscribe from an artist
  Future<bool> unsubscribeFromArtist(int artistId) async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      final rows = await db.delete(
        'Subscription',
        where: 'user_id = ? AND artist_id = ?',
        whereArgs: [userID, artistId],
      );
      return rows > 0;
    } catch (e) {
      return false;
    }
  }

  // Check if user is subscribed to an artist
  Future<bool> isSubscribedToArtist(int artistId) async {
    try {
      final db = await DatabaseHelper.getInstance().database;
      final result = await db.query(
        'Subscription',
        where: 'user_id = ? AND artist_id = ?',
        whereArgs: [userID, artistId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
