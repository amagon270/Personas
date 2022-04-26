import 'dart:async';

import 'package:personas/services/interviewService.dart';
import 'package:personas/services/personaService.dart';
import 'package:personas/services/questionService.dart';
import 'package:personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePersona extends StatefulWidget {
  CreatePersona();

  _CreatePersona createState() => _CreatePersona();
}

class _CreatePersona extends State<CreatePersona> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  late InterviewService interviewService;
  late Question currentQuestion;
  late QuestionResponse currentQuestionResponse;
  Color currentColor = Colors.white;
  late bool canTapNext;
  late Widget currentQuestionWidget;
  late Session currentSession;
  late Timer questionSkipTimer;
  late String userId;

  late bool nextText;

  @override
  void initState() {
    super.initState();
    interviewService = new InterviewService();
    canTapNext = true;
    userId = context.read<User>().id;
    nextText = false;

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
    questionSkipTimer.cancel();
  }

  _selectAnswer(dynamic answer) {
    print(answer);
    currentQuestionResponse.choice = answer;
    if (currentQuestionResponse.choice == "true") {
      currentQuestionResponse.choice = true;
    } 
    if ([QuestionType.MultipleChoice, QuestionType.Polygon].contains(currentQuestionResponse.question.type)) {
      _submit();
    }
    if (currentQuestionResponse.question.type == QuestionType.ColourPicker) {
      if (answer == "done") {
        currentQuestionResponse.choice = currentColor.value;
        _submit();
      } else {
        setState(() {
          currentColor = new Color(answer);
        });
      }
    }
    if ([QuestionType.Theme, QuestionType.Slider].contains(currentQuestionResponse.question.type)) {
      setState(() {
        nextText = true;
      });
    }
  }

  void startTimer(Question question) {
    if (context.read<User>().enableTimer) {
      questionSkipTimer.cancel();
      if (question.timer > 0) {
        Duration length = Duration(seconds: question.timer);
        questionSkipTimer = Timer(length, _nextQuestion);
      }
    }
  }

  void _submit() {
    interviewService.answerQuestion(currentQuestionResponse, userId);
    if (currentQuestion == InterviewService.endQuestion) {
      PersonaService().save(currentSession);
      Navigator.pop(context);
    } else {
      _nextQuestion();
    }
  }

  void _nextQuestion() {
    setState(() {
      nextText = false;
      _controller.reset();
      _controller.forward();
      currentQuestion = interviewService.nextQuestion();
      //canTapNext = false;
      currentQuestionResponse = new QuestionResponse(currentQuestion, null);
      currentQuestionWidget = currentQuestion.generateQuestionWidget(
        selectAnswer: _selectAnswer,
        backgroundColour: currentColor);
    });
    if (!PersonaService.specialQuestionIds.contains(currentQuestion.id)) {
      startTimer(currentQuestion);
    }
  }

  Widget backButton() {
    return ElevatedButton(
      child: Text("Back",
        style: Theme.of(context).textTheme.button),
      onPressed: () {
        setState(() {
          nextText = false;
          _controller.reset();
          _controller.forward();
          canTapNext = true;
          currentQuestionResponse = interviewService.previousQuestion();
          currentQuestion = currentQuestionResponse.question;
          currentQuestionWidget = currentQuestion.generateQuestionWidget(
            selectAnswer: _selectAnswer,
            startValue: currentQuestionResponse.choice,
            backgroundColour: currentColor,
            );
          startTimer(currentQuestion);
        });
      });
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
                currentSession = snapshot.data as Session;
                //initilizing on the first question
                if (currentQuestion == null) {
                  currentQuestion = interviewService.nextQuestion();
                  currentQuestionResponse = new QuestionResponse(currentQuestion, null);
                  currentQuestionWidget = currentQuestion.generateQuestionWidget(
                    selectAnswer: _selectAnswer,
                    backgroundColour: currentColor);
                  currentColor = interviewService.getCurrentColor();
                }
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: currentColor),
                  child: Column(children: [
                    currentQuestionWidget,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //Back button doesn't appear on the first question
                        currentQuestion.code != "intro" ? backButton() : Container(),
                        ElevatedButton(
                          child: Text(nextText ? "Submit" : "Move on",
                            style: Theme.of(context).textTheme.button),
                          //next button can't be tapped unless the user has selected an answer
                          onPressed: canTapNext ? () {
                            _submit();
                          } : null,
                        ),
                      ] //null protection
                    ),
                  ])
                );
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
        brightness: currentColor.computeLuminance() > 0.25
          ? Brightness.light
          : Brightness.dark,
        primaryColor: Colors.blue,
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
