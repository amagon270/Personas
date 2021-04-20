import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliderQuestion extends StatefulWidget {
  SliderQuestion({Key key, this.question, this.selectAnswer, this.startValue, this.editable}) : super(key: key);

  final Question question;
  final ValueChanged selectAnswer;
  final String startValue;
  final bool editable;

  @override
  _SliderQuestion createState() => _SliderQuestion();
}

class _SliderQuestion extends State<SliderQuestion> {
  
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
              crossAxisAlignment: CrossAxisAlignment.start,
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