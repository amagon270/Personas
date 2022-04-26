import 'dart:convert';
import 'package:personas/widgets/questionFormats/colourPickerQuestion.dart';
import 'package:personas/widgets/questionFormats/middleSliderQuestion.dart';
import 'package:personas/widgets/questionFormats/multiPolygonQuestion.dart';
import 'package:personas/widgets/questionFormats/multipleChoiceQuestion.dart';
import 'package:personas/widgets/questionFormats/multipleSelectQuestion.dart';
import 'package:personas/widgets/questionFormats/polygonQuestion.dart';
import 'package:personas/widgets/questionFormats/sliderQuestion.dart';
import 'package:personas/widgets/questionFormats/textInputQuestion.dart';
import 'package:personas/widgets/questionFormats/textOnlyQuestion.dart';
import 'package:personas/widgets/questionFormats/themeQuestion.dart';
import 'package:personas/services/supaBaseService.dart';
import 'package:flutter/material.dart';

enum QuestionType {
  MultipleChoice,
  Slider,
  TextSlider,
  Polygon,
  MultiPolygon,
  Circle,
  ColourPicker,
  MultipleSelect,
  TextInput,
  TextOnly,
  Theme
}

//allows calling string.toEnum({Enum}.values) to turn a string into an Enum e.g. "Slider".toEnum(QuestionType.values)
extension EnumParser on String {
  T toEnum<T>(List<T> values) {
    return values.firstWhere(
      (e) => e.toString().toLowerCase().split(".").last == '$this'.toLowerCase(),
    );
  }
}

class QuestionOption {
  QuestionOption(this.code, this.value, this.text,
    {this.image, this.order, this.fact});

  String code;
  dynamic value;
  String text;
  String? image;
  int? order;
  String? fact;

  Map getAsMap() {
    Map newMap = Map();
    newMap["code"] = code;
    newMap["value"] = value;
    newMap["text"] = text;
    newMap["image"] = image ?? "";
    newMap["order"] = order;
    newMap["fact"] = fact;
    return newMap;
  }

  @override
  String toString() {
    return "QuestionOption { code: $code, value: $value, text: $text, image: $image, order: $order, fact: $fact }";
  }

  QuestionOption.fromJson(Map<String, dynamic> json) : 
    code = json['code'],
    value = json['value'],
    text = json['text'],
    image = json['image'],
    order = json['order'],
    fact = json['fact'];

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "value": value,
      "text": text,
      "image": image,
      "order": order,
      "fact": fact,
    };
  }
}

class QuestionInputData {
  QuestionInputData(this.question, this.selectAnswer,
    {this.startValue, this.editable = true, this.backgroundColour = Colors.white});

  Question question;
  ValueChanged selectAnswer;
  dynamic startValue;
  bool editable;
  Color backgroundColour;
}

class Question {
  Question(this.id, this.code, this.text, this.type, this.factSubject, this.options,
    {this.min, this.max, this.labels, this.timer = 10, this.enabled = true});

  String id;
  String code;
  String text;
  QuestionType type;
  String factSubject;
  List<QuestionOption> options;
  int? min;
  int? max;
  List<String>? labels;
  int timer;
  bool enabled = true;

  Widget generateQuestionWidget({ValueChanged? selectAnswer, dynamic startValue, bool editable = true, required Color backgroundColour}) {

    selectAnswer ??= (value) {};
    QuestionInputData inputData = QuestionInputData(
      this, selectAnswer, startValue: startValue, editable: editable, backgroundColour: backgroundColour
    );

    switch (type) {
      case QuestionType.MultipleChoice:
        return MultipleChoiceQuestion(data: inputData, key: UniqueKey());
      case QuestionType.MultipleSelect:
        return MultipleSelectQuestion(data: inputData, key: UniqueKey());
      case QuestionType.Slider:
        return SliderQuestion(data: inputData, key: UniqueKey(),);
      case QuestionType.TextSlider:
        return MiddleSliderQuestion(data: inputData, key: UniqueKey(),);
      case QuestionType.Polygon:
        return PolygonQuestion(data: inputData, key: UniqueKey());
      case QuestionType.MultiPolygon:
        return MultiPolygonQuestion(data: inputData, key: UniqueKey());
      case QuestionType.Circle:
        break;
      case QuestionType.ColourPicker:
        return ColourPickerQuestion(data: inputData, key: UniqueKey());
      case QuestionType.TextInput:
        return TextInputQuestion(data: inputData, key: UniqueKey());
      case QuestionType.TextOnly:
        return TextOnlyQuestion(data: inputData, key: UniqueKey());
      case QuestionType.Theme:
        return ThemeQuestion(data: inputData, key: UniqueKey());
      default:
        return MultipleChoiceQuestion(data: inputData, key: UniqueKey());
    }
    return MultipleChoiceQuestion(data: inputData, key: UniqueKey());
  }

  Question.fromJson(Map<String, dynamic> json) : 
    id = json['id'],
    code = json['code'],
    text = json['text'],
    type = QuestionType.values.firstWhere((e) => e.toString() == json['type']),
    factSubject = json['factSubject'],
    options = (json['options'] as List).map((e) => QuestionOption.fromJson(e)).toList(),
    min = json['min'],
    max = json['max'],
    labels = json['labels'].map<String>((json) => json.toString()).toList(),
    timer = json['timer'],
    enabled = json['enabled'];

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? _options = this.options != null ? this.options.map((i) => i.toJson()).toList() : null;
    return {
      "id": id,
      "code": code,
      "text": text,
      "type": type.toString(),
      "factSubject": factSubject,
      "options": _options,
      "min": min,
      "max": max,
      "labels": labels,
      "timer": timer,
      "enabled": enabled,
    };
  }
}

class QuestionService {
  static final QuestionService _instance = QuestionService._internal();
  factory QuestionService() => _instance;

  QuestionService._internal() {
    //assignQuestions();
  }

  late List<Question> _allQuestions;

  void assignQuestions() async {
    _allQuestions = await loadQuestions();
  }

  List<Question> get allQuestions => _allQuestions;

  Question? getQuestionById(String id) {
    return _allQuestions.firstWhere((e) => (e.id == id));
  }

  void switchQuestionEnabled(String id) {
    Question? question = getQuestionById(id);
    if (question != null) {
      question.enabled = !question.enabled;
    }
  }

  static Future<List<Question>> loadQuestions() async {
    //final data = await rootBundle.loadString("assets/export.json");
    final data = SupaBaseService().qMatrix;
    List<dynamic> decodedData = json.decode(data)["questions"] ?? [];
    List<Question> newQuestions = [];
    decodedData.forEach((question) {
      var id = question["id"]?.toString() ?? "";
      var code = question["code"];
      var type = question["type"].toString().toEnum(QuestionType.values);
      var text = question["text"];
      var subject = question["factSubject"];
      var min = question["min"];
      var max = question["max"];
      var timer = question["timer"] ?? 10;
      var labels = (question["labels"] as List<dynamic>)
        .map((e) => e as String).toList();
      List<QuestionOption> newOptions = [];
      (question['options'] as List).forEach((option) {
        if (option["code"] != "") {
          newOptions.add(QuestionOption(
            option["code"].toString(), option["value"], option["text"],
            image: option["image"], order: option["order"],
            fact: option["factId"].toString())
          );
        }
      });

      Question newQuestion = Question(
        id, code, text, type, subject, newOptions,
        min: min ?? 0, max: max ?? 0, labels: labels, timer: timer
      );

      newQuestions.add(newQuestion);
    });  

    return newQuestions;
  }
}
