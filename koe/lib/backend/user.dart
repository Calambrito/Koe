import 'theme.dart';
import 'database_helper.dart';

class User {
  final int userID;
  final String username;
  KoeTheme theme;


  User({
    required this.userID,
    required this.username,
    required this.theme,
  });

  

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
