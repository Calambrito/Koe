import 'database_helper.dart';
import 'theme.dart';
import 'user.dart';
import 'facades.dart';

class ProxyListener extends User {
  ProxyListener({
    required super.userID,
    required super.username,
    required super.theme,
  });
 
  static Future<ProxyListener> create(int userID) async {
    final userMap = await Facades.loadUserById(userID);

    return ProxyListener(
      userID: userMap['user_id'] as int,
      username: userMap['user_name'] as String,
      theme: userMap['theme'] as KoeTheme,
    );
  }

  Future<void> addNotification(String message) async {
    final db = await DatabaseHelper.getInstance().database;
    await db.insert('Notification', {
      'user_id': userID,
      'message': message,
    });
  }
}

