import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';

class QuestionResponse {
  Question question;
  String choice;
  DateTime timestamp;

  QuestionResponse(this.question, this.choice) {
    timestamp = DateTime.now();
  }
}

class Session {
  String id;
  DateTime dateStarted;
  DateTime dateCompleted;
  List<Question> questions;
  List<QuestionResponse> answers; 

  Session(this.id) {
    dateStarted = DateTime.now();
    questions = new List<Question>();
    answers = new List<QuestionResponse>();
  }
}

class InterviewService {
  List<Question> allQuestions;
  int currentIndex;
  Session currentSession;

  Future<Session> startSession() async {
    if (currentSession == null) {
      currentIndex = -1;
      currentSession = new Session(await UtilityFunctions.generateId());
      allQuestions = await QuestionService.loadQuestions();
      //allQuestions.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    }
    return currentSession;
  }

  Question nextQuestion() {
    currentIndex++;
    if (allQuestions.length > currentIndex) {
      currentSession.questions.add(allQuestions[currentIndex]);
      return allQuestions[currentIndex];
    } else {
      // TODO implement an end of persona function
    }
  }

  QuestionResponse getQuestionResponse(String questionId) {
    return currentSession.answers.firstWhere((e) => (e.question.id == questionId), orElse: (null));
  }

  void answerQuestion(String questionId, String personaId, String response, String userId) {
    if (questionId != null && questionId != "") {
      Question question = getQuestionById(currentSession, questionId);
      QuestionResponse questionResponse = new QuestionResponse(question, response);
      currentSession.answers.add(questionResponse);
      QuestionService.answerQuestion(question, personaId, questionResponse.choice, userId);
    }
  }

  Session getSession() {
    return currentSession;
  }

  ///searches through every question asked in the given session for one with a matching id
  Question getQuestionById(Session session, String id) {
    return session.questions.firstWhere((e) => (e.id == id), orElse: (null));
  }
}