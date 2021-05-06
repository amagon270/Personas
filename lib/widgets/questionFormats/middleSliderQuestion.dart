import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class MiddleSliderQuestion extends StatefulWidget {
  MiddleSliderQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _MiddleSliderQuestion createState() => _MiddleSliderQuestion();
}

class _MiddleSliderQuestion extends State<MiddleSliderQuestion> {
  
  double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = 0;
    if (widget.data.startValue != null) {
      _currentSliderValue = widget.data.startValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(_currentSliderValue);
    int labelLength = widget.data.question.labels.length - 1;

    List<Widget> labels = new List<Widget>();
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
            min: 0,
            max: labelLength.toDouble(),
            divisions: labelLength,
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
                Text(widget.data.question.labels.first),
                Text(widget.data.question.labels[_currentSliderValue.truncate()], textAlign: TextAlign.center,),
                Text(widget.data.question.labels.last)
              ]
            )
          )
        ],
      )
    );
  }
} 