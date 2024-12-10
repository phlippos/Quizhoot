import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/classes/Flashcard.dart';
import 'package:quizhoot/services/base_service.dart';
import 'auth_services.dart';



class QuizService extends BaseService{
  static final QuizService _instance = QuizService._internal();

  // Private constructor
  QuizService._internal();

  // Static getter for the singleton instance
  static QuizService get instance => _instance;

  List<Map<String, dynamic>> generateQuestionListMC(List<Flashcard> flashcards, {bool onlyFavorites = false}) {

    List<Flashcard> filteredFlashcards = onlyFavorites ? flashcards.where((fc) => fc.favStatus).toList() : flashcards;
    List definitions = filteredFlashcards.map((fc) => fc.definition).toList();
    List<Map<String, dynamic>> questions = [];

    for (var flashcard in filteredFlashcards) {
      String correctDefinition = flashcard.definition;
      List incorrectDefinitions = definitions.where((def) => def != correctDefinition).toList();
      incorrectDefinitions.shuffle();

      List<String> options = [correctDefinition, incorrectDefinitions[0], incorrectDefinitions[1], incorrectDefinitions[2]];
      options.shuffle();

      questions.add({
        'question': flashcard.term,
        'options': options,
        'answer': correctDefinition,
      });
    }
    return questions;
  }

  Future<http.Response> add_quiz(int set_id,double result,int correct_answer,int incorrect_answer, bool type) async{
    final response = await http.post(
      Uri.parse(getLink('add-quiz',{'<int:set_id>':'$set_id'})!),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
      body: jsonEncode({
        'result': result,
        'correct_answer': correct_answer,
        'incorrect_answer': incorrect_answer,
        'quiz_type': type
      }),
    );
    return response;
  }

  int calculateCorrectAnswerNum(List<String> answerKey, List<String> answers){
    int correctAnswerNum = 0;
    for(int i = 0;i < answers.length; i++){
      if(answers[i] == answerKey[i]){
        correctAnswerNum++;
      }
    }
    return correctAnswerNum;
  }

  int calculateIncorrectAnswerNum(int correctAnswerNum, int questionNum){
    return questionNum - correctAnswerNum;
  }

  double calculateResult(int correctAnswerNum, int questionNum){
    return (correctAnswerNum/questionNum)*100;
  }

}