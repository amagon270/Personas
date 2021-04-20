import 'dart:convert';
import 'dart:math';

import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiPolygonQuestion extends StatefulWidget {
  MultiPolygonQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _MultiPolygonQuestion createState() => _MultiPolygonQuestion();
}

class _MultiPolygonQuestion extends State<MultiPolygonQuestion> {
  
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
    double _questionsLength = questionOptions.length.toDouble();

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );

      currentlySelected[option.code] ??= false;
      double factor = ((option.order/_questionsLength)*pi*2) - pi;

      options.add(
        Container(
          alignment: Alignment(cos(factor), sin(factor)),
          child: Stack(
            overflow: Overflow.visible,
            alignment: AlignmentDirectional.topCenter,
            children:[
              Positioned(
                top: -3,
                child: Container(
                  child: Text(option.text)
                )
              ),
              Positioned(
                top: -33,
                child: Container(
                  height: 30,
                  width: 30,
                  child: image
                )
              ),
              Positioned(
                child: Checkbox(
                  value: currentlySelected[option.code],
                  onChanged: widget.editable ? (value) {
                    setState(() {
                      currentlySelected[option.code] = !currentlySelected[option.code];
                      widget.selectAnswer(json.encode(currentlySelected));
                    });
                  } : null,
                ),
              )
            ]
          ),
        )
      );
    });
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(widget.question.text, style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
          Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                ...options
              ]
            )
          ),
        ],
      )
    );
  }
}