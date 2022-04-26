library auth;

class UserData {
  final String id;
  final String token;
  final String username;
  final bool seenIntro;
  UserData({required this.id, required this.token, required this.username, required this.seenIntro});
}