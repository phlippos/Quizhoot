import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizhoot/services/base_service.dart';
import 'package:quizhoot/services/auth_services.dart';

/// A service for handling Folder-related API calls.
class FolderService extends BaseService {
  // Singleton instance
  static final FolderService _instance = FolderService._internal();
  FolderService._internal();
  static FolderService get instance => _instance;

  /// Creates a new folder for the authenticated user.
  /// Expects a POST endpoint like POST /folders/create/.
  /// Example body: { "name": "My Folder" }
  Future<http.Response> createFolder(String name) async {
    final response = await http.post(
      Uri.parse(getLink('create-folder')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({
        'folder_name': name,
      }),
    );
    return response;
  }

  /// Lists all folders belonging to the authenticated user.
  /// Expects a GET endpoint like GET /folders/list/.
  Future<http.Response> listFolders() async {
    final response = await http.get(
      Uri.parse(getLink('list-folders')!),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  /// Renames a folder by ID.
  /// Expects a PUT endpoint like PUT /folders/<folder_id>/rename/.
  /// Body: { "name": "New Folder Name" }
  Future<http.Response> renameFolder(int folderID, String newName) async {
    final response = await http.put(
      Uri.parse(
        getLink('rename-folder', {'<int:pk>': '$folderID'})!,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'folder_name': newName}),
    );
    return response;
  }

  /// Deletes a folder by ID.
  /// Expects a DELETE endpoint like DELETE /folders/<folder_id>/.
  Future<http.Response> deleteFolder(int folderID) async {
    final response = await http.delete(
      Uri.parse(
        getLink('folder-detail', {'<int:pk>': '$folderID'})!,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  /// Adds an existing set to a folder by ID.
  /// Expects a POST endpoint like POST /folders/<folder_id>/add_set/.
  /// Body: { "set_id": <some_set_id> }
  Future<http.Response> addSetToFolder(int folderID, int setID) async {
    final response = await http.post(
      Uri.parse(
        getLink('add-set-to-folder', {'<int:pk>': '$folderID'})!,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
      body: jsonEncode({'set_id': setID}),
    );
    return response;
  }

  /// Removes a set from a folder by ID.
  /// Expects a DELETE endpoint like DELETE /folders/<folder_id>/remove_set/<set_id>/.
  Future<http.Response> removeSetFromFolder(int folderID, int setID) async {
    final response = await http.delete(
      Uri.parse(
        getLink('remove-set-from-folder', {
          '<int:pk>': '$folderID',
          '<int:set_id>': '$setID',
        })!,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }

  /// Lists all sets belonging to a particular folder.
  /// Expects a GET endpoint like GET /folders/<folder_id>/sets/.
  Future<http.Response> listSetsInFolder(int folderID) async {
    final response = await http.get(
      Uri.parse(
        getLink('list-sets-in-folder', {'<int:pk>': '$folderID'})!,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${await AuthService.instance.getToken()}',
      },
    );
    return response;
  }
}