import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/personaService.dart';
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
  bool canHitNext;
  Widget currentQuestionWidget;

  @override
  void initState() {
    super.initState();
    interviewService = new InterviewService();
    canHitNext = true;
  }
  
  void dispose() {
    super.dispose();
  }

  _selectAnswer(dynamic answer) {
    currentQuestionResponse.choice = answer.toString();
    if (canHitNext == false) {
      setState(() {
        canHitNext = true;
      });
    }
    if (currentQuestionResponse.question.id == "personaColor") {
      setState(() {
        currentColor = new Color(answer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Color complementaryColor = Color.fromRGBO(255-currentColor.red, 255-currentColor.green, 255-currentColor.blue, 1);
    return Theme(
      data: ThemeData(
        brightness: currentColor.computeLuminance() > 0.25 ? Brightness.light : Brightness.dark,
        primaryColor: Colors.blue,
        buttonColor: Colors.grey[400],
        textTheme: TextTheme(button: TextStyle(color: Colors.black))
      ),
      child: Scaffold(
        appBar: AppBar(title: Text("Create New Persona"),),
        body: SafeArea(
          child: FutureBuilder(
            future: interviewService.startSession(),
            initialData: null,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              } else {
                if (currentQuestion == null) {
                  currentQuestion = interviewService.nextQuestion(context.read<User>().id);
                  currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                  currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
                }
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: currentColor),
                  child: Column(
                    children: [
                      currentQuestionWidget,
                      RaisedButton(
                        child: Text("Next", style: Theme.of(context).textTheme.button),
                        onPressed: canHitNext ? () {
                          interviewService.answerQuestion(currentQuestion.id, snapshot.data.id, currentQuestionResponse.choice, context.read<User>().id);
                          setState(() {
                            currentQuestion = interviewService.nextQuestion(context.read<User>().id);
                            canHitNext = false;
                            currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                            currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
                          });
                          if (currentQuestion == InterviewService.endQuestion) {
                            Navigator.pop(context);
                          }
                        } : null,
                      ),
                    ]
                  )
                )
                ;
              }
            },
          )
        )
      )
    );
  }
}