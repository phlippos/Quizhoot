import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';


class FlashcardService{
  final AuthService _authService = AuthService();


  Future<http.Response> createFlashcard(String? term,String? definition) async {
    String? token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('${_authService.baseurl}/flashcards/add/'),
        headers: {'Content-Type' : 'application/json',
                  'Authorization' : 'Token ${token}'},
        body: jsonEncode({
          'term' : term,
          'definition' : definition
        })
    );

    if(response.statusCode == 201){
      return response;
    }else{
      throw Exception('Failed to create set ${response.statusCode}');
    }
  }

  Future<http.Response> updateFlashcard(int flashcardID, String term, String definition) async {
    String? token = await _authService.getToken();

    final response = await http.put(
      Uri.parse('${_authService.baseurl}/flashcards/update/$flashcardID/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'term': term,
        'definition': definition,
      }),
    );

    if (response.statusCode == 200) {
      return response; // Return the successful response
    } else {
      throw Exception('Failed to update flashcard. Status: ${response.statusCode}');
    }
  }

  // Add the delete service method
  Future<http.Response> deleteFlashcard(int flashcardID) async {
    String? token = await _authService.getToken(); // Fetch the token for authentication

    // Send a DELETE request to the backend API
    final response = await http.delete(
      Uri.parse('${_authService.baseurl}/flashcards/delete/$flashcardID/'), // API endpoint for deleting flashcard
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token', // Bearer token for authentication
      },
    );

    // If the deletion is successful (HTTP status 204)
    if (response.statusCode == 204) {
      return response; // Return the successful response
    } else {
      throw Exception('Failed to delete flashcard. Status: ${response.statusCode}');
    }
  }

  bool checkExistanceNullFlashcard(List<Map<String,String>>? flashcards){
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
  bool checkDuplication(List<Map<String, String>>? flashcards) {
    if (flashcards == null || flashcards.isEmpty) {
      return true;
    }

    Set<String> terms = Set<String>();

    for (Map<String, String> flashcard in flashcards) {
      String? term = flashcard['term'];

      if (term == null) {
        continue;
      }

      if (terms.contains(term)) {
        return false;
      }
      terms.add(term);
    }

    return true;
  }

  List<int> getNullTermOrDefinitionIndices(List<Map<String, String>> flashcards) {
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

  List<int> getDuplicateIndices(List<Map<String, String>> flashcards) {

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

}