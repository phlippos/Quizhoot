import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';

class Set_FlashcardService{
  final AuthService _authService = AuthService();
  List<Map<String,dynamic>> data = [];


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

  Future<void> fetchData(int setID) async{
    String? token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${_authService.baseurl}/set_flashcards/list/${setID}/'),
      headers : {'Content-Type' : 'application/json',
        'Authorization' : 'Token ${token}'
      }
    );
    if(response.statusCode == 200){
      List<dynamic> jsonResponse = json.decode(response.body);
      data= List<Map<String, dynamic>>.from(jsonResponse);
    }else{
      throw Exception('Failed to load data');
    }
  }

  Future<http.Response> updateFavStatus(int flashcardID,bool fav) async{
    String? token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${_authService.baseurl}/set_flashcards/update/${flashcardID}/'),
      headers: {'Content-Type' : 'application/json',
        'Authorization' : 'Token ${token}'
      },
      body: jsonEncode({
        'fav' : fav
      })
    );
    if(response.statusCode == 200){
      return response;
    }else{
      throw Exception('Failed to update Fav ${response.statusCode}');
    }
  }
}