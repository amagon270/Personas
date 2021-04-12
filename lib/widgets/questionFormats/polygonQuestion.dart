import 'dart:math';

import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PolygonQuestion extends StatefulWidget {
  PolygonQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _PolygonQuestion createState() => _PolygonQuestion();
}

class _PolygonQuestion extends State<PolygonQuestion> {
  
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
    double test = questionOptions.length.toDouble();
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      double factor = ((option.order/test)*pi*2) - pi;
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
                child: Radio(
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
          Text(widget.question.text, style: Theme.of(context).textTheme.headline6),
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