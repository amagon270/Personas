import 'package:personas/services/questionService.dart';
import 'package:flutter/material.dart';

class TextOnlyQuestion extends StatefulWidget {
  TextOnlyQuestion({Key? key, required this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _TextOnlyQuestion createState() => _TextOnlyQuestion();
}

class _TextOnlyQuestion extends State<TextOnlyQuestion> {
  
  late QuestionOption currentlySelected;

  @override
  void initState() {
    super.initState();
    widget.data.selectAnswer(null);
  }

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      padding: EdgeInsets.all(20),
      child:
        Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6)
    );
  }
}