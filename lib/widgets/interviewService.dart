import 'dart:convert';

import 'package:Personas/widgets/personaService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/services.dart';

enum TriggerType {
  Any,
  All,
  Always
}

enum Operator {
  GreaterThan,
  LessThan,
  EqualTo,
  Exists
}

class QuestionResponse {
  Question question;
  dynamic choice;
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
  List<Fact> facts;

  Session(this.id) {
    dateStarted = DateTime.now();
    questions = new List<Question>();
    answers = new List<QuestionResponse>();
    facts = new List<Fact>();
  }
}

class Rule {
  Rule(this.id, this.triggerType, this.tests, this.action);

  String id;
  TriggerType triggerType;
  List<RuleTest> tests;
  RuleAction action;
}

class RuleAction {
  RuleAction({this.fact, this.questionId});

  Fact fact;
  String questionId;
}

class RuleTest {
  RuleTest(this.fact, this.operation, {this.parameter});

  String fact;
  Operator operation;
  dynamic parameter;
}

class Fact {
  Fact(this.subject, this.value);

  String subject;
  dynamic value;
}

class InterviewService {
  List<Question> allQuestions;
  List<Rule> allRules;
  int currentRuleIndex;
  int currentIndex;
  Session currentSession;

  static final Question endQuestion = Question("end", "", "", QuestionType.MultipleChoice, "", []);

  Future<Session> startSession() async {
    if (currentSession == null) {
      currentIndex = 0;
      currentRuleIndex = 0;
      currentSession = new Session(await UtilityFunctions.generateId());
      allQuestions = await QuestionService.loadQuestions();
      allRules = await loadRules();
    }
    return currentSession;
  }

  Question nextQuestion(String userId) {
    Rule rule = allRules[currentRuleIndex];
    currentRuleIndex++;

    //Unpacks the TriggerType operator in the rule.  
    bool action;
    bool actionChange;
    bool actionComparison;
    //for TriggerType.all start with true and if any test fails set it to false
    if (rule.triggerType == TriggerType.All) {
      action = true;
      actionChange = false;
      actionComparison = false;
    //for TriggerType.any start with false and if any test succeeds set it to true
    } else if (rule.triggerType == TriggerType.Any) {
      action = false;
      actionChange = true;
      actionComparison = true;
    } else if (rule.triggerType == TriggerType.Always) {
      action = true;
      actionChange = true;
      actionComparison = true;
    }
    rule.tests?.forEach((test) {
      //setting up blank facts if they don't exist.  In this case just assume a minimal value 
      //unless we are checking that it exists then skip this part
      if (currentSession.facts.where((fact) => fact.subject == test.fact).length == 0 && test.operation != Operator.Exists) {
        //can't use a switch here because of the comparison i'm doing
        if (test.parameter is int) {
          currentSession.facts.add(Fact(test.fact, 0));
        } else if (test.parameter is bool) {
          currentSession.facts.add(Fact(test.fact, false));
        } else if (test.parameter is String) {
          currentSession.facts.add(Fact(test.fact, ""));
        } else {
          currentSession.facts.add(Fact(test.fact, 0));
        }
      }
      switch (test.operation) {
        case Operator.GreaterThan:
          if (actionComparison == (test.parameter > currentSession.facts.firstWhere((fact) => fact.subject == test.fact).value)) {
            action = actionChange;
          }
          break;
        case Operator.LessThan:
          if (actionComparison == (test.parameter < currentSession.facts.firstWhere((fact) => fact.subject == test.fact).value)) {
            action = actionChange;
          }
          break;
        case Operator.EqualTo:
          if (actionComparison == (test.parameter == currentSession.facts.firstWhere((fact) => fact.subject == test.fact).value)) {
            action = actionChange;
          }
          break;
        case Operator.Exists:
          if (actionComparison == (currentSession.facts.where((fact) => fact.subject == test.fact).length == 0)) {
            action = actionChange;
          }
          break;
      }
    });

    if (action) {
      if (rule.action.fact != null && rule.action.questionId != null) {
        
      } else if (rule.action.fact != null) {
        currentSession.facts.add(rule.action.fact);
        return nextQuestion(userId);
      } else if (rule.action.questionId != null) {
        Question question = QuestionService().getQuestionById(rule.action.questionId);
        currentSession.questions.add(question);
        return question;
      }
    }

    //all temporary untill we get the proper ai going
    // if (allQuestions.length > currentIndex) {
    //   Question newQuestion = allQuestions[currentIndex];
    //   currentSession.questions.add(newQuestion);
    //   currentIndex++;
    //   return newQuestion;
    // } else {
    //   PersonaService().save("Test", currentSession, userId);
    //   return endQuestion;
    // }
  }

  void answerQuestion(String questionId, String personaId, dynamic response, String userId) {
    //I have a few null question things that i didn't want answered here so i just skip them
    if (questionId != null && questionId != "") {
      Question question = getSessionQuestionById(currentSession, questionId);
      QuestionResponse questionResponse = new QuestionResponse(question, response);
      if (!PersonaService.specialQuestionIds.contains(questionId)) {
        currentSession.answers.add(questionResponse);
        currentSession.facts.add(Fact(question.fact, response));
      }
    }
  }

  Session getSession() {
    return currentSession;
  }

  ///searches through every question asked in the given session for one with a matching id
  Question getSessionQuestionById(Session session, String id) {
    return session.questions.firstWhere((e) => (e.id == id), orElse: (null));
  }

  QuestionResponse getQuestionResponse(String questionId) {
    return currentSession.answers.firstWhere((e) => (e.question.id == questionId), orElse: (null));
  }

  static Future<List<Rule>> loadRules() async {
    final data = await rootBundle.loadString("assets/questions/rules.json");
    List<dynamic> decodedData = json.decode(data);
    List<Rule> newRules = new List<Rule>();
    decodedData.forEach((rule) {
      String id = rule["id"] ?? "";
      var triggerType = rule["triggerType"].toString().toEnum(TriggerType.values);
      List<RuleTest> newTests = new List<RuleTest>();
      (rule['tests'] as List)?.forEach((test) {
        RuleTest _newTest = RuleTest(test["factId"], test["operation"].toString().toEnum(Operator.values), parameter: test["parameter"]);
        // print("Adding tests to rule: factId ${_newTest.fact}, operation ${_newTest.operation}, parameter ${_newTest.parameter}");
        newTests.add(_newTest);
      });

      Map action = rule["action"];
      RuleAction newAction;
      if (action["fact"] != null) {
        Fact fact = Fact(action["fact"]["subject"], action["fact"]["value"]);
        newAction = RuleAction(fact: fact);
      } else {
        newAction = RuleAction(questionId: action["questionId"]);
      }

      Rule newRule = Rule(id, triggerType, newTests, newAction);
      
      newRules.add(newRule);
    });
    return newRules;
  }
}