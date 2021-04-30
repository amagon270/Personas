import 'dart:convert';
import 'package:Personas/widgets/questionFormats/colourPickerQuestion.dart';
import 'package:Personas/widgets/questionFormats/middleSliderQuestion.dart';
import 'package:Personas/widgets/questionFormats/multiPolygonQuestion.dart';
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
  MiddleSlider,
  Polygon,
  MultiPolygon,
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
  QuestionOption(this.code, this.value, this.text, {this.image, this.order});

  String code;
  dynamic value;
  String text;
  String image;
  int order;

  Map getAsMap() {
    Map newMap = Map();
    newMap["code"] = code;
    newMap["value"] = value;
    newMap["text"] = text;
    newMap["image"] = image ?? "";
    newMap["order"] = order;
    return newMap;
  }
}

class QuestionInputData {
  QuestionInputData(this.question, this.selectAnswer, {this.startValue, this.editable = true});

  Question question;
  ValueChanged selectAnswer;
  dynamic startValue;
  bool editable;
}

class Question {
  Question(this.id, this.code, this.text, this.type, this.factSubject, this.options, {this.min, this.max, this.labels});

  String id;
  String code;
  String text;
  QuestionType type;
  String factSubject;
  List<QuestionOption> options;
  int min;
  int max;
  List<String> labels;

  Widget generateQuestionWidget({ValueChanged selectAnswer, dynamic startValue, bool editable = true}) {

    selectAnswer ??= (value) {};
    QuestionInputData inputData = QuestionInputData(this, selectAnswer, startValue: startValue, editable: editable);

    switch (type) {
      case QuestionType.MultipleChoice:
        return MultipleChoiceQuestion(data: inputData, key: UniqueKey());
      case QuestionType.MultipleSelect:
        return MultipleSelectQuestion(data: inputData, key: UniqueKey());
      case QuestionType.Slider:
        return SliderQuestion(data: inputData, key: UniqueKey(),);
      case QuestionType.MiddleSlider:
        return MiddleSliderQuestion(data: inputData, key: UniqueKey(),);
      case QuestionType.Polygon:
        return PolygonQuestion(data: inputData, key: UniqueKey());
      case QuestionType.MultiPolygon:
        return MultiPolygonQuestion(data: inputData, key: UniqueKey());
      case QuestionType.Circle:
        // TODO: Handle this case.
        break;
      case QuestionType.ColourPicker:
        return ColourPickerQuestion(data: inputData, key: UniqueKey());
      case QuestionType.TextInput:
        return TextInputQuestion(data: inputData, key: UniqueKey());
      default:
       return MultipleChoiceQuestion(data: inputData, key: UniqueKey());
    }
  }
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

  Question getQuestionById(String id) {
    return _allQuestions?.firstWhere((e) => (e.id == id), orElse: () {return null;});
  }

  static Future<List<Question>> loadQuestions() async {
    final data = await rootBundle.loadString("assets/questions/personaQuestions.json");
    List<dynamic> decodedData = json.decode(data);
    List<Question> newQuestions = new List<Question>();
    decodedData.forEach((question) {
      var id = question["id"] ?? "";
      var code = question["code"];
      var type = question["type"].toString().toEnum(QuestionType.values);
      var text = question["text"];
      var subject = question["factSubject"];
      var min = question["min"];
      var max = question["max"];
      var labels = (question["labels"] as List<dynamic>).map((e) => e as String).toList();
      List<QuestionOption> newOptions = new List<QuestionOption>();
      (question['options'] as List)?.forEach((option) {
        newOptions.add(QuestionOption(option["code"], option["value"], option["text"], image: option["image"], order: option["order"]));
      });

      Question newQuestion = Question(id, code, text, type, subject, newOptions ?? [], min: min ?? 0, max: max ?? 0, labels: labels ?? []);
      
      newQuestions.add(newQuestion);
    });
    return newQuestions;
  }
}