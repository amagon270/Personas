import 'package:flutter/material.dart';
import 'package:personas/widgets/ScrollTextBox.dart';
import 'package:personas/widgets/button/BaseButton.dart';

class RegisterPage extends StatelessWidget {
  final ScrollTextBox test = new ScrollTextBox(
    tapEntry: (int index) => {print(index)},
    entries: ["First up, let's get your profile set up", "Test8", "Test9", "Test10", "Test11", "Test12", "Test13", "Test14", "Test15", "Test16", "Test17", "Test18", "Test19"],
    );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Container(),
        test,
        Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                BaseButton(
                  onTap: () => {},
                  title: "Add Entry",
                ),
                BaseButton(
                  onTap: () => {Navigator.pushNamed(context, "/register")},
                  title: "Register",
                ),
                BaseButton(
                  onTap: () => {Navigator.pushNamed(context, "/login")},
                  title: "Login",
                  margin: EdgeInsets.only(bottom: 40, top: 10),
                ),
              ],
            ))
      ],
    )));
  }
}
