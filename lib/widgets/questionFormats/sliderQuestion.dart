import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliderQuestion extends StatefulWidget {
  SliderQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _SliderQuestion createState() => _SliderQuestion();
}

class _SliderQuestion extends State<SliderQuestion> {
  
  double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.data.question.min?.toDouble() ?? 0;
    if (widget.data.startValue != null) {
      _currentSliderValue = widget.data.startValue;
    }
    print(_currentSliderValue);
    //widget.data.selectAnswer(widget.data.question.min?.toDouble() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> labels = [];
    widget.data.question.labels.forEach((label) {
      labels.add(Text(label));
    });
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          Slider(
            value: _currentSliderValue,
            min: widget.data.question.min?.toDouble() ?? 0,
            max: widget.data.question.max?.toDouble() ?? 10,
            divisions: widget.data.question.max ?? 10,
            onChanged: widget.data.editable ? (value) {
              setState(() {
                _currentSliderValue = value;
                widget.data.selectAnswer(value);
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