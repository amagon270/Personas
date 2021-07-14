import 'dart:async';

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

class _CreatePersona extends State<CreatePersona>
    with SingleTickerProviderStateMixin {
    
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  
  InterviewService interviewService;
  Question currentQuestion;
  QuestionResponse currentQuestionResponse;
  Color currentColor = Colors.white;
  bool canTapNext;
  Widget currentQuestionWidget;
  Session currentSession;
  Timer questionSkipTimer;

  @override
  void initState() {
    super.initState();
    interviewService = new InterviewService();
    canTapNext = true;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  void dispose() {
    super.dispose();
    _controller.dispose();
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

  void startTimer(Question question) {
    questionSkipTimer?.cancel();
    if (question.timer > 0) {
      Duration length = Duration(seconds: question.timer);
      questionSkipTimer = Timer(length, _nextQuestion);
    }
  }

  void _nextQuestion() {
    interviewService.answerQuestion(currentQuestion.id, currentSession.id, currentQuestionResponse.choice, context.read<User>().id);
    setState(() {
      _controller.reset();
      _controller.forward();
      currentQuestion = interviewService.nextQuestion();
      canTapNext = false;
      currentQuestionResponse = new QuestionResponse(currentQuestion, null);
      currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
    });
    if (currentQuestion == InterviewService.endQuestion) {
      Navigator.pop(context);
    }
    if (!PersonaService.specialQuestionIds.contains(currentQuestion.id)) {
      startTimer(currentQuestion);
    }
  }

  Widget questionUI() {
    return Container(
      decoration: BoxDecoration(color: currentColor),
      child: SlideTransition(
        position: _offsetAnimation,
        child: SafeArea(
          child: FutureBuilder(
            future: interviewService.startSession(),
            initialData: null,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Text("Loading");
              } else {
                currentSession = snapshot.data;
                //initilizing on the first question
                if (currentQuestion == null) {
                  currentQuestion = interviewService.nextQuestion();
                  currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                  currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer) ?? Text("Loading");
                  currentColor = interviewService.getCurrentColor();
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
                          currentQuestion.id != "intro" ? RaisedButton(
                            child: Text("Back", style: Theme.of(context).textTheme.button),
                            onPressed: () {
                              setState(() {
                                _controller.reset();
                                _controller.forward();
                                canTapNext = true;
                                currentQuestionResponse = interviewService.previousQuestion();
                                currentQuestion = currentQuestionResponse.question;
                                currentQuestionWidget = currentQuestion?.generateQuestionWidget(selectAnswer: _selectAnswer, startValue: currentQuestionResponse.choice) ?? Text("Loading");
                                startTimer(currentQuestion);
                              });
                            }
                          ) : null,
                          RaisedButton(
                            child: Text("Next", style: Theme.of(context).textTheme.button),
                            //next button can't be tapped unless the user has selected an answer
                            onPressed: canTapNext ? () {_nextQuestion();} : null,
                          ),
                        ].where((o) => o != null).toList() //null protection
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
        appBar: AppBar(
          title: Text("Create New Persona"),
          actions: [
            //_resetButton()
          ],
        ),
        body: questionUI()
      )
    );
  }

  //Because personas should be created in one sitting this is no longer needed
  // Widget _resetButton() {
  //   return FlatButton(
  //     child: Text("Reset"),
  //     onPressed: () async {
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             content: Text("Are you sure you want to discard progress on this persona and reset?"),
  //             actions: [
  //               FlatButton(
  //                 child: Text("Reset"),
  //                 onPressed: () async {
  //                   await interviewService.clearUnfinishedSession();
  //                   Navigator.pushReplacementNamed(context, "/createPersona");
  //                 },
  //               ),
  //               FlatButton(
  //                 child: Text("Cancel"),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 }, 
  //               )
  //             ],
  //           );
  //         },
  //       );
  //     }, 
  //   );
  // }
}