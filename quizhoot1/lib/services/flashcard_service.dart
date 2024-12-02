import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';


class FlashcardService{
  final AuthService _authService = AuthService.instance;


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