import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:quizhoot/services/classroom_service.dart';
import 'package:quizhoot/services/notification_service.dart';
import 'package:quizhoot/services/user_service.dart';
import '../services/auth_services.dart';
import 'package:http/http.dart' as http;
import 'CNotification.dart';
import 'Folder.dart';
import 'IComponent.dart';
import 'Set.dart';
import 'package:quizhoot/classes/Classroom.dart'; // Ensure consistent case

class User with ChangeNotifier {
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
  List<Classroom> _classrooms = [];
  List<CNotification> _notifications = [];

  List<Classroom> get classrooms => _classrooms;

  User();

  String get firstName => _firstName;
  set firstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
    update({'first_name': _firstName});
  }

  String get lastName => _lastName;
  set lastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
    update({'last_name': _lastName});
  }

  String get username => _username;
  set username(String username) {
    _username = username;
    notifyListeners();
    update({'username': _username});
  }

  int get id => _id;
  set id(int id) {
    _id = id;
    notifyListeners();
  }

  int get mindfulness => _mindfulness;
  set mindfulness(int mindfulness) {
    _mindfulness = mindfulness;
    notifyListeners();
    update({'mindfulness': _mindfulness});
  }

  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
    update({'email': _email});
  }

  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
    update({'password': _password});
  }

  String get phoneNumber => _phoneNumber;
  set phoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
    update({'phone_number': _phoneNumber});
  }

  List<CNotification> get notifications => _notifications;

  AuthService get authService => _authService;

  List<IComponent> get components => _components;

  void addComponent(IComponent component) {
    if (!_components.contains(component)) {
      _components.add(component);
      notifyListeners();
    }
  }

  List<Set> getSets() {
    return _components.whereType<Set>().toList();
  }

  List<Folder> getFolders(){
    return _components.whereType<Folder>().toList();
  }

  void addClassroom(Classroom classroom) {
    if (!_classrooms.contains(classroom)) {
      _classrooms.add(classroom);
      notifyListeners();
    }
  }


  Future<http.Response> register(String firstName, String lastName, String username, String email, String password, String phoneNumber) async {
    final response = await _authService.register(firstName, lastName, username, email, phoneNumber, password);
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<int> login(String username, String password) async {
    final response = await _authService.login(username, password);
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> userCredentials = data['user'];
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
    } else {
      throw Exception("Failed to sign in. Username or Password false!");
    }
  }

  Future<bool> update(Map<String, dynamic> credentials) async {
    final response = await _userService.update(credentials);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }

  Future<bool> delete() async {
    final response = await _userService.deleteUser();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  Future<void> fetchClassrooms() async {
    final response = await ClassroomService.instance.fetchUsersClassrooms();
    _classrooms.clear();
    if (response.statusCode == 200) {

      try {
        List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(json.decode(response.body));


        data.forEach((classroom) {
          addClassroom(Classroom(
            classroom['id'],
            classroom['classroom_name'],
            classroom['size'],
            classroom['creator_username'],
          ));
        });

      } catch (e) {
        throw Exception('Failed to parse data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchSets() async{

    List<Map<String, dynamic>> fetchedSets = await Set.fetchSets();
    _components.clear();
    fetchedSets.forEach((set){
      addComponent(Set(set["id"],set["set_name"], set["size"]));
    });
  }
  Future<void> fetchFolders() async{

    List<Folder> fetchedFolders = await Folder.fetchFolders();
    _components.clear();
    fetchedFolders.forEach((folder){
        addComponent(folder);
      }
    );
  }

  Future<void> fetchNotifications() async {
    final response = await NotificationService.instance
        .fetchUserNotifications();
    if (response.statusCode == 200) {
      _notifications.clear();
      List<dynamic> data = jsonDecode(response.body);

      for (var notification in data) {
        print(notification);
        _notifications.add(
            CNotification(
              notification['id'],
              notification['classroom'],
              notification['message'],
              DateTime.parse(notification['created_at']),
              notification['username'],
              notification['classroomname'],
            )
        );
      }
    }else{
      throw Exception('Failed to fetch notifications. Status: ${response.statusCode}');
    }
  }

  Future<bool> deleteNotification(int notificationID) async{
    final response = await NotificationService.instance.deleteUserNotification(notificationID);
    if(response.statusCode == 200){
      return true;
    }else{
      throw Exception('Failed to delete notification. Status: ${response.statusCode}');
    }
  }


}
