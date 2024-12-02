import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static final UserService _instance = UserService._internal();


  UserService._internal();

  static UserService get instance => _instance;

  Future<http.Response> update(Map<String,dynamic> credentials, String? token,
      String baseurl) async {

    if (token == null) {
      throw Exception('No token found, user might not be logged in.');
    }
    try {
      // Send a POST request with mindfulness data
      final response = await http.post(
        Uri.parse('${baseurl}/update-mindfulness/'),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(credentials),
      );

      return response;

    } catch (e) {

      throw Exception('An error occurred: $e');
    }
  }

}