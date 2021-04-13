import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class MiddleSliderQuestion extends StatefulWidget {
  MiddleSliderQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _MiddleSliderQuestion createState() => _MiddleSliderQuestion();
}

class _MiddleSliderQuestion extends State<MiddleSliderQuestion> {
  
  double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.question.min?.toDouble() ?? 0;
    if (widget.startValue != null) {
      _currentSliderValue = double.parse(widget.startValue);
    }
    print(_currentSliderValue);
    //widget.selectAnswer(widget.question.min?.toDouble() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    //print(_currentSliderValue);
    int labelLength = widget.question.labels.length - 1;

    List<Widget> labels = new List<Widget>();
    widget.question.labels.forEach((label) {
      labels.add(Text(label));
    });
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.question.text, style: Theme.of(context).textTheme.headline6),
          Slider(
            value: _currentSliderValue,
            min: widget.question.min?.toDouble() ?? 0,
            max: labelLength.toDouble(),
            divisions: labelLength,
            onChanged: widget.editable ? (value) {
              setState(() {
                _currentSliderValue = value;
                widget.selectAnswer(value);
              });
            } : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.question.labels.first),
                Text(widget.question.labels[_currentSliderValue.truncate()]),
                Text(widget.question.labels.last)
              ]
            )
          )
        ],
      )
    );
  }
}