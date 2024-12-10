import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';

import 'auth_services.dart';

class UserService extends BaseService{
  static final UserService _instance = UserService._internal();


  UserService._internal();

  static UserService get instance => _instance;

  Future<http.Response> update(Map<String,dynamic> credentials) async {

    try {
      // Send a POST request with mindfulness data
      final response = await http.post(
        Uri.parse(getLink('user-update')!),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Token ${await AuthService.instance.getToken()}',
        },
        body: jsonEncode(credentials),
      );

      return response;

    } catch (e) {

      throw Exception('An error occurred: $e');
    }
  }

}