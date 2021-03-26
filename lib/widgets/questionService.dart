import 'dart:convert';
import 'dart:io';
import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionFormats/colourPickerQuestion.dart';
import 'package:Personas/widgets/questionFormats/multipleChoiceQuestion.dart';
import 'package:Personas/widgets/questionFormats/sliderQuestion.dart';
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

  Widget generateQuestionWidget({ValueChanged selectAnswer, dynamic startValue}) {
    selectAnswer ??= doNothingFunction;
    switch (type) {
      case QuestionType.MultipleChoice:
        return MultipleChoiceQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue,);
      case QuestionType.Slider:
        return SliderQuestion(question: this, selectAnswer: selectAnswer, startValue: startValue);
      case QuestionType.Polygon:
        // TODO: Handle this case.
        break;
      case QuestionType.Circle:
        // TODO: Handle this case.
        break;
      case QuestionType.ColourPicker:
        return ColourPickerQuestion(question: this, selectAnswer: selectAnswer);
      default:
       return MultipleChoiceQuestion(question: this);
    }
  }

  void doNothingFunction(dynamic nothing) {}
}

class Persona {
  String id;
  String name;
  Color color;
  List<QuestionResponse> answers;
}

class QuestionService {
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
      (question['options'] as List).forEach((option) {
        newOptions.add(QuestionOption(option["code"], option["text"], image: option["image"]));
      });

      Question newQuestion = Question(id, code, text, type, newOptions, min: min ?? 0, max: max ?? 0, labels: labels ?? []);
      
      newQuestions.add(newQuestion);
    });
    return newQuestions;
  }

  static void answerQuestion(Question question, String personaId, String answer, String userId) async {
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
    decodedData[userId] ??= {};
    decodedData[userId][personaId] ??= {};
    decodedData[userId][personaId]["answers"] ??= {};
    //this is here to allow for special pieces of data like the name and colour of a persona
    switch (question.id) {
      case "personaName": 
        decodedData[userId][personaId]["name"] = answer;
        break;
      case "personaColor": 
        decodedData[userId][personaId]["color"] = answer;
        break;
      case "":
        break;
      default:
        decodedData[userId][personaId]["answers"][question.id] = answer ?? "code";
        break;
    }
    String newUserAnswers = json.encode(decodedData);
    await file.writeAsString(newUserAnswers);
  }

  static Future<List<Persona>> getPersonas(String userId) async {
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
    print(decodedData);

    List<Question> allQuestions = await loadQuestions();
    List<Persona> allPersonas = new List<Persona>();

    decodedData[userId].forEach((id, persona) {
      Persona _persona = new Persona();
      _persona.id = id;
      _persona.name = persona["name"] ?? "";
      int colorInt = int.parse(persona["color"]);
      _persona.color = new Color(colorInt);
      List<QuestionResponse> _personaAnswers = new List<QuestionResponse>();
      
      persona["answers"]?.forEach((question, answer) async {
        Question questionObject = allQuestions.firstWhere((e) => (e.id == question));
        _personaAnswers.add(new QuestionResponse(questionObject, answer));
      });
      _persona.answers = _personaAnswers;
      allPersonas.add(_persona);
    });
    //print(allPersonas);
    return allPersonas;
  }
}