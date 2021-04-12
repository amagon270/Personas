import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  MultipleChoiceQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _MultipleChoiceQuestion createState() => _MultipleChoiceQuestion();
}

class _MultipleChoiceQuestion extends State<MultipleChoiceQuestion> {
  
  QuestionOption currentlySelected;

  @override
  void initState() {
    super.initState();
    currentlySelected = widget.question.options.firstWhere((e) => e.code == widget.startValue, orElse: () {return null;},);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> options = new List<Widget>();
    List<QuestionOption> questionOptions = widget.question.options;
    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      options.add(
        Row(children: [
          Radio(
            value: option,
            groupValue: currentlySelected,
            onChanged: (value) {
              if (widget.editable) {
                setState(() {
                  currentlySelected = value;
                  widget.selectAnswer(value.code);
                });
              }
            },
          ),
          Text(option.text, style: Theme.of(context).textTheme.bodyText1),
          image
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