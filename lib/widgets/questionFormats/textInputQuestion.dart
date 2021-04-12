import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInputQuestion extends StatefulWidget {
  TextInputQuestion({Key key, this.question, this.selectAnswer, this.startValue}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;

  @override
  _TextInputQuestion createState() => _TextInputQuestion();
}

class _TextInputQuestion extends State<TextInputQuestion> {
  
  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.question.text, style: Theme.of(context).textTheme.headline6),
          TextField(
            controller: _controller,
            onChanged: (String value) async {
              setState(() {
                widget.selectAnswer(value);
              });
            },
          )
        ],
      )
    );
  }
}