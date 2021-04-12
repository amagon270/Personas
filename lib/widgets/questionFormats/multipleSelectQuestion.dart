import 'dart:convert';

import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleSelectQuestion extends StatefulWidget {
  MultipleSelectQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _MultipleSelectQuestion createState() => _MultipleSelectQuestion();
}

class _MultipleSelectQuestion extends State<MultipleSelectQuestion> {
  
  Map<String, bool> currentlySelected;

  @override
  void initState() {
    super.initState();
    if (widget.startValue != null) {
      currentlySelected = Map<String, bool>.from(json.decode(widget.startValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    currentlySelected ??= new Map<String, bool>();
    List<Widget> options = new List<Widget>();
    List<QuestionOption> questionOptions = widget.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      currentlySelected[option.code] ??= false;
      options.add(
        Row(
          children: [
            Checkbox(
              value: currentlySelected[option.code],
              onChanged: (value) {
                if (widget.editable) {
                  setState(() {
                    currentlySelected[option.code] = !currentlySelected[option.code];
                    widget.selectAnswer(json.encode(currentlySelected));
                  });
                }
              },
            ),
            Text(option.text, style: Theme.of(context).textTheme.bodyText1),
            image
          ]
        )
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