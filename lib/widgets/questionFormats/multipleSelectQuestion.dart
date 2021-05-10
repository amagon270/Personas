import 'dart:convert';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleSelectQuestion extends StatefulWidget {
  MultipleSelectQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _MultipleSelectQuestion createState() => _MultipleSelectQuestion();
}

class _MultipleSelectQuestion extends State<MultipleSelectQuestion> {
  
  Map<String, bool> currentlySelected;

  @override
  void initState() {
    super.initState();
    if (widget.data.startValue != null) {
      currentlySelected = Map<String, bool>();
      (widget.data.startValue as List<String>).forEach((e) { 
        currentlySelected[e] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    currentlySelected ??= new Map<String, bool>();
    List<Widget> options = new List<Widget>();
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      currentlySelected[option.value] ??= false;
      options.add(
        Row(
          children: [
            Checkbox(
              value: currentlySelected[option.value],
              onChanged: widget.data.editable ? (value) {
                setState(() {
                  currentlySelected[option.value] = !currentlySelected[option.value];
                });
                List<String> returnData = new List<String>();
                currentlySelected.forEach((key, value) { 
                  if (value == true) {
                    returnData.add(key);
                  }
                });
                widget.data.selectAnswer(returnData);
              } : null,
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
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          ...options
        ],
      )
    );
  }
}