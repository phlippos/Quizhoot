import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';

import 'auth_services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService extends BaseService {
  static final UserService _instance = UserService._internal();

  UserService._internal();

  static UserService get instance => _instance;

  Future<http.Response> update(Map<String, dynamic> credentials) async {
    try {
      // Send a PUT request with updated user data
      final response = await http.put(
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

  Future<http.Response> deleteUser() async {
    try {
      // Send a DELETE request to delete the user
      final response = await http.delete(
        Uri.parse(getLink('user-delete')!),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${await AuthService.instance.getToken()}',
        },
      );

      return response;
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
