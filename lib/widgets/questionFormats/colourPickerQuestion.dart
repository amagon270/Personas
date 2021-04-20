import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:Personas/widgets/questionService.dart';


class ColourPickerQuestion extends StatefulWidget {
  ColourPickerQuestion({Key key, this.question, this.selectAnswer}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;

  State<ColourPickerQuestion> createState() => _ColourPickerQuestion();
}

class _ColourPickerQuestion extends State<ColourPickerQuestion> {
  Color currentColor = Colors.limeAccent;

  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: currentColor
        // border: Border.all()
      ),
      child: Center(
        child: Column( 
          children:[ 
            Container(
              padding: EdgeInsets.all(20),
              child: Text(widget.question.text, style: Theme.of(context).textTheme.headline6,)
            ),
            Center(
              child: RaisedButton(
                elevation: 3.0,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0.0),
                        contentPadding: const EdgeInsets.all(0.0),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            showLabel: false,
                            enableAlpha: false,
                            pickerColor: currentColor,
                            onColorChanged: (color) {
                              setState(() {
                                currentColor = color;
                                widget.selectAnswer(color.value);
                              });
                            },
                            //enableLabel: true,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Choose Colour', style: Theme.of(context).textTheme.button),
              ),
            )
          ]
        )
      )
    );
  }
}