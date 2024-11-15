import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';
class AuthService {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final String baseurl = 'http://10.0.2.2:8000/api';

  Future<http.Response> register(String firstName, String lastName,String username, String email,String phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse('${baseurl}/users/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name' : firstName,
        'last_name' : lastName,
        'phone_number' : phoneNumber,
        'username': username,
        'email': email,
        'password': password,
        'mindfulness' : 1
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<http.Response> login(String username, String password) async{
    final response = await http.post(
      Uri.parse('${baseurl}/login/'),
      headers: {'Content-Type' : 'application/json'},
      body: jsonEncode({
        'username' : username,
        'password' : password
      })
    );
    if(response.statusCode == 200){
      var data = json.decode(response.body);
      String token = data['access_token'];
      await _secureStorageService.saveToken(token);
      return response;
    }else{
      throw Exception('Failed to login ${response.statusCode}');
    }
  }

  Future<String?> getToken() async {
    return await _secureStorageService.getToken();
  }

  Future<void> logout() async {
    await _secureStorageService.deleteToken();
  }

  Future<http.Response> setMindfulness(int? mindfulness) async{
    String? token = await _secureStorageService.getToken();
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
        body: jsonEncode({'mindfulness': mindfulness}),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        return response; // Return the response if successful
      } else {
        throw Exception('Failed to set mindfulness: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any other errors that might occur (e.g., network issues)
      throw Exception('An error occurred: $e');
    }
  }

}