import 'theme.dart';
import 'discover.dart';
import 'database_helper.dart';

class User {
  final int userID;
  final String username;
  final KoeTheme theme;

  List<int> playlists = [];
  List<String> notifications = [];
  List<String> artists = [];
  final Discover discover = Discover();

  User({
    required this.userID,
    required this.username,
    required this.theme,
  });

  Future<void> addNotification(String message) async {
    final db = await DatabaseHelper.getInstance().database;
    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });
    notifications.add(message);
  }

  Future<String> getUsernameFromDB() async {
    final db = await DatabaseHelper.getInstance().database;
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
}
