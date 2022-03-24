import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personas/types/auth.dart';

class Auth {
  // static String apiEndpoint = "https://question-matrix-creator-gamma.vercel.app/api";
  static String apiEndpoint = "http://localhost:3000/api";

  static Future<UserData> login(String _username, String _password) async {
    try {
      final token = await http.post(
        Uri.parse("$apiEndpoint/auth/login"),
        body: {
          "password": _password,
          "username": _username
        },
      );
      if (token.statusCode == 200) {
        final _user = await http.get(
          Uri.parse("$apiEndpoint/auth/getMe"),
          headers: {
            "Authorization": "Bearer " + token.body,
          },
        );
        final decodedUser = json.decode(_user.body);
        print(decodedUser);
        return UserData(id: decodedUser["id"].toString(), token: token.body, username: _username);
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<UserData> signup(String _username, String _password) async {
    try {
      final token = await http.post(
        Uri.parse("$apiEndpoint/auth/signup"),
        body: {
          "password": _password,
          "username": _username
        },
      );
      if (token.statusCode == 200) {
        final _user = await http.get(
          Uri.parse("$apiEndpoint/auth/getMe"),
          headers: {
            "Authorization": "Bearer " + token.body,
          },
        );
        final decodedUser = json.decode(_user.body);
        return UserData(id: decodedUser["id"].toString(), token: token.body, username: _username);
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}