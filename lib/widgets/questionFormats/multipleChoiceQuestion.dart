import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  MultipleChoiceQuestion({Key key, this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _MultipleChoiceQuestion createState() => _MultipleChoiceQuestion();
}

class _MultipleChoiceQuestion extends State<MultipleChoiceQuestion> {
  
  QuestionOption currentlySelected;

  @override
  void initState() {
    super.initState();
    currentlySelected = widget.data.question.options.firstWhere((e) => e.value == widget.data.startValue, orElse: () {return null;},);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> options = new List<Widget>();
    List<QuestionOption> questionOptions = widget.data.question.options;

    questionOptions.sort((a, b) => a.order.compareTo(b.order));
    
    questionOptions.forEach((option) {
      Widget image = Container(
        width: 40,
        child: UtilityFunctions.getImageFromString(option.image)
      );
      options.add(
        Row(children: [
          Radio(
            value: option,
            groupValue: currentlySelected,
            onChanged: widget.data.editable ? (value) {
              setState(() {
                currentlySelected = value;
                widget.data.selectAnswer(value.value);
              });
            } : null,
          ),
          Text(option.text, style: Theme.of(context).textTheme.bodyText1),
          image
        ])
      );
    });
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          ...options
        ],
      )
    );
  }
}