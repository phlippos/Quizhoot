import 'dart:convert';

import 'package:quizhoot/classes/IComponent.dart';
import 'package:quizhoot/services/flashcard_service.dart';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/set_flashcard_service.dart';

class Flashcard implements IComponent {
  int? _id;
  String _term;
  String _definition;
  bool _favStatus = false;
  FlashcardService _service = FlashcardService.instance;
  Set_FlashcardService _set_flashcardService = Set_FlashcardService.instance;

  Flashcard(this._id, this._term, this._definition, this._favStatus);

  Flashcard.create(this._term, this._definition);

  int? get id => _id;

  set id(int? value) {
    _id = value;
  }

  String get term => _term;

  set term(String value) {
    _term = value;
  }

  String get definition => _definition;

  set definition(String value) {
    _definition = value;
  }

  bool get favStatus => _favStatus;

  set favStatus(bool value) {
    _favStatus = value;
  }

  FlashcardService get service => _service;

  set service(FlashcardService value) {
    _service = value;
  }

  Set_FlashcardService get set_flashcardService => _set_flashcardService;

  set set_flashcardService(Set_FlashcardService value) {
    _set_flashcardService = value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Check for same instance
    if (other is! Flashcard) return false; // Check for same type

    return other._id == _id || other.term == _term;
  }

  @override
  Future<http.Response> add() async {
    final response = await _service.createFlashcard(_term, _definition);
    if (response.statusCode == 201) {
      _id = Map<String, dynamic>.from(json.decode(response.body))['id'];
      return response;
    } else {
      throw Exception('Failed to create set ${response.statusCode}');
    }
  }

  Future<http.Response> updateFavStatus(int set_id) async {
    final response = await _set_flashcardService.updateFavStatus(
        _id!,set_id, _favStatus);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Flashcard fav status not updated");
    }
  }

  static bool checkExistanceNullFlashcard(List<Map<String,String>>? flashcards){
    if(flashcards == null){
      return false;
    }
    for(Map<String,String> m in flashcards){
      if(m['term']!.isEmpty || m['definition']!.isEmpty){
        return false;
      }
    }
    return true;
  }

  static bool checkDuplication(List<Map<String, String>>? flashcards) {
    if (flashcards == null || flashcards.isEmpty) {
      return true;
    }
    Set<String> terms = Set<String>();
    Set<String> definitions = Set<String>();
    for (Map<String, String> flashcard in flashcards) {
      String? term = flashcard['term'];
      String? definition = flashcard['definition'];
      if (term == null) {
        continue;
      }
      if (definition == null){
        continue;
      }
      if (terms.contains(term) || definitions.contains(definition)) {
        return false;
      }
      terms.add(term);
      definitions.add(definition);
    }
    return true;
  }

  static List<int> getNullTermOrDefinitionIndices(List<Map<String, String>> flashcards) {
    List<int> nullIndices = [];
    for (int i = 0; i < flashcards.length; i++) {
      String? term = flashcards[i]['term'];
      String? definition = flashcards[i]['definition'];

      if (term == null || definition == null) {
        nullIndices.add(i);
      }
    }
    return nullIndices;
  }

  static List<int> getDuplicateIndices(List<Map<String, String>> flashcards) {
    Map<String, List<int>> termIndices = {};
    for (int i = 0; i < flashcards.length; i++) {
      String? term = flashcards[i]['term'];

      if (term == null) {
        continue;
      }
      if (termIndices.containsKey(term)) {
        termIndices[term]!.add(i);
      } else {
        termIndices[term] = [i];
      }
    }

    List<int> duplicateIndices = [];
    termIndices.forEach((term, indices) {
      if (indices.length > 1) {
        duplicateIndices.addAll(indices);
      }
    });
    return duplicateIndices;
  }

  @override
  Future<bool> update() async{
    final response = await _service.updateFlashcard(_id!, _term, _definition);
    if (response.statusCode == 200) {
      return true; // Return the successful response
    } else {
      throw Exception('Failed to update flashcard. Status: ${response.statusCode}');
    }
  }

  @override
  Future<bool> remove() async{
    final response = await _service.deleteFlashcard(_id!);
    // If the deletion is successful (HTTP status 204)
    if (response.statusCode == 204) {
      return true; // Return the successful response
    } else {
      throw Exception('Failed to delete flashcard. Status: ${response.statusCode}');
    }
  }
}