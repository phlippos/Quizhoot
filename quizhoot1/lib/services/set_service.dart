import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/auth_services.dart';

class SetService{
  static final SetService _instance = SetService._internal();

  // Private constructor
  SetService._internal();

  // Static getter for the singleton instance
  static SetService get instance => _instance;
  List<Map<String, dynamic>> data = [];

  Future<http.Response> createSet(String setName,int size) async {

    final response = await http.post(
      Uri.parse('${AuthService.instance.baseurl}/sets/add/'),
      headers: {'Content-Type': 'application/json',
                'Authorization' : 'Token ${await AuthService.instance.getToken()}'},
      body: jsonEncode({
        'set_name' : setName,
        'size' : size
      }),
    );

    return response;
  }

  Future<void> fetchData() async{
    final response = await http.get(
      Uri.parse('${AuthService.instance.baseurl}/sets/list/'),
      headers: {'Content-Type': 'application/json',
        'Authorization' : 'Token ${await AuthService.instance.getToken()}'},
    );
    if(response.statusCode == 200){
      List<dynamic> jsonResponse = json.decode(response.body);
      data= List<Map<String, dynamic>>.from(jsonResponse);
    }else{
      throw Exception('Failed to load data');
    }
  }

}