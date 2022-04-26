import 'dart:convert';

import 'package:personas/services/questionService.dart';
import 'package:personas/widgets/utility.dart';
import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  MultipleChoiceQuestion({Key? key, required this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _MultipleChoiceQuestion createState() => _MultipleChoiceQuestion();
}

class _MultipleChoiceQuestion extends State<MultipleChoiceQuestion> {
  
  late QuestionOption currentlySelected;

  @override
  void initState() {
    super.initState();
    currentlySelected = widget.data.question.options.firstWhere((e) => e.value == widget.data.startValue,);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [];
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order!.compareTo(b.order!));
    
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image!)
      );
      options.add(
        Row(children: [
          Radio(
            value: option,
            groupValue: currentlySelected,
            onChanged: widget.data.editable ? (value) {
              setState(() {
                currentlySelected = value as QuestionOption;
                if (option.fact == "null") {
                  widget.data.selectAnswer(value.value);
                } else {
                  widget.data.selectAnswer(json.encode({option.fact.toString(): value.value}));
                }
              });
            } : null,
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
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          ...options
        ],
      )
    );
  }
}