import 'package:Personas/widgets/MenuTile.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = [];
    items.add(
      Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text("Menu", style: TextStyle(fontSize: 20),)
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Create Persona"),
        onPressed: () {
          Navigator.pushNamed(context, "/createPersona");
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("View Personas"),
        onPressed: () {
          Navigator.pushNamed(context, "/viewPersonas");
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("View Intro"),
        onPressed: () {
          Navigator.pushNamed(context, "/intro");
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Dev Menu"),
        onPressed: () {
          Navigator.pushNamed(context, "/devMenu");
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Edit Questions"),
        onPressed: () {
          Navigator.pushNamed(context, "/editQuestions");
        },
      )
    );
    items.add(
      MenuTile()
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