import 'dart:convert';
import 'dart:io';

import 'package:Personas/widgets/personaService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_hash/pbkdf2.dart';
import 'package:password_hash/salt.dart';
import 'package:path_provider/path_provider.dart';

import 'auth.dart';

class User with ChangeNotifier, DiagnosticableTreeMixin {
  String id;
  String firstName;
  String lastName;
  String email;
  DateTime dateCreated;

  bool hasWatchedIntro;

  User() {
    checkExistingUser();
  }

  void checkExistingUser() async {
    Map userData = await getUserData();
    print("get user data $userData");
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

    //TODO - Work out a better system for this
    PersonaService().userId = id;
  }

  Future<Map> getUserData() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    try {
      final file = File('$path/user.json');
      final data = await file.readAsString();
      return json.decode(data);
    } catch (e) {
      print(e.toString());
      print("test print on return null in getUserData");
      return null;
    }
  }

  void setUserData(String userData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    try {
      final file = File('$path/user.json');
      file.writeAsString(userData);
    } catch (e) {
      print(e);
    }
  }
}