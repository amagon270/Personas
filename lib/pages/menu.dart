import 'package:Personas/widgets/personaService.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {

  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = new List<Widget>();
    items.add(
      Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text("Menu", style: TextStyle(fontSize: 20),)
      )
    );
    items.add(
      RaisedButton(
        child: Text("Create Persona"),
        onPressed: () {
          Navigator.pushNamed(context, "/createPersona");
        },
      )
    );
    items.add(
      RaisedButton(
        child: Text("View Personas"),
        onPressed: () {
          Navigator.pushNamed(context, "/viewPersonas");
        },
      )
    );
    items.add(
      RaisedButton(
        child: Text("View Intro"),
        onPressed: () {
          Navigator.pushNamed(context, "/intro");
        },
      )
    );
    items.add(
      RaisedButton(
        child: Text("Dev Menu"),
        onPressed: () {
          Navigator.pushNamed(context, "/devMenu");
        },
      )
    );
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