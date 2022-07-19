import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final EdgeInsets margin;

  const BaseButton({
    Key? key,
    required this.onTap, 
    required this.title, 
    this.backgroundColor = Colors.transparent, 
    this.textColor = Colors.black,
    this.margin = EdgeInsets.zero
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(height: 40),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Text(title),
      ),
    );
  }
}