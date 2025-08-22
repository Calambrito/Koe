import 'database_helper.dart';

class LoginManager {
  static final dbHelper = DatabaseHelper.getInstance();

  static Future<int> addUser({
    required String userName,
    required String password,
    bool isAdmin = false,
  }) async {
    // Security: Only allow admin creation for the specific hardcoded admin user
    if (isAdmin && (userName != 'cal' || password != '123')) {
      throw Exception('Admin creation is not allowed');
    }
    final db = await dbHelper.database;

    final existingUser = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: [userName.toLowerCase()],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Username "$userName" already exists');
    }

    return await db.insert('User', {
      'user_name': userName.toLowerCase(),
      'password': password,
      'is_admin': isAdmin ? 1 : 0,
    });
  }

  static Future<void> removeUser(int userId) async {
    final db = await dbHelper.database;

    await db.delete('Subscription', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete('Notification', where: 'user_id = ?', whereArgs: [userId]);

    final playlists = await db.query(
      'Playlist',
      columns: ['playlist_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    for (final playlist in playlists) {
      final playlistId = playlist['playlist_id'] as int;
      await db.delete(
        'Playlist_Songs',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
    }

    await db.delete('Playlist', where: 'user_id = ?', whereArgs: [userId]);

    await db.delete('User', where: 'user_id = ?', whereArgs: [userId]);
  }

  static Future<int?> authenticate(String username, String password) async {
    final db = await dbHelper.database;

    // Debug: Check if admin user exists
    if (username == 'cal') {
      final adminCheck = await db.query(
        'User',
        where: 'user_name = ?',
        whereArgs: [username],
        limit: 1,
      );
      print('DEBUG: Admin user check - Found: ${adminCheck.isNotEmpty}');
      if (adminCheck.isNotEmpty) {
        print('DEBUG: Admin user data: ${adminCheck.first}');
      }
    }

    // Special handling for admin user - don't convert to lowercase
    final whereArgs = username == 'cal'
        ? [username, password]
        : [username.toLowerCase(), password];

    final result = await db.query(
      'User',
      columns: ['user_id'],
      where: 'user_name = ? AND password = ?',
      whereArgs: whereArgs,
      limit: 1,
    );

    print(
      'DEBUG: Authentication result for $username - Found: ${result.isNotEmpty}',
    );
    if (result.isNotEmpty) {
      print('DEBUG: User ID: ${result.first['user_id']}');
    }

    return result.isNotEmpty ? result.first['user_id'] as int? : null;
  }

  static Future<bool> isAdmin(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'User',
      columns: ['is_admin', 'user_name'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    print(
      'DEBUG: isAdmin check for user $userId - Found: ${result.isNotEmpty}',
    );
    if (result.isNotEmpty) {
      print('DEBUG: User data: ${result.first}');
    }

    // Security: Only the specific hardcoded admin user can be admin
    if (result.isNotEmpty) {
      final isAdminFlag = result.first['is_admin'] == 1;
      final userName = result.first['user_name'] as String;

      print('DEBUG: isAdminFlag: $isAdminFlag, userName: $userName');
      // Only allow admin status for the specific hardcoded admin user
      final isAdmin = isAdminFlag && userName == 'cal';
      print('DEBUG: Final isAdmin result: $isAdmin');
      return isAdmin;
    }

    return false;
  }

  static Future<bool> userExists(String userName) async {
    final db = await dbHelper.database;

    // Special handling for admin user - don't convert to lowercase
    final whereArgs = userName == 'cal'
        ? [userName]
        : [userName.toLowerCase()];

    final result = await db.query(
      'User',
      columns: ['user_id'],
      where: 'user_name = ?',
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Security method to prevent admin promotion
  static Future<void> ensureUserIsNotAdmin(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'User',
      columns: ['user_name'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final userName = result.first['user_name'] as String;
      if (userName != 'cal') {
        // Ensure non-admin users cannot be promoted to admin
        await db.update(
          'User',
          {'is_admin': 0},
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  // Debug method to check all users in database
  static Future<void> debugCheckAllUsers() async {
    final db = await dbHelper.database;
    final allUsers = await db.query('User');

    print('=== DEBUG: All Users in Database ===');
    for (final user in allUsers) {
      print(
        'User ID: ${user['user_id']}, Username: ${user['user_name']}, Password: ${user['password']}, Is Admin: ${user['is_admin']}',
      );
    }
    print('=== END DEBUG ===');
  }

  // Debug method to force create admin user
  static Future<void> debugForceCreateAdmin() async {
    final db = await dbHelper.database;

    // Check if admin exists
    final existingAdmin = await db.query(
      'User',
      where: 'user_name = ?',
      whereArgs: ['cal'],
      limit: 1,
    );

    if (existingAdmin.isEmpty) {
      print('DEBUG: Creating admin user...');
      final adminId = await db.insert('User', {
        'user_name': 'cal',
        'password': '123',
        'is_admin': 1,
      });
      print('DEBUG: Admin user created with ID: $adminId');
    } else {
      print(
        'DEBUG: Admin user already exists with ID: ${existingAdmin.first['user_id']}',
      );
    }
  }
}
