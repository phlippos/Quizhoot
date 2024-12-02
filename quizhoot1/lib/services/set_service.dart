import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';

class SetService{
  final AuthService _authService = AuthService.instance;
  List<Map<String, dynamic>> data = [];

  Future<http.Response> createSet(String setName,int size) async {
    String? token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('${_authService.baseurl}/sets/add/'),
      headers: {'Content-Type': 'application/json',
                'Authorization' : 'Token ${token}'},
      body: jsonEncode({
        'set_name' : setName,
        'size' : size
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to create set ${response.statusCode}');
    }
  }

  Future<void> fetchData() async{
    String? token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${_authService.baseurl}/sets/list/'),
      headers: {'Content-Type': 'application/json',
        'Authorization' : 'Token ${token}'},
    );
    if(response.statusCode == 200){
      List<dynamic> jsonResponse = json.decode(response.body);
      data= List<Map<String, dynamic>>.from(jsonResponse);
    }else{
      throw Exception('Failed to load data');
    }
  }

}