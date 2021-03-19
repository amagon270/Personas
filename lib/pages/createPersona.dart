import 'dart:convert';

import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class CreatePersona extends StatefulWidget {
  CreatePersona();

  _CreatePersona createState() => _CreatePersona();
}

class _CreatePersona extends State<CreatePersona> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: QuestionService.loadQuestions(),
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Text("Loading");
            } else {
              return (Text(snapshot.data.toString()));
            }
          },
        )
      )
    );
  }
}