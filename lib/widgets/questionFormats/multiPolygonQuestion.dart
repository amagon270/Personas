import 'dart:convert';
import 'dart:math';

import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiPolygonQuestion extends StatefulWidget {
  MultiPolygonQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _MultiPolygonQuestion createState() => _MultiPolygonQuestion();
}

class _MultiPolygonQuestion extends State<MultiPolygonQuestion> {
  
  Map<String, bool> currentlySelected;

  @override
  void initState() {
    super.initState();
    if (widget.data.startValue != null) {
      currentlySelected = Map<String, bool>();

      (widget.data.startValue as List<String>).forEach((e) { 
        currentlySelected[e] = true;
      });
      //currentlySelected = Map<String, bool>.from(json.decode(widget.data.startValue));
    }
  }

  @override
  Widget build(BuildContext context) {
    currentlySelected ??= new Map<String, bool>();
    List<Widget> options = new List<Widget>();
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    double _questionsLength = questionOptions.length.toDouble();

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );

      currentlySelected[option.value] ??= false;
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
                    //widget.data.selectAnswer(json.encode(currentlySelected));
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
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
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