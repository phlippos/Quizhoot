import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:quizhoot/services/user_service.dart';
import '../services/auth_services.dart';
import 'package:http/http.dart' as http;
import 'IComponent.dart';
import 'Set.dart';

class User with ChangeNotifier{
  late String _firstName;
  late String _lastName;
  late String _username;
  late int _id;
  late int _mindfulness;
  late String _email;
  late String _password;
  late String _phoneNumber;
  final AuthService _authService = AuthService.instance;
  final UserService _userService = UserService.instance;
  List<IComponent> _components = [];
  // Constructor


  User();
  // Getter and Setter for firstName
  String get firstName {
    return _firstName;
  }
  set firstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
    update({'first_name':_firstName});
  }

  // Getter and Setter for lastName
  String get lastName {
    return _lastName;
  }
  set lastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
    update({'last_name':_lastName});
  }

  String get username {
    return _username;
  }
  set username(String lastName) {
    _username = lastName;
    notifyListeners();
    update({'username':_username});
  }
  // Getter and Setter for id
  int get id {
    return _id;
  }
  set id(int id) {
    _id = id;
    notifyListeners();
  }

  // Getter and Setter for mindfulness
  int get mindfulness {
    return _mindfulness;
  }
  set mindfulness(int mindfulness) {
    _mindfulness = mindfulness;
    notifyListeners();
    update({'mindfulness':_mindfulness});
  }

  // Getter and Setter for email
  String get email {
    return _email;
  }
  set email(String email) {
    _email = email;
    notifyListeners();
    update({'email':_email});
  }

  // Getter and Setter for password
  String get password {
    return _password;
  }
  set password(String password) {
    _password = password;
    notifyListeners();
    update({'password':_password}); //update async o yüzden başka çözüm bul
  }

  // Getter and Setter for phoneNumber
  String get phoneNumber {
    return _phoneNumber;
  }
  set phoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
    update({'phone_number':_phoneNumber});
  }

  AuthService get authService{
    return _authService;
  }

  List<IComponent> get components{
    return _components;
  }

  void addComponent(IComponent component) {
    if (!_components.contains(component)) {
      _components.add(component);
      notifyListeners();
    }
  }

  List<Set> getSets(){
    return _components.whereType<Set>().toList();
  }

  Future<http.Response> register(String firstName,String lastName,String username,String email,String password,String phoneNumber) async{
    final response = await _authService.register(firstName, lastName, username, email, phoneNumber, password);
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<int> login(String username,String password) async{
    final response = await _authService.login(username, password);
    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      Map<String,dynamic> userCredentials = data['user'];
      _id = userCredentials['id'];
      _firstName = userCredentials['first_name'];
      _lastName = userCredentials['last_name'];
      _email = userCredentials['email'];
      _phoneNumber = userCredentials['phone_number'];
      _mindfulness = userCredentials['mindfulness'];
      _username = username;
      _password = password;
      notifyListeners();
      return response.statusCode;
    }else{
      throw Exception("Failed to sign in. Username or Password false!");
    }
  }

  Future<bool> update(Map<String,dynamic> credentials) async{
    final response = await _userService.update(
        credentials,
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to set mindfulness: ${response.statusCode}');
    }
  }

}
