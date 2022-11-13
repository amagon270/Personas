import 'package:personas/services/personaService.dart';
import 'package:personas/services/questionService.dart';
import 'package:personas/services/factService.dart';
import 'package:personas/widgets/utility.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'interviewService.dart';

class SupaBaseService {
  static final SupaBaseService _instance = SupaBaseService._internal();
  factory SupaBaseService() => _instance;

  SupaBaseService._internal() {
    getQMatrix();
  }

  String _qMatrix;
  String get qMatrix => _qMatrix;
  bool _isSupabaseInitialized = false;

  String _authToken;
  String get authToken => _authToken;
  set authToken(String value) {_authToken = value;}

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

      writeLocalDatabase(_qMatrix);

      QuestionService().assignQuestions();
      PersonaService().getPersonas();
      InterviewService();
      FactService().assignFacts();
      return true;
      
    } catch (e) {
      print(e);
      try {
        _qMatrix = await readLocalDatabase();
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

  Future<String> readLocalDatabase() async {
    return await UtilityFunctions.getStorage("database") ?? {"": {}};
  }

  Future<bool> writeLocalDatabase(String fileData) async {
    return await UtilityFunctions.setStorage("database", fileData);
  }
}