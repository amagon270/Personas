import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class QuestionData {
  String id;
  String question;
  String answer;
  List<String> options;

  QuestionData(this.id, this.question, this.options);
}

class QuestionService {

  static Future<List<QuestionData>> loadQuestions() async {
    final data = await rootBundle.loadString("assets/questions/questions.json");
    Map decodedData = json.decode(data);
    List<QuestionData> newQuestions = new List<QuestionData>();
    decodedData.forEach((key, value) {
      List<String> newOptions = (value['options'] as List)?.map((item) => item as String)?.toList();
      newQuestions.add(QuestionData(key, value["question"], newOptions));
    });
    return newQuestions;
  }

  static QuestionData askQuestion(List<QuestionData> possableQuestions) {
    List<QuestionData> unansweredQuestions = possableQuestions.where((element) => element.answer == null).toList();
    if (unansweredQuestions.length > 0) {
      return unansweredQuestions[Random().nextInt(unansweredQuestions.length)];
    } else {
      return new QuestionData("000", "Sorry we are out of questions", []);
    }
  }

  static void answerQuestion(QuestionData question, String userId) async {
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
    decodedData[userId][question.id] = question.answer ?? "";
    String newUserAnswers = json.encode(decodedData);
    await file.writeAsString(newUserAnswers);
  }

  static Future<Map<String, dynamic>> getAnswers(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/userAnswers.json');
    String userAnswers = "{}";
    try{
      userAnswers = await file.readAsString();
      Map decodedData = json.decode(userAnswers);
      return decodedData[userId];
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  static void resetAnswers(String userId) async {
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
    decodedData[userId] = {};
    String newUserAnswers = json.encode(decodedData);
    await file.writeAsString(newUserAnswers);
  }
}