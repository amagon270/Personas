import 'dart:convert';
import 'package:personas/services/supaBaseService.dart';

class Fact {
  Fact(this.id, this.text, this.tags, {this.value, this.negatedFacts});

  final String id;
  String text;
  List<String> tags;
  dynamic value;
  List<String>? negatedFacts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Fact { id: $id, text: $text, tags: $tags, value: $value, negatedFacts: $negatedFacts}\n";
  }

  Fact.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    text = json['text'],
    tags = json['tags'].map<String>((json) => json.toString()).toList(),
    value = json['value'],
    negatedFacts = json['negatedFacts']?.map<String>((json) => json.toString())?.toList() ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'text': text, 
      'tags': tags, 
      'value': value, 
      'negatedFacts': negatedFacts
    };
  }
}

class FactException implements Exception {
  String cause;
  FactException(this.cause);
}

class FactService {
  static final FactService _instance = FactService._internal();
  factory FactService() => _instance;

  FactService._internal() {
    //assignFacts();
  }

  late List<Fact> _allFacts;

  List<Fact>? get allFacts => _allFacts;

  Fact getFactById(String id, {dynamic value}) {
    Fact newFact = _allFacts.firstWhere((e) => e.id == id, orElse: () {
      if (id != "") {
        throw ("There has been an error with the $id fact");
      }
      throw("There is no fact with the id: $id");
    });
    return new Fact(newFact.id, newFact.text, newFact.tags, value: value);
  }

  void assignFacts() async {
    _allFacts = await loadFacts();
  }

  static Future<List<Fact>> loadFacts() async {
    //final data = await rootBundle.loadString("assets/export.json");
    final data = SupaBaseService().qMatrix;
    List<dynamic> decodedData = json.decode(data.toString())["facts"] ?? [];
    List<Fact> newFacts = [];
    decodedData.forEach((fact) {
      var id = fact["id"].toString();
      var text = fact["text"];
      var tags = ((fact["tags"] ?? []) as List<dynamic>).map((e) => e as String).toList();
      List<String> negatedFacts = ((fact["negatedFacts"] ?? []) as List<dynamic>).map((e) => e.toString()).toList();
      Fact newFact = Fact(id, text, tags, negatedFacts: negatedFacts);
      newFacts.add(newFact);
    });
    return newFacts;
  }
}
