import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewPersonas extends StatelessWidget {

  List<Widget> createPersonaList(List<Persona> personas, BuildContext context) {
    List<Widget> widgets = new List<Widget>();
    personas.forEach((persona) {
      widgets.add(FlatButton(
        color: persona.color,
        child: Container(
          decoration: BoxDecoration(color: persona.color),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("/viewPersona", arguments: persona);
        }
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
          future: QuestionService.getPersonas(context.read<User>().id),
          builder: (context, snapshot) {
            print(snapshot.data);
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