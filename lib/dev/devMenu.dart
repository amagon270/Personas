import 'package:personas/services/personaService.dart';
import 'package:personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevMenuPage extends StatelessWidget {

  List<Widget> createMenu(BuildContext context) {
    List<Widget> items = [];
    items.add(
      Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text("Dev Menu", style: TextStyle(fontSize: 20),)
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Menu"),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Delete All Personas"),
        onPressed: () {
          PersonaService().deleteAllPersonas();
        },
      )
    );
    items.add(
      ElevatedButton(
        child: Text("Delete User"),
        onPressed: () async {
          context.read<User>().setUserData();
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