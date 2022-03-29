library auth;

class UserData {
  final String id;
  final String token;
  final String username;
  final bool seenIntro;
  UserData({this.id, this.token, this.username, this.seenIntro});
}