import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';
import 'auth_services.dart';

class Set_FlashcardService extends BaseService{
  static final Set_FlashcardService _instance = Set_FlashcardService._internal();

  // Private constructor
  Set_FlashcardService._internal();

  // Static getter for the singleton instance
  static Set_FlashcardService get instance => _instance;

  Future<http.Response> createRelationSet_Flashcard(int setID, int? flashcardID) async{
    final response = await http.post(
      Uri.parse(getLink('add-set-flashcard')!),
      headers: {
            'Content-Type' : 'application/json',
            'Authorization': 'Token ${await AuthService.instance.getToken()}'
      },
      body: jsonEncode({
        'set_id': setID,
        'flashcard_id': flashcardID
      })
    );

   return response;
  }

  Future<http.Response> fetchData(int setID) async{
    final response = await http.get(
      Uri.parse(getLink('list-set-flashcards',{'<int:set_id>':'$setID'})!),
      headers : {'Content-Type' : 'application/json',
        'Authorization' : 'Token ${await AuthService.instance.getToken()}'
      }
    );
    return response;
  }

  Future<http.Response> updateFavStatus(int flashcardID,int set_id,bool fav) async{
    final response = await http.put(
      Uri.parse(getLink('update-set-flashcard',{'<int:flashcard_id>':'$flashcardID','<int:set_id>':'$set_id'})!),
      headers: {'Content-Type' : 'application/json',
        'Authorization' : 'Token ${await AuthService.instance.getToken()}'
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