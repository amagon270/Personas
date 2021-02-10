import 'package:Personas/pages/login.dart';
import 'package:Personas/pages/questions.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => User(),
        )
      ],
      child: Personas()
    )
  );
}

class Personas extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    bool needToLogIn = (context.watch<User>().id == null);
    return MaterialApp(
      title: 'Personas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: needToLogIn 
        ? LoginPage(title: 'Log in')
        : QuestionsPage(),
    );
  }
}
