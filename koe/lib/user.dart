enum Theme {
  green,
  blue,
  pink,
}

class User {
  final String userID;
  final String username;
  final Theme theme;

  const User({required this.userID, required this.username, required this.theme});
}