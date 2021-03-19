import 'package:Personas/pages/createPersona.dart';
import 'package:Personas/pages/login.dart';
import 'package:Personas/pages/menu.dart';
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
      default:
        return MaterialPageRoute(builder: (context) => HomePage());
    }
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = context.watch<User>().id;

    return userId == null
    ? Center(child: CircularProgressIndicator())
    : userId == ""
      ? LoginPage()
      : MenuPage();
  }
}
