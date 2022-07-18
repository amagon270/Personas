import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personas/services/personaService.dart';
import 'package:personas/services/supaBaseService.dart';
import 'package:personas/types/auth.dart';

class Auth {
  // static String apiEndpoint = "https://question-matrix-creator-gamma.vercel.app/api";
  static String apiEndpoint = "http://localhost:3000/api";

  static Future<UserData?> login(String _username, String _password) async {
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
        SupaBaseService().authToken = token.body;
        return UserData(
          id: decodedUser["id"].toString(), 
          token: token.body, 
          username: _username, 
          seenIntro: decodedUser["seenIntro"]
        );
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<UserData?> signup(String _username, String _password) async {
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
        SupaBaseService().authToken = token.body;
        return UserData(
          id: decodedUser["id"].toString(), 
          token: token.body, 
          username: _username,
          seenIntro: decodedUser["seenIntro"]  
        );
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<int> savePersona(Persona persona) async {
    String token = SupaBaseService().authToken;
    try {
      var _response = await http.post(
        Uri.parse("$apiEndpoint/auth/savePersona"),
        headers: {
          "Authorization": "Bearer " + token,
        },
        body: json.encode(persona),
      );
      return json.decode(_response.body)["id"];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<List<Persona>?> getPersonas() async {
    String token = SupaBaseService().authToken;
    try {
      final response = await http.get(
        Uri.parse("$apiEndpoint/auth/getPersonas"),
        headers: {
          "Authorization": "Bearer " + token,
        },
      );
      if (response.statusCode == 200) {
        final decodedPersona = json.decode(response.body);
        List<Persona> personas = [];
        for (var persona in decodedPersona) {
          Persona _newPersona = new Persona.fromJson(persona);
          personas.add(_newPersona);
        }
        return personas;
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<String?> getQuestionMatrix() async {
    try {
      final response = await http.get(
        Uri.parse("$apiEndpoint/export"),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<bool> watchIntro() async {
    try {
      String token = SupaBaseService().authToken;
      final success = await http.post(
        Uri.parse("$apiEndpoint/auth/watchIntro"),
        headers: {
          "Authorization": "Bearer " + token,
        },
      );
      return success.statusCode == 200;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}