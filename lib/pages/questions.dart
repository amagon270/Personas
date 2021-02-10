import 'package:Personas/pages/results.dart';
import 'package:Personas/widgets/individualQuestion.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionData currentQuestion = context.watch<User>().currentQuestion;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            IndividualQuestion(question: currentQuestion),
            RaisedButton(
              child: Text("Submit"),
              onPressed: () {
                QuestionService.answerQuestion(currentQuestion, context.read<User>().id);
                context.read<User>().askQuestion();
              },
            ),
            RaisedButton(
              child: Text("View Answers"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage()));
              },
            ), 
            RaisedButton(
              child: Text("Reset answers"),
              onPressed: () {
                context.read<User>().resetAnswers();
              },
            )
          ]
        )
      )
    );
  }
}
