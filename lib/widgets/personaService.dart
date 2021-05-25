import 'dart:convert';
import 'dart:io';

import 'package:Personas/widgets/interviewService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'factService.dart';

class Persona {
  String id;
  String name;
  Color color;
  List<Fact> facts;
  List<QuestionResponse> answers;
  int order;
}

class PersonaService {
  static final PersonaService _instance = PersonaService._internal();
  factory PersonaService() => _instance;

  List<Persona> allPersonas;
  String userId;

  static final List<String> specialQuestionIds = ["", "intro", "end", "blank"];

  PersonaService._internal();

  void save(String name, Session session) {
    Persona persona = new Persona();
    persona.id = session.id;

    //specifically find the color response and remove it from normal questions
    QuestionResponse colorResponse = session.answers.firstWhere((e) => (e.question.id == "personaColor"), orElse: () {return null;},);
    int colorString = colorResponse?.choice ?? 0;
    session.answers.removeWhere((e) => (e.question.id == "personaColor"));

    //specifically find the name of the persona and remove it from normal questions
    QuestionResponse nameResponse = session.answers.firstWhere((e) => (e.question.id == "personaName"), orElse: () {return null;},);
    session.answers.removeWhere((e) => (e.question.id == "personaName"));

    persona.color = Color(colorString) ?? Colors.white;
    persona.name = nameResponse?.choice ?? "";
    persona.answers = session.answers;
    persona.facts = session.facts;
    persona.order = allPersonas.length;
    savePersona(persona, userId);
  }

  void edit(Persona data) {
    savePersona(data, userId);
  }

  Persona get(String personaId) {
    return allPersonas.firstWhere((e) => (e.id == personaId), orElse: () {return null;},);
  }

  Future<bool> delete(String personaId) async {
    Persona _persona = allPersonas.firstWhere((e) => (e.id == personaId), orElse: () {return null;},);
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
    List<Persona> allPersonas = new List<Persona>();

    decodedData[userId]?.forEach((id, persona) {
      persona ??= {};
      Persona _persona = new Persona();
      _persona.id = id;
      _persona.name = persona["name"] ?? "";
      int colorInt = persona["color"] ?? 0;
      _persona.color = new Color(colorInt);
      _persona.order = persona["order"];

      List<Fact> _facts = new List<Fact>();
      persona["facts"]?.forEach((id, value) async {
        _facts.add(FactService().getFactById(id, value: value));
      });
      _persona.facts = _facts;

      List<QuestionResponse> _personaAnswers = new List<QuestionResponse>();
      persona["answers"]?.forEach((question, answer) async {
        Question questionObject = allQuestions.firstWhere((e) => (e.id == question), orElse: () {return null;},);
        if (questionObject != null) _personaAnswers.add(new QuestionResponse(questionObject, answer));
      });
      _persona.answers = _personaAnswers;

      allPersonas.add(_persona);
    });
    
    allPersonas.sort((a, b) => a.order.compareTo(b.order));
    this.allPersonas = allPersonas;
    return allPersonas;
  }

  Map savablePersonaMap(Persona persona, String userId, Map existingMap) {
    existingMap[userId] ??= {};
    existingMap[userId][persona.id] ??= {};
    existingMap[userId][persona.id]["answers"] ??= {};
    existingMap[userId][persona.id]["facts"] ??= {};

    existingMap[userId][persona.id]["name"] = persona.name;
    existingMap[userId][persona.id]["color"] = persona.color.value;
    existingMap[userId][persona.id]["order"] = persona.order;

    persona.facts?.forEach((fact) {
      existingMap[userId][persona.id]["facts"][fact.id] = fact.value;
    });
    print(existingMap[userId][persona.id]["facts"]);
    persona.answers?.forEach((answer) {
      existingMap[userId][persona.id]["answers"][answer.question.id] = answer.choice;
    });
    
    return existingMap;
  }

  void savePersona(Persona persona, String userId) async {
    Map decodedData = await readPersonaFile();
    decodedData = savablePersonaMap(persona, userId, decodedData);
    
    String newUserAnswers = json.encode(decodedData);
    writePersonaFile(newUserAnswers);
  }

  void setPersonaOrder(List<Persona> personas, String userId) async {
    await writePersonaFile("");
    personas.sort((a, b) => a.order.compareTo(b.order));
    Map completePersonaMap = new Map();
    personas.forEach((persona) {
      completePersonaMap = savablePersonaMap(persona, userId, completePersonaMap);
    });
    await writePersonaFile(json.encode(completePersonaMap));
  }

  Future<Map> readPersonaFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/personas.json');
    String userAnswers = "{}";
    try{
      userAnswers = await file.readAsString();
    } catch (e) {
      print("Couldn't find file, creating new file");
      userAnswers = '{"" : {}}';
    }
    return json.decode(userAnswers);
  }

  Future<bool> writePersonaFile(String fileData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/personas.json');
    await file.writeAsString(fileData);
    return true;
  }
}