import 'dart:convert';
import 'package:flutter/services.dart';

class Fact {
  Fact(this.id, this.text, this.tags, {this.value});

  final String id;
  String text;
  List<String> tags;
  dynamic value;

  @override 
  bool operator ==(Object other) => 
    identical(this, other) || 
    other is Fact &&
    runtimeType == other.runtimeType &&
    id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FactException implements Exception {
  String cause;
  FactException(this.cause);
}

class FactService {
  static final FactService _instance = FactService._internal();
  factory FactService() => _instance;

  FactService._internal() {
    assignFacts();
  }

  List<Fact> _allFacts;

  List<Fact> get allFacts => _allFacts;

  Fact getFactById(String id, {dynamic value}) {
    Fact newFact = _allFacts.firstWhere((e) => e.id == id, orElse: () {throw ("There has been an error with the $id fact");});
    newFact.value = value;
    return newFact;
  }

  void assignFacts() async {
    _allFacts = await loadFacts();
  }

  static Future<List<Fact>> loadFacts() async {
    final data = await rootBundle.loadString("assets/questions/facts.json");
    List<dynamic> decodedData = json.decode(data);
    List<Fact> newFacts = new List<Fact>();
    decodedData.forEach((fact) {
      var id = fact["id"] ?? "";
      var text = fact["text"];
      var tags = (fact["tags"] as List<dynamic>).map((e) => e as String).toList();
      Fact newFact = Fact(id, text, tags);
      newFacts.add(newFact);
    });
    return newFacts;
  }
}