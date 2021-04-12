import 'package:Personas/dev/devMenu.dart';
import 'package:Personas/pages/createPersona.dart';
import 'package:Personas/pages/introduction.dart';
import 'package:Personas/pages/login.dart';
import 'package:Personas/pages/menu.dart';
import 'package:Personas/pages/viewPersona.dart';
import 'package:Personas/pages/viewPersonas.dart';
import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/personaService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => User(),
        ),
      ],
      child: Personas()
    )
  );
}

class Personas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personas App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      onGenerateRoute: (settings) => routeHandler(settings),
    );
  }

  Route<dynamic> routeHandler(RouteSettings settings) {
    switch (settings.name) {
      case "/createPersona":
        return MaterialPageRoute(builder: (context) => CreatePersona());
      case "/viewPersonas":
        return MaterialPageRoute(builder: (context) => ViewPersonas());
      case "/viewPersona":
        return MaterialPageRoute(builder: (context) => ViewPersona(persona: settings.arguments));
      case "/devMenu":
        return MaterialPageRoute(builder: (context) => DevMenuPage());
      case "/intro":
        return MaterialPageRoute(builder: (context) => IntroducitonPage());
      default:
        return MaterialPageRoute(builder: (context) => HomePage());
    }
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //just initialising these early so they can finish all the file calls they need
    QuestionService();
    PersonaService();
    InterviewService();
    
    String userId = context.watch<User>().id;
    bool watchedIntro = context.watch<User>().hasWatchedIntro;

    if (userId == null) {
      return Center(child: CircularProgressIndicator());
    } else if (watchedIntro == false) {
      return IntroducitonPage();
    } else if (userId == "") {
      return LoginPage();
    } else {
      return MenuPage();
    }
  }
}
