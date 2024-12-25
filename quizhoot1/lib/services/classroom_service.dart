import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart'; // Import the base service class
import 'auth_services.dart';

class ClassroomService extends BaseService {
  static final ClassroomService _instance = ClassroomService._internal();

  // Private constructor
  ClassroomService._internal();

  // Static getter for singleton instance
  static ClassroomService get instance => _instance;

  // Create a new classroom
  Future<http.Response> createClassroom(String classroomName) async {
    final response = await http.post(
      Uri.parse(getLink('classroom-add')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'classroom_name': classroomName}),
    );
    return response;
  }

  // Update an existing classroom
  Future<http.Response> updateClassroom(int classroomID, String classroomName) async {
    final response = await http.put(
      Uri.parse(getLink('classroom-update', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'classroom_name': classroomName}),
    );
    return response;
  }

  // Delete a classroom
  Future<http.Response> deleteClassroom(int classroomID) async {
    final response = await http.delete(
      Uri.parse(getLink('classroom-delete', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  // Get a list of classrooms for the current user
  Future<http.Response> getClassrooms() async {
    final response = await http.get(
      Uri.parse(getLink('classroom-list')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  Future<http.Response> fetchUsersClassrooms() async {
    final response = await http.get(
      Uri.parse(getLink('classroom-user-list')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  Future<http.Response> fetchMembersOfClassroom(int classroomID) async{
    final response = await http.get(
      Uri.parse(getLink('classroom-members-list',{'<int:classroom_id>':'$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    print(response.statusCode);
    return response;
  }

  Future<http.Response> joinClassroom(int classroomID) async{
    print(getLink('classroom-user-add-user'));
    final response = await http.post(

      Uri.parse(getLink('classroom-user-add-user')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body:
        jsonEncode({
          'classroom_id': classroomID
        })
    );
    return response;
  }

  Future<http.Response> leaveClassroom(int classroomID) async {
    final response = await http.delete(
      Uri.parse(getLink('classroom-remove-user', {'<int:classroom_id>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  // Add a set to a classroom
  Future<http.Response> addSetToClassroom(int classroomID, int setID) async {
    final response = await http.post(
      Uri.parse(getLink('classroom-add-set', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'set_id': setID}),
    );
    return response;
  }

  // Remove a set from a classroom
  Future<http.Response> removeSetFromClassroom(int classroomID, int setID) async {
    final response = await http.delete(
      Uri.parse(getLink('classroom-remove-set', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'set_id': setID}),
    );
    return response;
  }

  // Add a folder to a classroom
  Future<http.Response> addFolderToClassroom(int classroomID, int folderID) async {
    final response = await http.post(
      Uri.parse(getLink('classroom-add-folder', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'folder_id': folderID}),
    );
    return response;
  }

  // Remove a folder from a classroom
  Future<http.Response> removeFolderFromClassroom(int classroomID, int folderID) async {
    final response = await http.delete(
      Uri.parse(getLink('classroom-remove-folder', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'folder_id': folderID}),
    );
    return response;
  }

  // List all sets and folders in a classroom
  Future<http.Response> listSetsAndFoldersInClassroom(int classroomID) async {
    final response = await http.get(
      Uri.parse(getLink('classroom-list-sets-folders', {'<int:pk>': '$classroomID'})!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

}