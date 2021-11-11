import 'dart:convert';
import 'dart:math';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
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
    currentlySelected ??= new Map<String, bool>();
    List<Widget> options = [];
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    questionOptions = questionOptions.sublist(0, 6);
    double _questionsLength = questionOptions.length.toDouble();
    

    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );

      currentlySelected[option.fact] ??= false;
      double factor = ((option.order/_questionsLength)*pi*2) - pi;

      options.add(
        Container(
          alignment: Alignment(cos(factor), sin(factor)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.topCenter,
            children:[
              Positioned(
                child: Container(
                  //color: widget.data.backgroundColour,
                  child: Checkbox(
                    hoverColor: widget.data.backgroundColour,
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
                      //widget.data.selectAnswer(returnData);
                      widget.data.selectAnswer(json.encode(currentlySelected));
                    } : null,
                  )
                ),
              ),
              Positioned(
                top: -33,
                child: Container(
                  //color: widget.data.backgroundColour,
                  height: 30,
                  width: 30,
                  child: image
                )
              ),
              Positioned(
                bottom: 40,
                child: Container(
                  //color: widget.data.backgroundColour,
                  width: 110,
                  child: Text(option.text, textAlign: TextAlign.center,)
                )
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
                Container(
                  alignment: Alignment.center,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Image(
                        image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark 
                          ? "assets/images/BlackHexagon.png"
                          : "assets/images/WhiteHexagon.png"),
                        fit: BoxFit.fill,
                        width: constraints.maxWidth*0.88,
                        height: constraints.maxHeight*0.77,
                      );
                    }
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(widget.data.question.code, textAlign: TextAlign.center,)
                ),
                ...options,
              ]
            )
          ),
        ],
      )
    );
  }
}