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