import 'dart:convert';
import 'package:Personas/widgets/questionFormats/colourPickerQuestion.dart';
import 'package:Personas/widgets/questionFormats/multipleChoiceQuestion.dart';
import 'package:Personas/widgets/questionFormats/multipleSelectQuestion.dart';
import 'package:Personas/widgets/questionFormats/polygonQuestion.dart';
import 'package:Personas/widgets/questionFormats/sliderQuestion.dart';
import 'package:Personas/widgets/questionFormats/textInputQuestion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum QuestionType {
  MultipleChoice,
  Slider,
  Polygon,
  Circle,
  ColourPicker,
  MultipleSelect,
  TextInput
}

//allows calling string.toEnum({Enum}.values) to turn a string into an Enum e.g. "Slider".toEnum(QuestionType.values)
extension EnumParser on String {
  T toEnum<T>(List<T> values) {
    return values.firstWhere(
      (e) => e.toString().toLowerCase().split(".").last == '$this'.toLowerCase(), orElse: () => null,);
  }
}

class QuestionOption {
  QuestionOption(this.code, this.text, {this.image, this.order});

  String code;
  String text;
  String image;
  int order;

  Map getAsMap() {
    Map newMap = Map();
    newMap["code"] = code;
    newMap["text"] = text;
    newMap["image"] = image ?? "";
    newMap["order"] = order;
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

  Widget generateQuestionWidget({ValueChanged selectAnswer, dynamic startValue, bool editable = true}) {
    selectAnswer ??= doNothingFunction;
    switch (type) {
      case QuestionType.MultipleChoice:
        return MultipleChoiceQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue, editable: editable,);
      case QuestionType.Slider:
        return SliderQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue, editable: editable);
      case QuestionType.Polygon:
        return PolygonQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue, editable: editable);
        break;
      case QuestionType.Circle:
        // TODO: Handle this case.
        break;
      case QuestionType.ColourPicker:
        return ColourPickerQuestion(question: this, selectAnswer: selectAnswer);
      case QuestionType.MultipleSelect:
        return MultipleSelectQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue, editable: editable);
      case QuestionType.TextInput:
        return TextInputQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue,);
      default:
       return MultipleChoiceQuestion(question: this);
    }
  }

  //mostly just here as a null safe funtion for generateQuestionWidget.
  void doNothingFunction(dynamic nothing) {}
}

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;

  QuestionService._internal() {
    assignQuestions();
  }

  List<Question> _allQuestions;

  void assignQuestions() async {
    _allQuestions = await loadQuestions();
  }

  List<Question> get allQuestions => _allQuestions;

  static Future<List<Question>> loadQuestions() async {
    final data = await rootBundle.loadString("assets/questions/personaQuestions.json");
    List<dynamic> decodedData = json.decode(data);
    List<Question> newQuestions = new List<Question>();
    decodedData.forEach((question) {
      var id = question["id"] ?? "";
      var code = question["code"];
      var type = question["type"].toString().toEnum(QuestionType.values);
      var text = question["text"];
      var min = question["min"];
      var max = question["max"];
      var labels = (question["labels"] as List<dynamic>).map((e) => e as String).toList();
      List<QuestionOption> newOptions = new List<QuestionOption>();
      (question['options'] as List)?.forEach((option) {
        newOptions.add(QuestionOption(option["code"], option["text"], image: option["image"], order: option["order"]));
      });

      Question newQuestion = Question(id, code, text, type, newOptions ?? [], min: min ?? 0, max: max ?? 0, labels: labels ?? []);
      
      newQuestions.add(newQuestion);
    });
    return newQuestions;
  }
}