import 'package:personas/services/questionService.dart';
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
    if (widget.data.startValue != null && widget.data.startValue != "") {
      _currentSliderValue = widget.data.startValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    int labelLength = widget.data.question.labels.length - 1;

    List<Widget> labels = [];
    widget.data.question.labels.forEach((label) {
      labels.add(Text(label));
    });
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.data.question.labels.first, 
                  textAlign: TextAlign.start, 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.data.question.labels.last, 
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ]
            )
          ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.data.question.labels[_currentSliderValue.truncate()], textAlign: TextAlign.center,),
              ]
            )
          )
        ],
      )
    );
  }
} 