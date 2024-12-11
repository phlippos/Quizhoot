import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';



class QuizService{
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> generateQuestions(List<Map<String,dynamic>>? flashcards, {bool onlyFavorites = false}) {
    if(flashcards == null){
      return [];
    }
    List<Map<String,dynamic>> filteredFlashcards = onlyFavorites ? flashcards.where((fc) => fc['fav']).toList() : flashcards;

    List definitions = filteredFlashcards.map((fc) => fc['definition']).toList();
    List<Map<String, dynamic>> questions = [];

    for (var flashcard in filteredFlashcards) {
      String correctDefinition = flashcard['definition'];
      List incorrectDefinitions = definitions.where((def) => def != correctDefinition).toList();
      incorrectDefinitions.shuffle();

      List<String> options = [correctDefinition, incorrectDefinitions[0], incorrectDefinitions[1], incorrectDefinitions[2]];
      options.shuffle();

      questions.add({
        'question': flashcard['term'],
        'options': options,
        'answer': correctDefinition,
      });
    }

    return questions;
  }


}