import 'package:personas/services/questionService.dart';
import 'package:flutter/material.dart';

class TextInputQuestion extends StatefulWidget {
  TextInputQuestion({Key? key, required this.data}) : super(key: key);

  final QuestionInputData data;

  @override
  _TextInputQuestion createState() => _TextInputQuestion();
}

class _TextInputQuestion extends State<TextInputQuestion> {
  
  late TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.data.question.text, style: Theme.of(context).textTheme.headline6),
          TextField(
            controller: _controller,
            onChanged: (String value) async {
              setState(() {
                widget.data.selectAnswer(value);
              });
            },
          )
        ],
      )
    );
  }
}