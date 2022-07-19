import 'package:flutter/material.dart';
import 'package:personas/widgets/background/LoginBackground.dart';
import 'package:personas/widgets/button/BaseButton.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: LoginBackground(
                child: Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Column(
          children: [
            Image(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/logo_title.png"),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text("Little tagline goes here"),
            )
          ],
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
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
    ))));
  }
}
