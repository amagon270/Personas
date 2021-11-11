import 'package:Personas/widgets/personaService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import 'factService.dart';
import 'interviewService.dart';

class SupaBaseService {
  static final SupaBaseService _instance = SupaBaseService._internal();
  factory SupaBaseService() => _instance;

  SupaBaseService._internal() {
    //getQMatrix();
  }

  String _qMatrix;
  String get qMatrix => _qMatrix;
  bool _isSupabaseInitialized = false;

  Future<bool> getQMatrix() async {
    if (_isSupabaseInitialized) {
      return true;
    }
    try {
      await Supabase.initialize(
        url: "https://usqmtvptioodqnbokizz.supabase.co",
        anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyNTQ1MDA1MiwiZXhwIjoxOTQxMDI2MDUyfQ.gZpmtAz767MVifN_wsh8LBGkfV3iPXa3ICHyzhcDP80",
      );
    
      _isSupabaseInitialized = true;
      final api = await http.get(Uri.parse("https://question-matrix-creator-gamma.vercel.app/api/export"));
      _qMatrix = api.body;
      // final storage = await Supabase.instance.client.storage.from("public").download("personas/export.json");
      // _qMatrix = String.fromCharCodes(storage.data);
      print("Qmatrix Data");
      print(_qMatrix);

      QuestionService().assignQuestions();
      PersonaService().getPersonas();
      InterviewService();
      FactService().assignFacts();
      return true;
      
    } catch (e) {
      print(e);
      return false;
    }
  }

}