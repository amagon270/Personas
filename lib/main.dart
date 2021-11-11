import 'package:Personas/dev/devMenu.dart';
import 'package:Personas/pages/createPersona.dart';
import 'package:Personas/pages/introduction.dart';
import 'package:Personas/pages/login.dart';
import 'package:Personas/pages/menu.dart';
import 'package:Personas/pages/viewPersona.dart';
import 'package:Personas/pages/viewPersonas.dart';
import 'package:Personas/widgets/supaBaseService.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  Widget build(BuildContext context){
    final supabase = SupaBaseService();

    return FutureBuilder(
      future: supabase.getQMatrix(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            title: "Getting Results",
            home: Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Loading Question Matrix")
                  ]
                )
              )
            )
          );
        } else {
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
      }
    );
  }

  Route<dynamic> routeHandler(RouteSettings settings) {
    Widget newPage;
    switch (settings.name) {
      case "/createPersona":
        newPage = CreatePersona();
        break;
      case "/viewPersonas":
        newPage = ViewPersonas();
        break;
      case "/viewPersona":
        newPage = ViewPersona(persona: settings.arguments);
        break;
      case "/devMenu":
        newPage = DevMenuPage();
        break;
      case "/intro":
        newPage = IntroducitonPage();
        break;
      default:
        newPage = HomePage();
        break;
    }
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {return newPage;},
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween); 

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
