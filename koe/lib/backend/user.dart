/*import 'theme.dart';

class User {
  final String userID;
  final String username;
  final KoeTheme theme;

  const User({required this.userID, required this.username, required this.theme});
}*/
import 'theme.dart';
import 'discover.dart';

class User {
  final String userID;
  final String username;
  final KoeTheme theme;

  final Discover discover;

  User({
    required this.userID,
    required this.username,
    required this.theme,
  }) : discover = Discover();  // initialize discover

}
