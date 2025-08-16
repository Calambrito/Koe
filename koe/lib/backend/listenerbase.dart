import 'theme.dart';
import 'discover.dart';

abstract class ListenerBase {
  int get userID;
  String get username;
  KoeTheme get theme;

  List<String> get notifications;
  List<String> get artists;
  Discover get discover;

  Future<void> addNotification(String message);
  Future<String> getUsername();
}
