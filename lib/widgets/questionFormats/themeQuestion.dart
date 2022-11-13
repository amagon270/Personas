import 'dart:convert';
import 'dart:math';
import 'package:personas/services/questionService.dart';
import 'package:personas/widgets/hexagon.dart';
import 'package:personas/widgets/utility.dart';
import 'package:flutter/material.dart';

class ThemeQuestion extends StatefulWidget {
  ThemeQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _ThemeQuestion createState() => _ThemeQuestion();
}

class _ThemeQuestion extends State<ThemeQuestion> {
  
  Map<String, bool> currentlySelected;

  @override
  void initState() {
    super.initState();
    if (widget.data.startValue != null && widget.data.startValue != "") {
      currentlySelected = Map<String, bool>.from(json.decode(widget.data.startValue)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data.question.code);
    currentlySelected ??= new Map<String, bool>();
    List<Widget> options = [];
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    if (questionOptions.length >= 6) {
      questionOptions = questionOptions.sublist(0, 6);
    }

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );

      currentlySelected[option.fact] ??= false;

      options.add(
        Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          children:[
            Positioned(
              child: Container(
                child: Checkbox(
                  value: currentlySelected[option.fact],
                  onChanged: widget.data.editable ? (value) {
                    setState(() {
                      currentlySelected[option.fact] = !currentlySelected[option.fact];
                    });
                    List<String> returnData = [];
                    currentlySelected.forEach((key, value) { 
                      if (value == true) {
                        returnData.add(key);
                      }
                    });
                    widget.data.selectAnswer(json.encode(currentlySelected));
                  } : null,
                )
              ),
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
              bottom: 40,
              child: Container(
                width: 110,
                child: Text(option.text, textAlign: TextAlign.center,)
              )
            )
          ]
        )
      );
    });

    final size = min(min(MediaQuery.of(context).size.width, 800), MediaQuery.of(context).size.height - 150);
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.center,),
          Container(
            padding: EdgeInsets.all(20),
            height: size,
            width: size,
            child: Hexagon(options, widget.data.question.text)
          ),
        ],
      )
    );
  }
}