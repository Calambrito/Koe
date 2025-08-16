import 'database_helper.dart';
import 'theme.dart';
import 'facades.dart';
import 'discover.dart';
import 'listener_base.dart'; // the interface

class ProxyListener extends User implements ListenerBase {
  List<String> _notifications = [];
  List<String> _artists = [];
  final Discover _discover = Discover();

  ProxyListener({
    required super.userID,
    required super.username,
    required super.theme,
  });

  @override
  List<String> get notifications => _notifications;

  @override
  List<String> get artists => _artists;

  @override
  Discover get discover => _discover;

  @override
  Future<String> getUsername() async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;
    final userRow = await db.query(
      'User',
      where: 'user_id = ?',
      whereArgs: [userID],
      limit: 1,
    );
    if (userRow.isNotEmpty) {
      return userRow.first['user_name'] as String;
    }
    throw Exception('User not found');
  }

  Future<void> loadFromDB() async {
    _notifications = await Facades.loadNotifications(userID);
    _artists = await Facades.loadArtists();
  }

  @override
  Future<void> addNotification(String message) async {
    final dbHelper = DatabaseHelper.getInstance();
    final db = await dbHelper.database;

    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });

    _notifications.add(message);
  }
}
