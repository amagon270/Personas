import 'package:Personas/widgets/personaService.dart';
import 'package:flutter/material.dart';

class ViewPersonas extends StatelessWidget {

  List<Widget> createPersonaList(List<Persona> personas, BuildContext context) {
    List<Widget> widgets = new List<Widget>();
    personas.forEach((persona) {
      widgets.add(Container(
          decoration: BoxDecoration(
            color: persona.color,
            border: Border.all(width: 1, color: Colors.black12),
  
          ),
        child: FlatButton(
        color: persona.color,
        child: Container(
          child: Text(
            persona.name,
            style: TextStyle(color: persona.color.computeLuminance() > 0.35 ? Colors.black : Colors.white),
          )
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("/viewPersona", arguments: persona);
        })
      ));
    });
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personas"),),
      body: SafeArea(
        child: FutureBuilder(
          future: PersonaService().getPersonas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Getting Results");
            } else {
              List<Widget> allPersonas = createPersonaList(snapshot.data, context);
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) { 
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    child:  allPersonas[index]
                  );
                },
              );
            }
          }
        )
      )
    );
  }
  
}