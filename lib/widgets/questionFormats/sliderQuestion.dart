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
    if (widget.data.startValue != null && widget.data.startValue != "") {
      _currentSliderValue = widget.data.startValue;
    }
    //widget.data.selectAnswer(widget.data.question.min?.toDouble() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> labels = [];
    widget.data.question.labels.forEach((label) {
      labels.add(Text(label));
    });
    int min = widget.data.question.min;
    int max = widget.data.question.max;
    int currentLabel = (((_currentSliderValue - min)/max)*labels.length).floor().clamp(0, labels.length-1);
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
            min: min?.toDouble() ?? 0,
            max: max?.toDouble() ?? 1,
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
                Text(widget.data.question.labels[currentLabel], textAlign: TextAlign.center,),
              ]
            )
          )
        ],
      )
    );
  }
}