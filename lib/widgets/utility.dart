import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/async.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as IO;
import 'dart:html';

class UtilityFunctions {
  static Future<String> generateId() async {
    return await nanoid(16);
  }

  static Widget getImageFromString(String path) {
    Widget image = Container();
    if (path != null && path != "") {
      image = Image(
        image: AssetImage(path),
        fit: BoxFit.contain,
      );
    }
    return image;
  }

  static Future<dynamic> getStorage(String variable) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      try {
        final file = IO.File('$path/$variable.json');
        final data = await file.readAsString();
        return json.decode(data);
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      try {
        final data = json.decode(window.localStorage[variable]);
        return data;
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  static Future<bool> setStorage(String variable, String data) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      try {
        final file = IO.File('$path/$variable.json');
        await file.writeAsString(data);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      try {
        window.localStorage[variable] = data;
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    }
  }
}