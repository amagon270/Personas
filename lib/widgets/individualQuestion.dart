import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndividualQuestion extends StatefulWidget {
  IndividualQuestion({Key key, this.question}) : super(key: key);

  final QuestionData question;

  @override
  _IndividualQuestion createState() => _IndividualQuestion();
}

class _IndividualQuestion extends State<IndividualQuestion> {
  
  String currentlySelected;

  @override
  Widget build(BuildContext context) {
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
                widget.question.answer = value;
              });
            },
          ),
          Text(option, style: Theme.of(context).textTheme.bodyText1),
        ])
      );
    });
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.question.question, style: Theme.of(context).textTheme.headline6),
          ...options
        ],
      )
    );
  }
}