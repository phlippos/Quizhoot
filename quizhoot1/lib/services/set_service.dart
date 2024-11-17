import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';

class SetService{
  final AuthService _authService = AuthService();
  final String baseurl = 'http://10.0.2.2:8000/api';

  Future<http.Response> createSet(String setName) async {
    String? token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('${baseurl}/sets/add/'),
      headers: {'Content-Type': 'application/json',
                'Authorization' : 'Token $token'},
      body: jsonEncode({
        'set_name' : setName
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to create set ${response.statusCode}');
    }
  }

}