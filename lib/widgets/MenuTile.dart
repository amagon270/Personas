import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuTile extends StatefulWidget {

  MenuTile();

  @override
  _MenuTileState createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {

  bool timerStatus;

  @override
  void initState() {
    super.initState();
    timerStatus = context.read<User>().enableTimer;
  }

  @override
  build(BuildContext context) {
    bool timerStatus = context.read<User>().enableTimer;
    return ElevatedButton(
      child: Text("Timer: ${timerStatus?'on':'off'}"),
      onPressed: () {
        context.read<User>().toggleTimer();
        setState(() {
          timerStatus = context.read<User>().enableTimer;
        });
      }
    );
  }
}