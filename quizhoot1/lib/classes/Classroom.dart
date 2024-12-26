import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/classes/CNotification.dart';
import 'package:quizhoot/services/classroom_service.dart';

import '../services/notification_service.dart';
import 'Folder.dart';
import 'IComponent.dart'; // Import the service for API interaction
import 'Set.dart';
import 'User.dart';

class Classroom {
  int? _id;
  String _classroomName;
  String? _creatorName;
  int? _size;
  List<Map<String, dynamic>> _members = [];
  List<IComponent> _components = [];
  ClassroomService _service = ClassroomService.instance;
  List<CNotification> _notifications = [];

 // Constructor to initialize the classroom
  Classroom(this._id, this._classroomName, this._size, this._creatorName);

  // Create constructor
  Classroom.create(this._classroomName);

  // Getters and Setters
  int? get id => _id;
  set id(int? value) {
    _id = value;
  }

  String get classroomName => _classroomName;
  set classroomName(String value) {
    _classroomName = value;
    update();
  }

  ClassroomService get service => _service;
  set service(ClassroomService value) {
    _service = value;
  }

  int get size => _size!;
  set size(int value) {
    _size = value;
  }

  String get creatorName => _creatorName!;
  set creatorName(String value) {
    _creatorName = value;
  }

  List<Map<String, dynamic>> get members => _members;
  set members(List<Map<String, dynamic>> value) {
    _members = value;
  }

  List<IComponent> get components => _components;

  List<CNotification> getCNotifications(){
    return _notifications;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Classroom) return false;

    return other.id == _id || other.classroomName == _classroomName;
  }

  // Add classroom
  Future<http.Response> add() async {
    final response = await _service.createClassroom(_classroomName);
    if (response.statusCode == 201) {
      _id = Map<String, dynamic>.from(json.decode(response.body))['id'];
      return response;
    } else {
      throw Exception('Failed to create classroom. Status: ${response.statusCode}');
    }
  }

  // Update classroom name
  Future<bool> update() async {
    final response = await _service.updateClassroom(_id!, _classroomName);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update classroom. Status: ${response.statusCode}');
    }
  }

  // Delete classroom
  Future<bool> remove() async {
    final response = await _service.deleteClassroom(_id!);
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete classroom. Status: ${response.statusCode}');
    }
  }

  // Get all classrooms
  static Future<List<Classroom>> getAllClassrooms() async {
    List<Classroom> classrooms = [];
    final response = await ClassroomService.instance.getClassrooms();
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      for (var classroom in data) {
        classrooms.add(Classroom(
          classroom['id'],
          classroom['classroom_name'],
          classroom['size'],
          classroom['creator_username'],
        ));
      }
      return classrooms;
    } else {
      throw Exception('Failed to load classrooms');
    }
  }

  // Fetch members of the classroom
  Future<void> fetchMembersOfClassroom() async {
    final response = await _service.fetchMembersOfClassroom(_id!);
    _members.clear();
    if (response.statusCode == 200) {
      _members = List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load members');
    }
  }

  // Check if user exists in classroom
  bool checkUserExist(int userId) {
    for (Map<String, dynamic> member in _members) {
      if (member['user_id'] == userId) {
        return true;
      }
    }
    return false;
  }

  // Join classroom
  Future<bool> joinClassroom(User user) async {
    await fetchMembersOfClassroom();
    if (!checkUserExist(user.id)) {
      final response = await _service.joinClassroom(_id!);
      if (response.statusCode == 200) {
        size++;
        sendNotification("${user.username} has joined to classroom. Say Welcome :)");
        return true;
      } else {
        throw Exception('Failed to join classroom. Status: ${response.body}');
      }
    } else {
      throw Exception('You are already in the classroom!');
    }
  }

  Future<bool> leaveClassroom(User user) async{
    final response = await _service.leaveClassroom(_id!);
    if(response.statusCode == 204){
      sendNotification("${user.username} left the classroom. BYE BITCH!!!");
      return true;
    }else{
      throw Exception('failed to leave classroom');
    }
  }

  Future<bool> addSet(Set set) async {
    final response = await _service.addSetToClassroom(_id!, set.id);
    if (response.statusCode == 200) {
      sendNotification("NEW SET IS ADDED TO THE CLASSROOM. LEARN BIIIITCH!!!");
      return true;
    } else {
      throw Exception('Failed to add set to classroom. Status: ${response.body}');
    }
  }

  Future<bool> removeSet(Set set) async {
    final response = await _service.removeSetFromClassroom(_id!, set.id);
    if (response.statusCode == 200) {
      sendNotification("ONE SET IS REMOVED FROM THE CLASSROOM. :(");
      return true;
    } else {
      throw Exception('Failed to remove set from classroom. Status: ${response.body}');
    }
  }

  Future<bool> addFolder(int folderId) async {
    final response = await _service.addFolderToClassroom(_id!, folderId);
    if (response.statusCode == 200) {
      sendNotification("NEW FOLDER CREATED");
      return true;
    } else {
      throw Exception('Failed to add folder to classroom. Status: ${response.body}');
    }
  }

  Future<bool> removeFolder(int folderId) async {
    final response = await _service.removeFolderFromClassroom(_id!, folderId);
    if (response.statusCode == 200) {
      sendNotification("ONE FOLDER REMOVED");
      return true;
    } else {
      throw Exception('Failed to remove folder from classroom. Status: ${response.body}');
    }
  }

  void addComponent(IComponent component) {
    if (!_components.contains(component)) {
      _components.add(component);
    } else {
      throw Exception('Component already exists in the classroom.');
    }
  }

  Future<void> listSetsAndFolders() async {
    final response = await _service.listSetsAndFoldersInClassroom(_id!);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> sets = data['sets'];
      List<dynamic> folders = data['folders'];

      _components.clear();

      for (var set in sets) {
        _components.add(Set(set['id'], set['set_name'],set['size']));
      }

      for (var folder in folders) {
        _components.add(Folder(folder['id'], folder['folder_name'],folder['size']));
      }
    } else {
      throw Exception('Failed to list sets and folders in classroom. Status: ${response.body}');
    }
  }

  Future<bool> fetchNotifications() async{
    final response = await NotificationService.instance.fetchNotifications(_id!);
    if(response.statusCode == 200){
      _notifications.clear();
      List<dynamic> data  = jsonDecode(response.body);

      for(var notification in data){
        print(notification);
        _notifications.add(
            CNotification(
                notification['id'],
                _id!,
                notification['message'],
                DateTime.parse(notification['created_at']),
                notification['username'],
                notification['classroomname'],
            )
        );
      }
      return true;
    }else{
      throw Exception('Failed to fetch notifications. Status: ${response.statusCode}');
    }
  }
  Future<void> sendNotification(String message) async{
    CNotification notification = CNotification.create(_id!,message);
    await notification.add();
  }
}
