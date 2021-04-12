import 'package:Personas/widgets/personaService.dart';
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

  static final Question endQuestion = Question("end", "", "", QuestionType.MultipleChoice, []);

  Future<Session> startSession() async {
    if (currentSession == null) {
      currentIndex = 0;
      currentSession = new Session(await UtilityFunctions.generateId());
      allQuestions = await QuestionService.loadQuestions();
      //allQuestions.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    }
    return currentSession;
  }

  Question nextQuestion(String userId) {
    //all temporary untill we get the proper ai going
    if (allQuestions.length > currentIndex) {
      Question newQuestion = allQuestions[currentIndex];
      currentSession.questions.add(newQuestion);
      currentIndex++;
      return newQuestion;
    } else {
      PersonaService().save("Test", currentSession, userId);
      return endQuestion;
    }
  }

  void answerQuestion(String questionId, String personaId, String response, String userId) {
    //I have a few null question things that i didn't want answerd here so i just skip them
    if (questionId != null && questionId != "") {
      Question question = getQuestionById(currentSession, questionId);
      QuestionResponse questionResponse = new QuestionResponse(question, response);
      if (!PersonaService.specialQuestionIds.contains(questionId)) {
        currentSession.answers.add(questionResponse);
      }
    }
  }

  Session getSession() {
    return currentSession;
  }

  ///searches through every question asked in the given session for one with a matching id
  Question getQuestionById(Session session, String id) {
    return session.questions.firstWhere((e) => (e.id == id), orElse: (null));
  }

  QuestionResponse getQuestionResponse(String questionId) {
    return currentSession.answers.firstWhere((e) => (e.question.id == questionId), orElse: (null));
  }
}