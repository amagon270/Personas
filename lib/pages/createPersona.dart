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
  bool canTapNext;
  Widget currentQuestionWidget;
  int currentQuestionindex;

  @override
  void initState() {
    super.initState();
    interviewService = new InterviewService();
    canTapNext = true;
    currentQuestionindex = 0;
  }
  
  void dispose() {
    super.dispose();
  }

  _selectAnswer(dynamic answer) {
    currentQuestionResponse.choice = answer;
    if (canTapNext == false) {
      setState(() {
        canTapNext = true;
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
                //initilizing on the first question
                if (currentQuestion == null) {
                  currentQuestion = interviewService.nextQuestion();
                  currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                  currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
                }
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: currentColor),
                  child: Column(
                    children: [
                      currentQuestionWidget,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Back button doesn't appear on the first question
                          currentQuestionindex > 0 ? RaisedButton(
                            child: Text("Back", style: Theme.of(context).textTheme.button),
                            onPressed: () {
                              setState(() {
                                currentQuestionindex--;
                                canTapNext = true;
                                currentQuestionResponse = interviewService.previousQuestion();
                                currentQuestion = currentQuestionResponse.question;
                                currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer, startValue: currentQuestionResponse.choice) ?? Text("Loading");
                              });
                            }
                          ) : null,
                          RaisedButton(
                            child: Text("Next", style: Theme.of(context).textTheme.button),
                            //next button can't be tapped unless the user has selected an answer
                            onPressed: canTapNext ? () {
                              currentQuestionindex++;
                              interviewService.answerQuestion(currentQuestion.id, snapshot.data.id, currentQuestionResponse.choice, context.read<User>().id);
                              setState(() {
                                currentQuestion = interviewService.nextQuestion();
                                //TODO - I think i might add a text only question to avoid things like this
                                if (currentQuestion != InterviewService.blankQuestion) {
                                  canTapNext = false;
                                }
                                currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                                currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
                              });
                              if (currentQuestion == InterviewService.endQuestion) {
                                Navigator.pop(context);
                              }
                            } : null,
                          ),
                        ].where((o) => o != null).toList()
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