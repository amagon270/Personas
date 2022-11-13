import 'dart:math';
import 'package:personas/services/questionService.dart';
import 'package:personas/widgets/hexagon.dart';
import 'package:personas/widgets/utility.dart';
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
    List<Widget> options = [];
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );

      currentlySelected[option.value] ??= false;

      options.add(
        Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.topCenter,
          children:[
            Positioned(
              child: Checkbox(
                value: currentlySelected[option.value],
                onChanged: widget.data.editable ? (value) {
                  setState(() {
                    currentlySelected[option.value] = !currentlySelected[option.value];
                  });
                  List<String> returnData = [];
                  currentlySelected.forEach((key, value) { 
                    if (value == true) {
                      returnData.add(key);
                    }
                  });
                  widget.data.selectAnswer(returnData);
                } : null,
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
        ),
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