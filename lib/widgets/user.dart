import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class User with ChangeNotifier, DiagnosticableTreeMixin {
  String id;
  String email;
  List<QuestionData> questions;
  QuestionData currentQuestion;

  User() {
    loadQuestions();
  }

  void login(String email, String password) {
    Map newUser = Auth.tempLoginCheck(email, password);
    id = newUser["id"];
    loadAnswers();
    notifyListeners();
  }

  void loadQuestions() async {
    addQuestions(await QuestionService.loadQuestions());
    currentQuestion = QuestionService.askQuestion(questions);
    notifyListeners();
  }

  void loadAnswers() async {
    Map answers = await QuestionService.getAnswers(id);
    answers.forEach((key, value) {
      questions.where((element) => element.id == key).first.answer = value;
    });
  }

  void askQuestion() {
    QuestionData newQuestion = QuestionService.askQuestion(questions);
    currentQuestion = newQuestion;
    notifyListeners();
  }

  void addQuestions(List<QuestionData> newQuestions) {
    if (questions == null) {
      questions = newQuestions;
    } else {
      questions.addAll(newQuestions);
    }
  }

  Future<List<String>> showAnswers() async {
    List<String> answersList = new List<String>();
    Map answers = await QuestionService.getAnswers(id);
    answers.forEach((key, value) {
      QuestionData question = questions.firstWhere((element) => element.id == key, orElse: () {return QuestionData("000", "Sorry we are out of questions", []);});
      answersList.add(
        "Question: " + question.question + 
        "\nAnswer: " + value
      );
    });
    return answersList;
  }

  void resetAnswers() {
    QuestionService.resetAnswers(id);
    loadQuestions();
  }
}