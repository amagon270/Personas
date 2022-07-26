import 'package:flutter/material.dart';
import 'package:personas/widgets/ScrollTextBox.dart';
import 'package:personas/widgets/button/BaseButton.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List<String> messages = ["Welcome to MyPersonalities"];
  List<String> allMessagesOne = [
    "Welcome to MyPersonalities",
    "First up, Lets get your profile set up"
  ];
  List<String> allMessagesTwo = [
    "Hi",
    "MyPersonallities would like to get to know you",
    "Some bits of required details",
    "",
    "Some other bit of required details",
    "",
    "Great we're all set! Let's visit the dashboard"
  ];
  int progress = 0;

  void ProgressStep() {
    setState(() {
      progress++;
    
    if (progress < 2) {
      messages = allMessagesOne.sublist(0, progress+1);
    } else {
      messages = allMessagesTwo.sublist(0, progress-1);
    }
    });
  }

  Widget interaction() {
    if (progress == 1) {
      return Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
            ));
    } else {
      return  InkWell(
          child: Container(
            constraints: BoxConstraints.expand(),
          ),
          onTap: ProgressStep,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ScrollTextBox(
            tapEntry: (int index) => {print(index)},
            entries: messages,
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: interaction(),
          )
        ),
      ],
    )));
  }
}
