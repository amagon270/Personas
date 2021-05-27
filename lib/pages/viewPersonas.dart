import 'package:Personas/widgets/personaService.dart';
import 'package:flutter/material.dart';

class ViewPersonas extends StatefulWidget {
  ViewPersonas({Key key}): super(key: key);

  _ViewPersonas createState() => _ViewPersonas();
}

class _ViewPersonas extends State<ViewPersonas> {

  List<Persona> _allPersonas;
  PersonaService personaService;

  @override
  initState() {
    super.initState();
    _allPersonas = null;
  }

  List<Widget> createPersonaList(List<Persona> personas, BuildContext context) {
    List<Widget> widgets = new List<Widget>();
    personas.forEach((persona) {
      widgets.add(
        Container(
          key: ValueKey(persona.id),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10),
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
            }
          )
        )
      );
    });
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    personaService = PersonaService();
    return Scaffold(
      appBar: AppBar(title: Text("Personas"),),
      body: SafeArea(
        child: FutureBuilder(
          future: PersonaService().getPersonas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Getting Results");
            } else {
              _allPersonas ??= snapshot.data;
              return ReorderableListView(
                header: Container(
                  //padding: EdgeInsets.all(20),
                ),
                children: createPersonaList(_allPersonas, context),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    var item = _allPersonas.removeAt(oldIndex);
                    _allPersonas.insert(newIndex, item);
                  });
                  personaService.setPersonaOrder(_allPersonas, personaService.currentOrdering);
                }
              );
            }
          }
        )
      )
    );
  }
}