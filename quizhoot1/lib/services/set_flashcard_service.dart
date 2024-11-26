import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';

class Set_FlashcardService{
  final AuthService _authService = AuthService();

  Future<http.Response> createRelationSet_Flashcard(int setID, int flashcardID) async{
    String? token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('${_authService.baseurl}/set_flashcards/add/'),
      headers: {
            'Content-Type' : 'application/json',
            'Authorization': 'Token ${token}'
      },
      body: jsonEncode({
        'set_id': setID,
        'flashcard_id': flashcardID
      })
    );

    if(response.statusCode == 201){
      return response;
    }else{
      throw Exception('Failed to create Set Flashcard relation ${response.statusCode}');
    }
  }
}