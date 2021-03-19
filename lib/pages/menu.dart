import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {

  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = new List<Widget>();
    items.add(
      RaisedButton(
        child: Text("Create Persona"),
        onPressed: () {
          Navigator.pushNamed(context, "/createPersona");
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