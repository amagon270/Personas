import 'dart:convert';

import 'package:personas/services/personaService.dart';
import 'package:personas/widgets/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:conduit_password_hash/conduit_password_hash.dart';

import 'auth.dart';

class User with ChangeNotifier, DiagnosticableTreeMixin {
  String id;
  String firstName;
  String lastName;
  String email;
  DateTime dateCreated;
  bool enableTimer;

  bool hasWatchedIntro;

  User() {
    checkExistingUser();
  }

  void checkExistingUser() async {
    Map userData = await getUserData();
    if (userData != null) {
      assignUserData(userData);
    } else {
      Map data = {"id": "", "email": "", "firstName": "", "lastName": "", "password": "", "salt": "", "watchedIntro" : false};
      assignUserData(data);
      setUserData(json.encode(data));
    }

    notifyListeners();
  }

  void watchIntro() async {
    hasWatchedIntro = true;
    Map data = await getUserData();
    data["watchedIntro"] = true;
    setUserData(json.encode(data));
    notifyListeners();
  }

  void login(String email, String password) {
    Map newUser = Auth.tempLoginCheck(email, password);
    id = newUser["id"];

    notifyListeners();
  }

  void signup(String email, String password, String firstName, String lastName) async {
    var id = await UtilityFunctions.generateId();
    var salt = Salt.generateAsBase64String(16);
    var hash = PBKDF2().generateKey(password, salt, 1000, 32);
    int time = DateTime.now().millisecondsSinceEpoch;
    Map userData = {"id": id, "email": email, "firstName": firstName, "lastName": lastName, "password": hash, "salt": salt, "created": time, "watchedIntro" : hasWatchedIntro};
    setUserData(json.encode(userData));
    assignUserData(userData);
    notifyListeners();
  }

  void assignUserData(Map userData) {
    id = userData["id"] ?? "";
    firstName = userData["firstName"] ?? "";
    lastName = userData["lastName"] ?? "";
    email = userData["email"] ?? "";
    dateCreated = userData["created"] != null ? DateTime.fromMillisecondsSinceEpoch(userData["created"]) : DateTime.now();
    hasWatchedIntro = userData["watchedIntro"] ?? false;
    enableTimer = true;

    //TODO - Work out a better system for this
    PersonaService().userId = id;
  }

  Future<Map> getUserData() async {
    return await UtilityFunctions.getStorage("user");
    
  }

  void setUserData(String userData) async {
    await UtilityFunctions.setStorage("user", userData);
  }

  void toggleTimer() {
    enableTimer = !enableTimer;
  }
}