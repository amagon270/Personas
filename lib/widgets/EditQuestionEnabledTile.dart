import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class EditQuestionEnabledTile extends StatefulWidget {

  EditQuestionEnabledTile({this.question});

  final Question question;

  @override
  _EditQuestionEnabledTileState createState() => _EditQuestionEnabledTileState();
}

class _EditQuestionEnabledTileState extends State<EditQuestionEnabledTile> {

  bool questionStatus;

  @override
  void initState() {
    super.initState();
    questionStatus = widget.question.enabled;
  }

  @override
  build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        QuestionService().switchQuestionEnabled(widget.question.id);
        setState(() {
          questionStatus = !questionStatus;
        });
      },
      child: Text("${widget.question.code}: ${widget.question.enabled}", style: TextStyle(fontSize: 20),)
    );
  }
}