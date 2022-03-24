import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:personas/services/personaService.dart';
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

  static Future<void> savePersona(Persona persona) async {
    print(json.encode(persona));
    try {
      await http.post(
        Uri.parse("$apiEndpoint/auth/savePersona"),
        body: json.encode(persona),
      );
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<List<Persona>> getPersonas() async {
    try {
      final response = await http.get(
        Uri.parse("$apiEndpoint/auth/getPersonas"),
      );
      if (response.statusCode == 200) {
        final decodedPersona = json.decode(response.body);
        print(decodedPersona);
        List<Persona> personas = [];
        for (var persona in decodedPersona) {
          Persona _newPersona = new Persona();
          _newPersona.id = persona["id"];
          _newPersona.name = persona["data"]["name"];
          _newPersona.color = persona["data"]["color"];
          _newPersona.facts = persona["data"]["facts"];
          _newPersona.answers = persona["data"]["answers"];
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
}