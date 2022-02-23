import 'dart:convert';
import 'dart:math';

import 'package:personas/services/questionService.dart';
import 'package:personas/widgets/utility.dart';
import 'package:flutter/material.dart';

class PolygonQuestion extends StatefulWidget {
  PolygonQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _PolygonQuestion createState() => _PolygonQuestion();
}

class _PolygonQuestion extends State<PolygonQuestion> {
  
  QuestionOption currentlySelected;

  @override
  void initState() {
    super.initState();
    currentlySelected = widget.data.question.options.firstWhere((e) => e.value == widget.data.startValue, orElse: () {return null;},);
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> options = [];
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    double optionsLength = questionOptions.length.toDouble();

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      double factor = ((option.order/optionsLength)*pi*2) - pi;

      options.add(
        Container(
          alignment: Alignment(cos(factor), sin(factor)),
          child: Stack(
            clipBehavior: Clip.none,
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
                  onChanged: widget.data.editable ? (value) {
                    setState(() {
                      currentlySelected = value;
                      if (option.fact == "null") {
                        widget.data.selectAnswer(value.value);
                      } else {
                        widget.data.selectAnswer(json.encode({option.fact: value.value}));
                      }
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
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
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