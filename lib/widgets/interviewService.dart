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
  Exists,
  Contains
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
  List<Rule> processedRules;
  List<Fact> facts;

  //I need this to store memory of facts for the back button
  List<Fact> individualFacts;

  Session(this.id) {
    dateStarted = DateTime.now();
    questions = new List<Question>();
    answers = new List<QuestionResponse>();
    processedRules = new List<Rule>();
    facts = new List<Fact>();
    individualFacts = new List<Fact>();
  }
}

class Rule {
  Rule(this.id, this.priority, this.triggerType, this.tests, this.action);

  String id;
  int priority;
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

  final String subject;
  dynamic value;

  @override 
  bool operator ==(Object other) => 
    identical(this, other) || 
    other is Fact &&
    runtimeType == other.runtimeType &&
    subject == other.subject;

  @override
  int get hashCode => subject.hashCode;


}

class InterviewService {
  List<Question> allQuestions;
  List<Rule> allRules;
  int currentRuleIndex;
  Session currentSession;

  static final Question endQuestion = Question("end", "", "", QuestionType.MultipleChoice, "", []);
  static final Question blankQuestion = Question("blank", "", "Something went wrong with the question", QuestionType.MultipleChoice, "", []);

  Future<Session> startSession() async {
    if (currentSession == null) {
      currentRuleIndex = 0;
      currentSession = new Session(await UtilityFunctions.generateId());
      allQuestions =  await QuestionService.loadQuestions();
      allRules = await loadRules();
    }
    return currentSession;
  }

  bool _checkRule(Rule rule) {
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
        } else if (test.parameter is String) {
          currentSession.facts.add(Fact(test.fact, ""));
        }
      }
      //This goes against clarity but also saves about 20+ lines of repeating code so I'm sticking with it
      //e.g. GreaterThan with All Type; test.parameter is 3 and fact.value is 1
      //action starts at true; actionComparison is false; actionChange is false
      //fact > parameter is false; actionComparison is also false; action = actionChange 
      //action = false; 
      //all future tests can only set action to false again so it will never become true after 1 test fails
      //oposite done with Any Type; Action starts false and can only be changed to true
      dynamic factValue = currentSession.facts.firstWhere((fact) => fact.subject == test.fact, orElse: () => null,)?.value;
      switch (test.operation) {
        case Operator.GreaterThan:
          if (actionComparison == (factValue > test.parameter)) {
            action = actionChange;
          }
          break;
        case Operator.LessThan:
          if (actionComparison == (factValue < test.parameter)) {
            action = actionChange;
          }
          break;
        case Operator.EqualTo:
          if (actionComparison == (factValue == test.parameter)) {
            action = actionChange;
          }
          break;
        case Operator.Exists:
          if (actionComparison == (currentSession.facts.where((fact) => fact.subject == test.fact).length != 0)) {
            action = actionChange;
          }
          break;
        case Operator.Contains:
          print(factValue);
          if (factValue is List) {
            if (actionComparison == factValue.contains(test.parameter)) {
              action = actionChange;
            }
          } else if (actionComparison == (factValue == test.parameter)) {
            action = actionChange;
          }
          break;
      }
    });

    return action;
  }

  Question nextQuestion() {
    //failsafe if we run out of rules
    if (currentRuleIndex >= allRules.length) {
      PersonaService().save("Test", currentSession);
      return endQuestion;
    }

    List<Rule> possibleRules = new List<Rule>();
    allRules.forEach((newRule) { 
      if (!currentSession.processedRules.contains(newRule) && _checkRule(newRule)) {
        possibleRules.add(newRule);
      }
    });
    if (possibleRules.length == 0) {
      PersonaService().save("Test", currentSession);
      return endQuestion;
    }
    possibleRules.sort((a, b) => b.priority.compareTo(a.priority));
    Rule rule = possibleRules.first;
    currentSession.processedRules.add(rule);

    //if both fact and question exist in the rule do both
    if (rule.action.fact != null && rule.action.questionId != null) {
      addFactToList(rule.action.fact, currentSession.facts);
      currentSession.individualFacts.add(rule.action.fact);
      Question question = QuestionService().getQuestionById(rule.action.questionId);
      if (question != null) {
        currentSession.questions.add(question);
        return question;
      } else {
        return blankQuestion;
      }

    //if only the fact exist in the rule add the fact then ask the next question
    } else if (rule.action.fact != null) {
      addFactToList(rule.action.fact, currentSession.facts);
      currentSession.individualFacts.add(rule.action.fact);
      return nextQuestion();

    //if only the question exists then return the question
    } else if (rule.action.questionId != null) {
      Question question = QuestionService().getQuestionById(rule.action.questionId);
      if (question != null) {
        currentSession.questions.add(question);
        return question;
      } else {
        return blankQuestion;
      }
    }
    //if no action was specified then as a failsafe return the blank question
    return blankQuestion;
  }

  QuestionResponse previousQuestion() {
    Rule rule;
    //remove the last fact added so the user should be at the same state as when they first reached this rule
    if (currentSession.individualFacts.length > 0) {
      removeFactFromList(currentSession.individualFacts.last, currentSession.facts);
      currentSession.individualFacts.removeLast();
    }

    currentSession.processedRules.removeLast();
    rule = currentSession.processedRules.last;
    
    //this situation means that 2 facts were added from 1 rule and so needs another removed
    if (rule.action.fact != null && rule.action.questionId != null) {
      removeFactFromList(currentSession.individualFacts.last, currentSession.facts);
      currentSession.individualFacts.removeLast();
    }
    //if the rule has a question
    if (rule.action.questionId != null) {
      currentSession.questions.removeLast();
      QuestionResponse answer = currentSession.answers.firstWhere((answer) => answer.question.id == rule.action.questionId, orElse: () => null,);
      if (answer != null) {
        currentSession.answers.remove(answer);
        return answer;
      } else {
        return QuestionResponse(currentSession.questions.last, "");
      }
    } else {
      return previousQuestion();
    }
  }

  void answerQuestion(String questionId, String personaId, dynamic response, String userId) {
    //I have a few null question things that i didn't want answered here so i just skip them
    if (questionId != null && questionId != "") {
      Question question = getSessionQuestionById(currentSession, questionId);
      QuestionResponse questionResponse = new QuestionResponse(question, response);
      if (!PersonaService.specialQuestionIds.contains(questionId)) {
        currentSession.answers.add(questionResponse);
        addFactToList(Fact(question.factSubject, response), currentSession.facts);
        currentSession.individualFacts.add(Fact(question.factSubject, response));
      }
    }
  }

  void addFactToList(Fact newFact, List<Fact> list) {
    Fact existingFact = list.firstWhere((fact) => fact == newFact, orElse: () {return null;},);
    if (existingFact != null) {
      print("existing fact add: ${existingFact.value}");
      if (newFact.value is int) {
        existingFact.value += newFact.value;
      } else {
        existingFact.value = newFact.value;
      }
    } else {
      list.add(newFact);
    }
  }

  void removeFactFromList(Fact newFact, List<Fact> list) {
    Fact existingFact = list.firstWhere((fact) => fact == newFact, orElse: () {return null;},);
    if (existingFact != null) {
    print("existing fact subtract: ${existingFact.value}");
      if (newFact.value is int) {
          existingFact.value -= newFact.value;
      } else if (newFact.value is String) {
        existingFact.value = "";
      } else {
        list.removeWhere((fact) => fact.subject == newFact.subject);
      }
    }
  }

  Session getSession() {
    return currentSession;
  }

  ///searches through every question asked in the given session for one with a matching id
  Question getSessionQuestionById(Session session, String id) {
    return session.questions.firstWhere((e) => (e.id == id), orElse: () => null);
  }

  QuestionResponse getQuestionResponse(String questionId) {
    return currentSession.answers.firstWhere((e) => (e.question.id == questionId), orElse: () => null);
  }

  static Future<List<Rule>> loadRules() async {
    final data = await rootBundle.loadString("assets/questions/rules.json");
    List<dynamic> decodedData = json.decode(data);
    List<Rule> newRules = new List<Rule>();

    decodedData.forEach((rule) {
      String id = rule["id"] ?? "";
      int priority = rule["priority"] ?? 1;
      var triggerType = rule["triggerType"].toString().toEnum(TriggerType.values);

      List<RuleTest> newTests = new List<RuleTest>();
      (rule['tests'] as List)?.forEach((test) {
        RuleTest _newTest = RuleTest(test["factId"], test["operation"].toString().toEnum(Operator.values), parameter: test["parameter"]);
        // print("Adding tests to rule: factId ${_newTest.fact}, operation ${_newTest.operation}, parameter ${_newTest.parameter}");
        newTests.add(_newTest);
      });

      Map action = rule["action"];
      RuleAction newAction = RuleAction();
      if (action["fact"] != null) {
        Fact fact = Fact(action["fact"]["subject"], action["fact"]["value"]);
        newAction.fact = fact;
      } 
      if (action["questionId"] != null) {
        newAction.questionId = action["questionId"];
      }

      Rule newRule = Rule(id, priority, triggerType, newTests, newAction);
      
      newRules.add(newRule);
    });
    return newRules;
  }
}