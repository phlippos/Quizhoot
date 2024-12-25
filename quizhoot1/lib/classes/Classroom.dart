import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/classroom_service.dart'; // Import the service for API interaction
import 'User.dart';

class Classroom {
  int? _id;
  String _classroomName;
  String? _creatorName;
  int? _size;
  List<Map<String, dynamic>> _members = []; // Make it non-nullable

  List<Map<String, dynamic>> get members => _members;

  set members(List<Map<String, dynamic>> value) {
    _members = value;
  }

  ClassroomService _service = ClassroomService.instance;

  // Modified constructor to initialize members
  Classroom(this._id, this._classroomName, this._size, this._creatorName);


  Classroom.create(this._classroomName); // Initialize for create constructor

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Check for same instance
    if (other is! Classroom) return false; // Check for same type

    return other.id == _id || other.classroomName == _classroomName;
  }

  // Add classroom
  Future<http.Response> add() async {
    final response = await _service.createClassroom(_classroomName);
    if (response.statusCode == 201) {
      _id = Map<String, dynamic>.from(json.decode(response.body))['id'];
      return response;
    } else {
      throw Exception('Failed to create classroom ${response.statusCode}');
    }
  }

  // Update classroom name
  Future<bool> update() async {
    final response = await _service.updateClassroom(_id!, _classroomName);
    if (response.statusCode == 200) {
      return true; // Return successful response
    } else {
      throw Exception('Failed to update classroom. Status: ${response.statusCode}');
    }
  }

  // Delete classroom
  Future<bool> remove() async {
    final response = await _service.deleteClassroom(_id!);
    if (response.statusCode == 204) {
      return true; // Return successful response
    } else {
      throw Exception('Failed to delete classroom. Status: ${response.statusCode}');
    }
  }

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

  Future<void> fetchMembersOfClassroom() async {
    final response = await _service.fetchMembersOfClassroom(_id!);

    if (response.statusCode == 200) {
      _members = List<Map<String,dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load Members');
    }
  }


  bool checkUserExist(int user_id){
    for(Map<String,dynamic> member in _members){
      if(member['user_id'] == user_id){
        return false;
      }
    }
    return true;
  }


  Future<bool> joinClassroom(int user_id) async{
    await fetchMembersOfClassroom();
    if(checkUserExist(user_id)) {
      final response = await _service.joinClassroom(_id!);
      if (response.statusCode == 200) {
        size++;
        return true;
      }else{
        throw Exception("Failed to join classroom ${response.body}");
      }
    }else{
      throw Exception("You are already in classroom !");
    }
  }

}
