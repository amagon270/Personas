import 'package:Personas/widgets/questionService.dart';
import 'package:nanoid/async/nanoid.dart';

class QuestionResponse {
  Question quesiton;
  String choice;
  DateTime timestamp;

  QuestionResponse(this.quesiton, this.choice) {
    timestamp = DateTime.now();
  }
}

class Session {
  String id;
  DateTime dateStarted;
  DateTime dateCompleted;
  List<QuestionResponse> answers; 

  Session(this.id) {
    dateStarted = DateTime.now();
    answers = new List<QuestionResponse>();
  }
}

class InterviewService {
  List<Question> allQuestions;
  int currentIndex;
  Session currentSession;

  void startSession() async {
    currentIndex = -1;
    currentSession = new Session(await nanoid(16));
    allQuestions = await QuestionService.loadQuestions();
    allQuestions.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
  }

  Question nextQuestion() {
    currentIndex++;
    return allQuestions[currentIndex];
  }

  QuestionResponse getQuestionResponse(String questionId) {

  }

  void answerQuestion(String questionId, dynamic response) {
  
  }

  Session getSession() {
  
  }
}