import 'dart:convert';
import 'dart:io';

import 'package:Personas/widgets/factService.dart';
import 'package:Personas/widgets/personaService.dart';
import 'package:Personas/widgets/questionService.dart';
import 'package:Personas/widgets/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum TriggerType { Any, All, Always }

enum Operator { GreaterThan, LessThan, EqualTo, Exists, Contains }

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

class InterviewService {
  List<Question> allQuestions;
  List<Rule> allRules;
  Session currentSession;

  static final Question endQuestion =
      Question("end", "", "", QuestionType.TextOnly, "", []);
  static final Question blankQuestion = Question("blank", "",
      "Something went wrong with the question", QuestionType.TextOnly, "", []);

  Future<Session> startSession() async {
    if (currentSession == null) {
      allQuestions = await QuestionService.loadQuestions();
      allRules = await loadRules();
      currentSession = new Session(await UtilityFunctions.generateId());
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
      if (currentSession.facts.where((fact) => fact.id == test.fact).length ==
              0 &&
          test.operation != Operator.Exists) {
        //can't use a switch here because of the comparison i'm doing
        if (test.parameter is int) {
          currentSession.facts
              .add(FactService().getFactById(test.fact, value: 0));
        } else if (test.parameter is String) {
          currentSession.facts
              .add(FactService().getFactById(test.fact, value: ""));
        }
      }
      //This goes against clarity but also saves about 20+ lines of repeating code so I'm sticking with it
      //e.g. GreaterThan with All Type; test.parameter is 3 and fact.value is 1
      //action starts at true; actionComparison is false; actionChange is false
      //fact > parameter is false; actionComparison is also false; action = actionChange
      //action = false;
      //all future tests can only set action to false again so it will never become true after 1 test fails
      //oposite done with Any Type; Action starts false and can only be changed to true
      dynamic factValue = currentSession.facts
          .firstWhere(
            (fact) => fact.id == test.fact,
            orElse: () => null,
          )
          ?.value;
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
          if (actionComparison ==
              (currentSession.facts
                      .where((fact) => fact.id == test.fact)
                      .length !=
                  0)) {
            action = actionChange;
          }
          break;
        case Operator.Contains:
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
    //saveUnfinishedSession(currentSession);

    List<Rule> possibleRules = new List<Rule>();
    allRules.forEach((newRule) {
      if (!currentSession.processedRules.contains(newRule) &&
          _checkRule(newRule)) {
        possibleRules.add(newRule);
      }
    });

    //out of rules end the session
    if (possibleRules.length == 0) {
      clearUnfinishedSession();
      PersonaService().save(currentSession);
      return endQuestion;
    }

    possibleRules.sort((a, b) => b.priority.compareTo(a.priority));
    Rule rule = possibleRules.first;
    currentSession.processedRules.add(rule);

    if (rule.action.fact != null) {
      addFactToList(rule.action.fact, currentSession.facts);
      currentSession.individualFacts.add(rule.action.fact);
    }

    if (rule.action.questionId != null) {
      Question question =
          QuestionService().getQuestionById(rule.action.questionId);
      if (question != null) {
        currentSession.questions.add(question);
        return question;
      } else {
        return blankQuestion;
      }
    }

    return nextQuestion();
  }

  QuestionResponse previousQuestion() {
    Rule rule;
    //remove the last fact added so the user should be at the same state as when they first reached this rule
    if (currentSession.individualFacts.length > 0) {
      removeFactFromList(
          currentSession.individualFacts.last, currentSession.facts);
      currentSession.individualFacts.removeLast();
    }

    currentSession.processedRules.removeLast();
    rule = currentSession.processedRules.last;

    //this situation means that 2 facts were added from 1 rule and so needs another removed
    if (rule.action.fact != null && rule.action.questionId != null) {
      removeFactFromList(
          currentSession.individualFacts.last, currentSession.facts);
      currentSession.individualFacts.removeLast();
    }
    //if the rule has a question
    if (rule.action.questionId != null) {
      currentSession.questions.removeLast();
      QuestionResponse answer = currentSession.answers.firstWhere(
        (answer) => answer.question.id == rule.action.questionId,
        orElse: () => null,
      );
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

  void answerQuestion(QuestionResponse response, String userId) {
    //I have a few null question things that i didn't want answered here so i just skip them
    if (response.question.code != null && response.question.code != "") {
      if (!PersonaService.specialQuestionIds.contains(response.question.code)) {
        String factId;
        print(response.question.options);
        if (response.question.options.length > 0) {
          factId = response.question?.options
          ?.firstWhere((option) => option?.value == response?.choice
            ,orElse: () {return null;})?.fact ?? response.question.factSubject;
        }
        if (factId == "null" || factId == null) {
          factId = response.question.factSubject;
        }
        currentSession.answers.add(response);
        Fact _fact = FactService().getFactById(factId, value: response.choice);
        addFactToList(_fact, currentSession.facts);
        currentSession.individualFacts.add(_fact);
      }
    }
  }

  void addFactToList(Fact newFact, List<Fact> list) {
    Fact existingFact = list.firstWhere(
      (fact) => fact == newFact,
      orElse: () {
        return null;
      },
    );
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
    Fact existingFact = list.firstWhere(
      (fact) => fact == newFact,
      orElse: () {
        return null;
      },
    );
    if (existingFact != null) {
      print("existing fact subtract: ${existingFact.value}");
      if (newFact.value is int) {
        existingFact.value -= newFact.value;
      } else if (newFact.value is String) {
        existingFact.value = "";
      } else {
        list.removeWhere((fact) => fact.id == newFact.id);
      }
    }
  }

  Session getSession() {
    return currentSession;
  }

  ///searches through every question asked in the given session for one with a matching id
  Question getSessionQuestionById(Session session, String id) {
    return session.questions
        .firstWhere((e) => (e.id == id), orElse: () => null);
  }

  QuestionResponse getQuestionResponse(String questionId) {
    return currentSession.answers
        .firstWhere((e) => (e.question.id == questionId), orElse: () => null);
  }

  Color getCurrentColor() {
    QuestionResponse question = currentSession.answers
        .firstWhere((e) => e.question.id == "personaColor", orElse: () => null);
    //4294967295 is white
    int colorString = question?.choice ?? 4294967295;
    return Color(colorString);
  }

  static Future<List<Rule>> loadRules() async {
    final data = await rootBundle.loadString("assets/export.json");
    List<dynamic> decodedData = json.decode(data)["rules"];
    List<Rule> newRules = new List<Rule>();

    decodedData.forEach((rule) {
      String id = rule["id"].toString() ?? "";
      int priority = rule["priority"] ?? 1;
      var triggerType =
          rule["triggerType"].toString().toEnum(TriggerType.values);

      List<RuleTest> newTests = new List<RuleTest>();
      (rule['tests'] as List)?.forEach((test) {
        RuleTest _newTest = RuleTest(test["factId"].toString(),
            test["operation"].toString().toEnum(Operator.values),
            parameter: test["parameter"]);
        // print("Adding tests to rule: factId ${_newTest.fact}, operation ${_newTest.operation}, parameter ${_newTest.parameter}");
        newTests.add(_newTest);
      });

      RuleAction newAction = RuleAction();
      if (rule["factId"] != null) {
        Fact fact = FactService()
            .getFactById(rule["factId"].toString(), value: rule["factAction"]);
        newAction.fact = fact;
      }
      if (rule["questionId"] != null) {
        newAction.questionId = rule["questionId"].toString();
      }

      Rule newRule = Rule(id, priority, triggerType, newTests, newAction);

      newRules.add(newRule);
    });
    return newRules;
  }

  Future<bool> clearUnfinishedSession() async {
    Map sessionData = {};
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/unfinishedSession.json');
    await file.writeAsString(json.encode(sessionData));
    return true;
  }

  void saveUnfinishedSession(Session session) async {
    Map sessionData = {};
    List<String> questions = new List<String>();
    List<String> processedRules = new List<String>();
    sessionData["id"] = session.id;
    sessionData["answers"] ??= {};
    sessionData["facts"] ??= {};
    session.questions?.forEach((question) {
      questions.add(question.id);
    });
    sessionData["questions"] = questions;
    session.answers?.forEach((answer) {
      print("answers when saving ${answer.choice}");
      sessionData["answers"][answer.question.id] = answer.choice;
    });
    session.processedRules?.forEach((rule) {
      processedRules.add(rule.id);
    });
    sessionData["rules"] = processedRules;
    session.facts?.forEach((fact) {
      sessionData["facts"][fact.id] = fact.value;
    });

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/unfinishedSession.json');
    await file.writeAsString(json.encode(sessionData));
  }

  Future<Session> loadUnfinishedSession() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/unfinishedSession.json');
    String userAnswers = "{}";
    try {
      userAnswers = await file.readAsString();
    } catch (e) {
      print("Couldn't find file, creating new file");
      userAnswers = '{"" : {}}';
    }
    Map userData = json.decode(userAnswers);

    if (userData["id"] != null && userData["id"] != "") {
      Session newSession = Session(userData["id"]);
      List<Question> questions = new List<Question>();
      List<QuestionResponse> answers = new List<QuestionResponse>();
      List<Rule> processedRules = new List<Rule>();
      List<Fact> facts = new List<Fact>();

      (userData["questions"] as List<dynamic>)?.forEach((questionId) {
        questions.add(allQuestions.firstWhere(
          (e) => e.id == questionId.toString(),
          orElse: () => null,
        ));
      });
      (userData["answers"] as Map<dynamic, dynamic>)
          ?.forEach((questionId, response) {
        Question question = allQuestions.firstWhere(
            (e) => e.id == questionId.toString(),
            orElse: () => null);
        answers.add(QuestionResponse(question, response));
      });
      (userData["rules"] as List<dynamic>)?.forEach((ruleId) {
        processedRules.add(allRules.firstWhere(
          (e) => e.id == ruleId.toString(),
          orElse: () => null,
        ));
      });
      (userData["facts"] as Map<dynamic, dynamic>)?.forEach((factId, value) {
        Fact fact = FactService().getFactById(factId.toString(), value: value);
        facts.add(fact);
      });
      newSession.questions = questions;
      newSession.answers = answers;
      newSession.processedRules = processedRules;
      newSession.facts = facts;
      return newSession;
    }
    return new Session(await UtilityFunctions.generateId());
  }
}
