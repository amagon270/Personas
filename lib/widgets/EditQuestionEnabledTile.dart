import 'package:personas/services/questionService.dart';
import 'package:flutter/material.dart';

class EditQuestionEnabledTile extends StatefulWidget {

  EditQuestionEnabledTile({required this.question});

  final Question question;

  @override
  _EditQuestionEnabledTileState createState() => _EditQuestionEnabledTileState();
}

class _EditQuestionEnabledTileState extends State<EditQuestionEnabledTile> {

  late bool questionStatus;

  @override
  void initState() {
    super.initState();
    questionStatus = widget.question.enabled;
  }

  @override
  build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: questionStatus ? Colors.green : Colors.red),
      onPressed: () {
        QuestionService().switchQuestionEnabled(widget.question.id);
        setState(() {
          questionStatus = !questionStatus;
        });
      },
      child: Text("${widget.question.code}", style: TextStyle(fontSize: 20),)
    );
  }
}