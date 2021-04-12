import 'package:flutter/material.dart';
import 'package:nanoid/async/nanoid.dart';

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

}