import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  MultipleChoiceQuestion({Key key, this.question, this.selectAnswer, this.startValue}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;

  @override
  _MultipleChoiceQuestion createState() => _MultipleChoiceQuestion();
}

class _MultipleChoiceQuestion extends State<MultipleChoiceQuestion> {
  
  QuestionOption currentlySelected;

  @override
  Widget build(BuildContext context) {
    if (widget.startValue != null) {
      currentlySelected = widget.question.options.firstWhere((e) => e.code == widget.startValue, orElse: () {return null;},);
    }
    List<Widget> options = new List<Widget>();
    widget.question.options.forEach((option) {
      options.add(
        Row(children: [
          Radio(
            value: option,
            groupValue: currentlySelected,
            onChanged: (value) {
              setState(() {
                currentlySelected = value;
                widget.selectAnswer(value.code);
              });
            },
          ),
          Text(option.text, style: Theme.of(context).textTheme.bodyText1),
        ])
      );
    });
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.question.text, style: Theme.of(context).textTheme.headline6),
          ...options
        ],
      )
    );
  }
}