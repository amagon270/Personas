import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';

class ViewPersona extends StatefulWidget {
  ViewPersona({Key key, this.persona}): super(key: key);

  final Persona persona;

  _ViewPersona createState() => _ViewPersona();
}

class _ViewPersona extends State<ViewPersona> {
  List<Widget> personas;

  List<Widget> createPersonaList(List<Persona> personas) {
    List<Widget> widgets = new List<Widget>();
    personas.forEach((persona) {
      widgets.add(FlatButton(
        color: persona.color,
        child: Container(
          decoration: BoxDecoration(color: persona.color),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        ),
        onPressed: null
      ));
    });
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Persona"),),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: widget.persona.color),
          child: ListView.builder(
            itemCount: widget.persona.answers.length,
            itemBuilder: (BuildContext context, int index) { 
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                //child: Text(widget.persona.answers[index].question.text + ":   " + widget.persona.answers[index].choice)
                child: widget.persona.answers[index].question.generateQuestionWidget(startValue: widget.persona.answers[index].choice)
              );
            },
          )
        )
      )
    );
  }
}