import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';
import 'auth_services.dart';


class FlashcardService extends BaseService{
  static final FlashcardService _instance = FlashcardService._internal();

  // Private constructor
  FlashcardService._internal();

  // Static getter for the singleton instance
  static FlashcardService get instance => _instance;

  Future<http.Response> createFlashcard(String? term,String? definition) async {
    final response = await http.post(
      Uri.parse(getLink('add-flashcard')!),
        headers: {'Content-Type' : 'application/json',
                  'Authorization' : 'Token ${await AuthService.instance.getToken()}'},
        body: jsonEncode({
          'term' : term,
          'definition' : definition
        })
    );
    return response;
  }

  Future<http.Response> updateFlashcard(int flashcardID, String term, String definition) async {

    final response = await http.put(
      Uri.parse(getLink('update-flashcard',{'<int:pk>':'$flashcardID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization' : 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({
        'term': term,
        'definition': definition,
      }),
    );
    return response;
  }

  // Add the delete service method
  Future<http.Response> deleteFlashcard(int flashcardID) async {

    // Send a DELETE request to the backend API
    final response = await http.delete(
      Uri.parse(getLink('delete-flashcard',{'<int:pk>':'$flashcardID'})!), // API endpoint for deleting flashcard
      headers: {
        'Content-Type': 'application/json',
        'Authorization' : 'Token ${await AuthService.instance.getToken()}', // Bearer token for authentication
      },
    );

    return response;
  }

}