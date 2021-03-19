import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum QuestionType {
  MultipleChoice,
  Slider,
  Polygon,
  Circle,
  ColourPicker
}

//allows calling string.toEnum({Enum}.values) to turn a string into an Enum e.g. "Slider".toEnum(QuestionType.values)
extension EnumParser on String {
  T toEnum<T>(List<T> values) {
    return values.firstWhere(
      (e) => e.toString().toLowerCase().split(".").last == '$this'.toLowerCase(), orElse: () => null,);
  }
}

class QuestionOption {
  QuestionOption(this.code, this.text, {this.image});

  String code;
  String text;
  String image;

  Map getAsMap() {
    Map newMap = Map();
    newMap["code"] = code;
    newMap["text"] = text;
    newMap["image"] = image ?? "";
    return newMap;
  }
}

class Question {
  Question(this.id, this.code, this.text, this.type, this.options, {this.min, this.max, this.labels});

  String id;
  String code;
  String text;
  QuestionType type;
  List<QuestionOption> options;
  int min;
  int max;
  List<String> labels;

  Widget generateQuestionWidget() {
    switch (type) {
      case QuestionType.MultipleChoice:
        // TODO: Handle this case.
        break;
      case QuestionType.Slider:
        // TODO: Handle this case.
        break;
      case QuestionType.Polygon:
        // TODO: Handle this case.
        break;
      case QuestionType.Circle:
        // TODO: Handle this case.
        break;
      case QuestionType.ColourPicker:
        // TODO: Handle this case.
        break;
    }
  }
}

class QuestionService {
  static Future<List<Question>> loadQuestions() async {
    final data = await rootBundle.loadString("assets/questions/personaQuestions.json");
    List<dynamic> decodedData = json.decode(data);
    List<Question> newQuestions = new List<Question>();
    decodedData.forEach((question) {
      var id = question["id"];
      var code = question["code"];
      var type = question["type"].toString().toEnum(QuestionType.values);
      var text = question["text"];
      var min = question["min"];
      var max = question["max"];
      var labels = (question["labels"] as List<dynamic>).map((e) => e as String).toList();
      List<QuestionOption> newOptions = new List<QuestionOption>();
      (question['options'] as List).forEach((option) {
        newOptions.add(QuestionOption(option["code"], option["text"], image: option["image"]));
      });

      Question newQuestion = Question(id, code, text, type, newOptions, min: min ?? 0, max: max ?? 0, labels: labels ?? []);
      
      newQuestions.add(newQuestion);
    });
    return newQuestions;
  }

  static void answerQuestion(Question question, QuestionOption answer, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/userAnswers.json');
    String userAnswers = "{}";
    try{
      userAnswers = await file.readAsString();
    } catch (e) {
      print("Couldn't find file, creating new file");
      userAnswers = '{"$userId" : {}}';
    }
    Map decodedData = json.decode(userAnswers);
    decodedData[userId][question.id] = answer.getAsMap() ?? {"code" : "", "text" : "", "image": ""};
    String newUserAnswers = json.encode(decodedData);
    await file.writeAsString(newUserAnswers);
  }
}