import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';


class FlashcardService{
  static final FlashcardService _instance = FlashcardService._internal();

  // Private constructor
  FlashcardService._internal();

  // Static getter for the singleton instance
  static FlashcardService get instance => _instance;

  Future<http.Response> createFlashcard(String? term,String? definition) async {
    final response = await http.post(
      Uri.parse('${AuthService.instance.baseurl}/flashcards/add/'),
        headers: {'Content-Type' : 'application/json',
                  'Authorization' : 'Token ${await AuthService.instance.getToken()}'},
        body: jsonEncode({
          'term' : term,
          'definition' : definition
        })
    );
    return response;
  }

}