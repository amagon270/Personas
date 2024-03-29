import 'dart:convert';

import 'package:personas/services/personaService.dart';
import 'package:personas/services/supaBaseService.dart';
import 'package:personas/types/auth.dart';
import 'package:personas/widgets/utility.dart';
import 'package:flutter/foundation.dart';

import 'auth.dart';

class User with ChangeNotifier, DiagnosticableTreeMixin {
  String id;
  String username;
  String token;
  bool hasWatchedIntro;
  bool enableTimer;

  User() {
    getUserData();
  }

  void watchIntro() async {
    hasWatchedIntro = true;
    await Auth.watchIntro();
    setUserData();
  }

  void login(String username, String password) async {
    UserData newUser = await Auth.login(username, password);
    assignUserData(newUser);
  }

  void signup(String userName, String password) async {
    UserData _newUser = await Auth.signup(userName, password);
    assignUserData(_newUser);
  }

  void assignUserData(UserData userData) {
    id = userData.id ?? "";
    username = userData.username ?? "";
    token = userData.token ?? "";
    hasWatchedIntro = userData.seenIntro ?? false;
    enableTimer ??= true;
    setUserData();

    //TODO - Work out a better system for this
    PersonaService().userId = id;
  }

  void logout() async {
    id = "";
    username = "";
    token = "";
    hasWatchedIntro = false;
    enableTimer = true;
    setUserData();
  }

  void getUserData() async {
    var userData = await UtilityFunctions.getStorage("user") ?? {};
    id = userData["id"] ?? "";
    username = userData["username"] ?? "";
    enableTimer = userData["enableTimer"] ?? true;
    token = userData["token"] ?? "";
    hasWatchedIntro = userData["watchedIntro"] ?? false;

    //TODO - Work out a better system for this
    PersonaService().userId = id;
    SupaBaseService().authToken = token;

    notifyListeners();
  }

  void setUserData() async {
    await UtilityFunctions.setStorage("user", json.encode({
      "id": id,
      "username": username,
      "token": token,
      "watchedIntro": hasWatchedIntro,
      "enableTimer": enableTimer,
    }));
    notifyListeners();
  }

  void toggleTimer() {
    enableTimer = !enableTimer;
  }

  void savePersona(Persona persona) async {
    await PersonaService().savePersona(persona, token);
  }
}