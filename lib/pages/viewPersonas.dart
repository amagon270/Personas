import 'package:personas/services/personaService.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class ViewPersonas extends StatefulWidget {
  ViewPersonas({Key? key}): super(key: key);

  _ViewPersonas createState() => _ViewPersonas();
}

class _ViewPersonas extends State<ViewPersonas> {

  int variableSet = 0;
  List<Persona>? _allPersonas;
  late List<Widget> _items;
  late PersonaService personaService;
  late ScrollController _scrollController;
  late double width;
  late double height;

  @override
  initState() {
    super.initState();
    _allPersonas = null;
  }

  int _indexOfKey(Key key) {
    return _items.indexWhere((a) => a.key == key);
  }

  bool _reorderCallback(int oldIndex, int newIndex) {
    final draggedItem = _items[oldIndex];
    final draggedPersona = _allPersonas![oldIndex];

    setState(() {
      _items.removeAt(oldIndex);
      _items.insert(newIndex, draggedItem);

      _allPersonas!.removeAt(oldIndex);
      _allPersonas!.insert(newIndex, draggedPersona);
    });
    return true;
  }

  Widget ListItem(Persona persona, Color textColor, BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: persona.color,
        border: Border.all(width: 1, color: Colors.black12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed("/viewPersona", arguments: persona);
        },
        child: Text(
          persona.name,
          style: TextStyle(color: textColor),
          textAlign: TextAlign.center,
        ),
      )
    );
  }

  List<Widget> createPersonaList(List<Persona> personas, BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < personas.length; i++) {
      list.add(ListItem(personas[i], personas[i].color.computeLuminance() > 0.35 ? Colors.black : Colors.white, context));
    }
    return list;
  }
  
  @override
  Widget build(BuildContext context) {
    personaService = PersonaService();
    return Scaffold(
      appBar: AppBar(
        title: Text("Personas"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed("/createPersona");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: PersonaService().getPersonas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Getting Results");
            } else {
              _allPersonas ??= snapshot.data as List<Persona>?;
              _items = createPersonaList(_allPersonas!, context);
              // return ReOrder.ReorderableList(
              //   onReorder: _reorderCallback,
              //   onReorderDone: _reorderDone,
              //   child: ListView(
              //     children: _items,
              //   )
              // );
              return ReorderableWrap(
                spacing: 8.0,
                runSpacing: 4.0,
                padding: const EdgeInsets.all(8),
                children: _items,
                onReorder: _reorderCallback,
              );
            }
          }
        )
      )
    );
  }
}