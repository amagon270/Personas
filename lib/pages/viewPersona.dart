import 'package:personas/services/factService.dart';
import 'package:personas/services/personaService.dart';
import 'package:flutter/material.dart';

class ViewPersona extends StatefulWidget {
  ViewPersona({Key key, this.persona}): super(key: key);

  final Persona persona;

  _ViewPersona createState() => _ViewPersona();
}

class _ViewPersona extends State<ViewPersona> {
  
  bool _editable = false;

  @override
  Widget build(BuildContext context) {
    widget.persona.facts.sort((a, b) {
      if (a.text == "colour") {
        return -1;
      } if (b.text == "colour") {
        return 1;
      }
      
      if (a.value is double) {
        return -1;
      } if (b.value is double) {
        return 1;
      } 
      return a.text.toLowerCase().compareTo(b.text.toLowerCase());
    });
    return Theme(
      data: ThemeData(
        brightness: widget.persona.color.computeLuminance() > 0.35 ? Brightness.light : Brightness.dark,
        primaryColor: Colors.blue,
        buttonColor: Colors.grey[400],
        textTheme: TextTheme(button: TextStyle(color: Colors.black))
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.persona.name),
          actions: [
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text("Are you sure you want to delete this persona?"),
                      actions: [
                        TextButton(
                          child: Text("Delete"),
                          onPressed: () async {
                            await PersonaService().delete(widget.persona.id);
                            Navigator.of(context).pushNamedAndRemoveUntil("/viewPersonas", ModalRoute.withName("/"));
                          },
                        ),
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }, 
                        )
                      ],
                    );
                  },
                );
              },
            ),
            _editable 
            ? TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  PersonaService().edit(widget.persona);
                  _editable = !_editable;
                });
              },
            )
            : TextButton(
              child: Text("Edit"),
              onPressed: () {
                setState(() {
                  _editable = !_editable;
                });
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: widget.persona.color),
            child: ListView.builder(
              itemCount: widget.persona.facts.length,
              itemBuilder: (BuildContext context, int index) { 
                Fact fact = widget.persona.facts[index];
                Widget tile;
                if (fact.value == false || fact.value.toString() == "" || fact.value == null) {
                  return Container(); 
                }
                if (fact.value is double) {
                  return Column(children: [
                    Text(fact.text),
                    Slider(value: fact.value, onChanged: (e) {})
                  ]);
                } else if (fact.value == true) {
                  tile = Text(widget.persona.facts[index].text);
                } else {
                  tile = Text(widget.persona.facts[index].text + ": " + widget.persona.facts[index].value.toString());
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: tile
                  // child: widget.persona.answers[index].question.generateQuestionWidget(
                  //   startValue: widget.persona.answers[index].choice, 
                  //   editable: _editable,
                  //   selectAnswer: (value) {
                  //     widget.persona.answers[index].choice = value.toString();
                  //   },
                  // )
                );
              },
            )
          )
        )
      )
    );
  }
}