import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:personas/services/interviewService.dart';
import 'package:personas/services/questionService.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personas/services/factService.dart';
import 'package:personas/widgets/auth.dart';
import 'package:personas/widgets/utility.dart';

class Persona {
  String id;
  String name;
  Color color;
  List<Fact> facts;
  List<QuestionResponse> answers;

  @override
  String toString() {
    return "$facts";
  }

  Persona();

  Persona.fromJson(Map<String, dynamic> json) : 
    id = json['id'],
    name = json["data"]["name"],
    color = json["data"]["color"],
    facts = json["data"]["facts"].map<Fact>((json) => Fact.fromJson(json)).toList(),
    answers = json["data"]["answers"].map<QuestionResponse>((json) => QuestionResponse.fromJson(json)).toList();

  Map<String, dynamic> toJson() {
    List<Map> _facts = this.facts != null ? this.facts.map((i) => i.toJson()).toList() : null;
    List<Map> _answers = this.answers != null ? this.answers.map((i) => i.toJson()).toList() : null;
    return {
      "id": id,
      "data": {
        "name": name,
        "color": color.value,
        "facts": _facts,
        "answers": _answers
      }
    };
  }
}

class PersonaService {
  static final PersonaService _instance = PersonaService._internal();
  factory PersonaService() => _instance;

  List<Persona> allPersonas;
  String userId;
  String currentOrdering;

  static final List<String> specialQuestionIds = ["", "intro", "blank"];

  PersonaService._internal() {
    currentOrdering = "default";
    //getPersonas();
  }

  void save(Session session) {
    Persona persona = new Persona();
    persona.id = session.id;

    //specifically find the color response and remove it from normal questions
    QuestionResponse colorResponse = session.answers.firstWhere(
      (e) => (e.question.type == QuestionType.ColourPicker),
      orElse: () {return null;},
    );
    print(colorResponse?.choice);
    int colorString = colorResponse?.choice ?? 0;
    session.answers.removeWhere((e) => (e.question.type == QuestionType.ColourPicker));

    //specifically find the name of the persona and remove it from normal questions
    QuestionResponse nameResponse = session.answers.firstWhere(
      (e) => (e.question.code == "personaName"),
      orElse: () {return null;},
    );
    session.answers.removeWhere((e) => (e.question.code == "personaName"));
    session.facts.removeWhere((e) => e.text == "blank");

    persona.color = Color(colorString) ?? Colors.white;
    persona.name = nameResponse?.choice ?? "";
    persona.answers = [...session.answers];
    persona.facts = [...session.facts];
    savePersona(persona, userId);
  }

  void edit(Persona data) {
    savePersona(data, userId);
  }

  Persona get(String personaId) {
    return allPersonas.firstWhere(
      (e) => (e.id == personaId),
      orElse: () {
        return null;
      },
    );
  }

  Future<bool> delete(String personaId) async {
    Persona _persona = allPersonas.firstWhere(
      (e) => (e.id == personaId),
      orElse: () {
        return null;
      },
    );
    allPersonas.remove(_persona);

    Map decodedData = await readPersonaFile();
    decodedData[userId].remove(personaId);
    String encodedJson = json.encode(decodedData);
    await writePersonaFile(encodedJson);
    return true;
  }

  void deleteAllPersonas() async {
    Map decodedData = await readPersonaFile();
    decodedData = {};
    String encodedJson = json.encode(decodedData);
    writePersonaFile(encodedJson);
  }

  Future<List<Persona>> getPersonas({String userId}) async {
    userId ??= this.userId;
    Map decodedData = await readPersonaFile();
    List<Question> allQuestions = QuestionService().allQuestions;
    List<Persona> allPersonas = [];

    decodedData[userId]?.forEach((id, persona) {
      persona ??= {};
      Persona _persona = new Persona();
      _persona.id = id;
      _persona.name = persona["name"] ?? "";
      int colorInt = persona["color"] ?? 0;
      _persona.color = new Color(colorInt);

      List<Fact> _facts = [];
      persona["facts"]?.forEach((id, value) async {
        _facts.add(FactService().getFactById(id, value: value));
      });
      _persona.facts = _facts;

      List<QuestionResponse> _personaAnswers = [];
      persona["answers"]?.forEach((question, answer) async {
        Question questionObject = allQuestions.firstWhere(
          (e) => (e.id == question),
          orElse: () {return null;},
        );
        if (questionObject != null)
          _personaAnswers.add(new QuestionResponse(questionObject, answer));
      });
      _persona.answers = _personaAnswers;

      allPersonas.add(_persona);
    });
    List<Persona> orderedPersonas = await getPersonaOrder(allPersonas, currentOrdering ?? "default");
    if (allPersonas.length > 0) {
      setPersonaOrder(orderedPersonas, currentOrdering ?? "default");
    }

    this.allPersonas = orderedPersonas;
    return orderedPersonas;
  }

  //used to turn a persona object into a json savable map
  Map savablePersonaMap(Persona persona, String userId, Map existingMap) {
    existingMap[userId] ??= {};
    existingMap[userId][persona.id] ??= {};
    existingMap[userId][persona.id]["answers"] ??= {};
    existingMap[userId][persona.id]["facts"] ??= {};

    existingMap[userId][persona.id]["name"] = persona.name;
    existingMap[userId][persona.id]["color"] = persona.color.value;

    persona.facts?.forEach((fact) {
      existingMap[userId][persona.id]["facts"][fact?.id] = fact?.value;
    });
    persona.answers?.forEach((answer) {
      existingMap[userId][persona.id]["answers"][answer.question.id] =
          answer.choice;
    });

    return existingMap;
  }

  void savePersona(Persona persona, String userId) async {
    Map decodedData = await readPersonaFile();
    decodedData = savablePersonaMap(persona, userId, decodedData);
    
    String newUserAnswers = json.encode(decodedData);
    writePersonaFile(newUserAnswers);
    allPersonas.add(persona);
    setPersonaOrder(allPersonas, currentOrdering ?? "default");
    await Auth.savePersona(persona);
  }

  void setPersonaOrder(List<Persona> personas, String orderName) async {
    Map personaOrderMap = await readPersonaOrderFile();
    personaOrderMap[userId] ??= {};
    personaOrderMap[userId][orderName] = {};

    for (int i = 0; i < personas.length; i++) {
      personaOrderMap[userId][orderName][personas[i].id] = i;
    }

    await writePersonaOrderFile(json.encode(personaOrderMap));
  }

  Future<List<Persona>> getPersonaOrder(
      List<Persona> personas, String orderName) async {
    Map personaOrderMap = await readPersonaOrderFile();
    //null safety
    personaOrderMap[userId] ??= {};
    personaOrderMap[userId][orderName] ??= {};
    var order = personaOrderMap[userId][orderName] as Map<dynamic, dynamic>;
    personas.sort((a, b) => (order[a.id] ?? 0).compareTo((order[b.id]) ?? 0));
    return personas;
  }

  Future<Map<String, dynamic>> readPersonaFile() async {
    return await UtilityFunctions.getStorage("personas") ?? {"": {}};
  }

  Future<bool> writePersonaFile(String fileData) async {
    return await UtilityFunctions.setStorage("personas", fileData);
  }

  Future<Map> readPersonaOrderFile() async {
    return await UtilityFunctions.getStorage("personaOrder") ?? {"": {}};
  }

  Future<bool> writePersonaOrderFile(String fileData) async {
    return await UtilityFunctions.setStorage("personaOrder", fileData);
  }
}
