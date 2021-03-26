import 'package:nanoid/async/nanoid.dart';

class UtilityFunctions {
  static Future<String> generateId() async {
    return await nanoid(16);
  }

}