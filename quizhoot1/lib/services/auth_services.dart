import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';
import 'secure_storage_service.dart';


class AuthService extends BaseService{
  static final AuthService _instance = AuthService._internal();

  // Private constructor
  AuthService._internal();

  // Static getter for the singleton instance
  static AuthService get instance => _instance;

  final SecureStorageService _secureStorageService = SecureStorageService();


  Future<http.Response> register(String firstName, String lastName,String username, String email,String phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse(getLink('user-create')!),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name' : firstName,
        'last_name' : lastName,
        'phone_number' : phoneNumber,
        'username': username,
        'email': email,
        'password': password,
        'mindfulness' : 0
      }),
    );

    return response;
  }

  Future<http.Response> login(String username, String password) async{
    final response = await http.post(
      Uri.parse(getLink('user-login')!),
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



}