import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliderQuestion extends StatefulWidget {
  SliderQuestion({Key key, this.question, this.selectAnswer, this.startValue}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;

  @override
  _SliderQuestion createState() => _SliderQuestion();
}

class _SliderQuestion extends State<SliderQuestion> {
  
  double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue ??= widget.question.min?.toDouble() ?? 0;
    widget.selectAnswer(widget.question.min?.toDouble() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startValue != null) {
      _currentSliderValue = double.parse(widget.startValue);
    }
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
            max: widget.question.max?.toDouble() ?? 10,
            divisions: widget.question.max ?? 10,
            onChanged: (value) {
              setState(() {
                _currentSliderValue = value;
                widget.selectAnswer(value);
              });
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...labels
              ]
            )
          )
        ],
      )
    );
  }
}