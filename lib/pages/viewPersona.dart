import 'package:Personas/widgets/personaService.dart';
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
              itemCount: widget.persona.answers.length,
              itemBuilder: (BuildContext context, int index) { 
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  //child: Text(widget.persona.answers[index].question.text + ":   " + widget.persona.answers[index].choice)
                  child: widget.persona.answers[index].question.generateQuestionWidget(
                    startValue: widget.persona.answers[index].choice, 
                    editable: _editable,
                    selectAnswer: (value) {
                      widget.persona.answers[index].choice = value.toString();
                    },
                  )
                );
              },
            )
          )
        )
      )
    );
  }
}