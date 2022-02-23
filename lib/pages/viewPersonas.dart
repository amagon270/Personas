import 'package:personas/services/personaService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as ReOrder;

class ViewPersonas extends StatefulWidget {
  ViewPersonas({Key key}): super(key: key);

  _ViewPersonas createState() => _ViewPersonas();
}

class _ViewPersonas extends State<ViewPersonas> {

  List<Persona> _allPersonas;
  List<Widget> _items;
  PersonaService personaService;

  @override
  initState() {
    super.initState();
    _allPersonas = null;
  }

  int _indexOfKey(Key key) {
    return _items.indexWhere((a) => a.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    final draggedItem = _items[draggingIndex];
    final draggedPersona = _allPersonas[draggingIndex];

    setState(() {
      debugPrint("Reordering $item -> $newPosition");
      _items.removeAt(draggingIndex);
      _items.insert(newPositionIndex, draggedItem);

      _allPersonas.removeAt(draggingIndex);
      _allPersonas.insert(newPositionIndex, draggedPersona);
    });
    return true;
  }

  void _reorderDone(Key item) {
    personaService.setPersonaOrder(_allPersonas, personaService.currentOrdering);
    final draggedItem = _items[_indexOfKey(item)];
    debugPrint("Reordering finished for $draggedItem}");
  }

  List<Widget> createPersonaList(List<Persona> personas, BuildContext context) {
    List<Widget> widgets = [];
    personas.forEach((persona) {
      Color textColor = persona.color.computeLuminance() > 0.35 ? Colors.black : Colors.white;
      widgets.add(
        ReOrder.ReorderableItem(
          key: ValueKey(persona.id),
          childBuilder: (context, state) {
            return Opacity(
              opacity: state == ReOrder.ReorderableItemState.placeholder ? 0.0 :1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: persona.color,
                  border: Border.all(width: 1, color: Colors.black12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed("/viewPersona", arguments: persona);
                  },
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
                            child: Text(
                              persona.name,
                              style: TextStyle(color: textColor),
                              textAlign: TextAlign.center,
                            )
                          )
                        ),
                        ReOrder.ReorderableListener(
                          child: Container(
                            padding: EdgeInsets.only(right: 18.0, left: 18.0),
                            color: Color(0x08000000),
                            child: Center(
                              child: Icon(Icons.reorder, color: textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              )
            );   
          },
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
              _items = createPersonaList(_allPersonas, context);
              return ReOrder.ReorderableList(
                onReorder: _reorderCallback,
                onReorderDone: _reorderDone,
                child: ListView(
                  children: _items,
                )
              );
            }
          }
        )
      )
    );
  }


}