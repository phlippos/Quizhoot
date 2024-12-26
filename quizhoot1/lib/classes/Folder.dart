import 'dart:convert';
import 'package:http/http.dart' as http;

// Assuming you have these files already, similar to your FlashcardService:
import 'package:quizhoot/services/folder_service.dart';
import 'package:quizhoot/classes/IComponent.dart';
import 'package:quizhoot/classes/Set.dart'; // or FlashcardSet, etc.

class Folder implements IComponent {
  int? _id;
  String _name;
  int? _size;
  /// A folder can contain multiple sets. You may store only IDs or entire Set objects.
  final List<Set> _sets = [];


  /// Reference to a FolderService (singleton, or create your own instance).
  FolderService _service = FolderService.instance;

  // Constructors
  Folder(this._id, this._name,this._size);
  Folder.create(this._name);

  // Getters & Setters
  int? get id => _id;
  set id(int? value) => _id = value;

  String get name => _name;
  set name(String value){
    _name = value;
    update();
  }

  int get size => _size!;

  set size(int value) {
    _size = value;
  }
  List<Set> get sets => _sets;

  FolderService get service => _service;

  // ---------------------------------------------------------------------------
  // 1) Create a folder (Server-side)
  //    Equivalent to "add()" in IComponent
  // ---------------------------------------------------------------------------
  @override
  Future<http.Response> add() async {
    final response = await _service.createFolder(_name);
    if (response.statusCode == 201) {
      // The response is expected to return the newly created folder ID, etc.
      final Map<String, dynamic> data = jsonDecode(response.body);
      _id = data['id'];
      _size = data['sets'].length;
      return response;
    } else {
      throw Exception('Failed to create folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 2) Update the folder’s name (You can also call this "updateName")
  //    Using the same "update()" method from IComponent style
  // ---------------------------------------------------------------------------
  @override
  Future<bool> update() async {
    if (_id == null) {
      throw Exception("Cannot update a folder without an ID");
    }
    final response = await _service.renameFolder(_id!, _name);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 3) Delete a folder
  // ---------------------------------------------------------------------------
  @override
  Future<bool> remove() async {
    if (_id == null) {
      throw Exception("Cannot delete a folder without an ID");
    }
    final response = await _service.deleteFolder(_id!);
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 4) List all folders for the logged-in user
  //    Typically a static method (like Flashcard.fetchSets).
  // ---------------------------------------------------------------------------
  static Future<List<Folder>> fetchFolders() async {

    final response = await FolderService.instance.listFolders();
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convert JSON list into Folder objects
      return data.map((folderJson) {
        return Folder(
          folderJson['id'],
          folderJson['folder_name'],
          folderJson['sets'].length
        );

      }).toList();

    } else {
      throw Exception(
          'Failed to fetch folders. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 5) Add a set to this folder
  //    Depending on your API, you might pass folder_id and set_id to an endpoint
  // ---------------------------------------------------------------------------
  Future<http.Response> addSetToFolder(Set set) async {
    if (_id == null) {
      throw Exception("Folder ID is null. Cannot add a set to a folder without ID.");
    }
    final response = await _service.addSetToFolder(_id!, set.id!);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _sets.add(set);
      return response;
    } else {
      throw Exception(
          'Failed to add set to folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 6) Remove a set from this folder
  // ---------------------------------------------------------------------------
  Future<http.Response> removeSetFromFolder(Set set) async {
    if (_id == null) {
      throw Exception("Folder ID is null. Cannot remove a set without folder ID.");
    }
    final response = await _service.removeSetFromFolder(_id!, set.id!);
    if (response.statusCode == 200 || response.statusCode == 204) {
      _sets.remove(set);
      return response;
    } else {
      throw Exception(
          'Failed to remove set from folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 7) List all sets within this folder
  //    This could also be a static method, but here we do it as an instance method.
  // ---------------------------------------------------------------------------
  Future<List<Set>> fetchSetsInFolder() async {
    if (_id == null) {
      throw Exception("Folder ID is null. Cannot fetch sets for a folder without ID.");
    }
    final response = await _service.listSetsInFolder(_id!);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convert JSON to your local Set objects
      _sets.clear();
      data.forEach((setJson) {
        _sets.add(
          Set(
            setJson['id'],
            setJson['set_name'],
            setJson['size'] ?? 0,
          ),
        );
      });
      return _sets;
    } else {
      throw Exception(
          'Failed to fetch sets in folder. Status: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // Equality & toString overrides (optional)
  // ---------------------------------------------------------------------------
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Folder) return false;
    return other._id == _id || other._name == _name;
  }

  @override
  int get hashCode => _id.hashCode ^ _name.hashCode;

  @override
  String toString() => 'Folder(id: $_id, name: $_name)';
}