import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePersona extends StatefulWidget {
  CreatePersona();

  _CreatePersona createState() => _CreatePersona();
}

class _CreatePersona extends State<CreatePersona> {
  InterviewService interviewService;
  Question currentQuestion;
  QuestionResponse currentQuestionResponse;
  Color currentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    interviewService = new InterviewService();
  }

  _selectAnswer(dynamic answer) {
    currentQuestionResponse.choice = answer.toString();
    if (currentQuestionResponse.question.id == "personaColor") {
      setState(() {
        currentColor = new Color(answer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Persona"),),
      body: SafeArea(
        child: FutureBuilder(
          future: interviewService.startSession(),
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Text("Loading");
            } else {
              print(snapshot.data.id);
              if (currentQuestion == null) {
                currentQuestion = interviewService.nextQuestion();
                currentQuestionResponse = new QuestionResponse(currentQuestion, null);
              }
              return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: currentColor),
                child: Column(
                  children: [
                    currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading"),
                    RaisedButton(
                      child: Text("Next"),
                      onPressed: () {
                        interviewService.answerQuestion(currentQuestion.id, snapshot.data.id, currentQuestionResponse.choice, context.read<User>().id);
                        setState(() {
                          currentQuestion = interviewService.nextQuestion();
                          if (currentQuestion == null) {
                            Navigator.pop(context);
                          }
                          currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                        });
                      },
                    ),
                  ]
                )
              );
            }
          },
        )
      )
    );
  }
}