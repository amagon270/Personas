import 'package:Personas/widgets/MenuTile.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class EditQuestions extends StatelessWidget {
  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = [];
    List<Question> questions = QuestionService().allQuestions;
    questions.forEach((question) {
      items.add(
        Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              question.enabled = !question.enabled;
            },
            child: Text("${question.code}: ${question.enabled}", style: TextStyle(fontSize: 20),)
          )
        )
      );
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> menuItems = createMenu(context);
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            return menuItems[index];
          },
        ),
      ),
    );
  }
}