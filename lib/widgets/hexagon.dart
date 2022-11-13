import 'dart:math';
import 'package:flutter/material.dart';

class Hexagon extends StatelessWidget {
  Hexagon(this.options, this.title);
  

  final List<Widget> options;
  final String title;

  @override
  Widget build(BuildContext context) {
    List<Widget> optionWidgets = [];

    for (int i = 0; i < options.length; i++ ) {
      double factor = ((i/options.length)*pi*2) - pi;
      optionWidgets.add(
        Container(
          alignment: Alignment(cos(factor)*0.885, sin(factor)*0.885),
          child: options[i]
        )
      );
    };

    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Image(
                image: AssetImage(
                  Theme.of(context).brightness == Brightness.dark 
                  ? "assets/images/BlackHexagon.png"
                  : "assets/images/WhiteHexagon.png"),
                fit: BoxFit.fill,
                width: constraints.maxWidth*0.88,
                height: constraints.maxHeight*0.77,
              );
            }
          )
        ),
        Container(
          alignment: Alignment.center,
          child: Text(title, textAlign: TextAlign.center,)
        ),
        ...optionWidgets,
      ]
    );
  }
}