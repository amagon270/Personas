import 'dart:ui';
import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget? child;
  const LoginBackground({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            constraints: BoxConstraints.expand(),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/test1.gif"),
                ))),
        Container(constraints: BoxConstraints.expand(), child: child)
      ],
    );
  }
}
