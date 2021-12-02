import 'package:Personas/widgets/EditQuestionEnabledTile.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class EditQuestions extends StatelessWidget {
  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = [];
    List<Question> questions = QuestionService().allQuestions;
    questions.forEach((question) {
      items.add(
        EditQuestionEnabledTile(
          question: question,
        ),
      );
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> menuItems = createMenu(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Questions'),
      ),
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