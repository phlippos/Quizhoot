import 'dart:convert';

import 'package:quizhoot/classes/IComponent.dart';
import 'package:quizhoot/services/set_flashcard_service.dart';
import 'package:quizhoot/services/set_service.dart';
import 'package:http/http.dart' as http;

import 'Flashcard.dart';
class Set implements IComponent{
  late int _id;
  String _name;
  int _size;
  List<IComponent> _components = [];
  static SetService _service = SetService.instance;
  static Set_FlashcardService _set_flashcardService = Set_FlashcardService.instance;
  Set.create(this._name,this._size);
  Set(this._id,this._name,this._size);

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  int get size => _size;

  set size(int value) {
    _size = value;
  }

  List<IComponent> get components => _components;

  set components(List<IComponent> value) {
    _components = value;
  }

  static SetService get service => _service;

  int get id => _id;

  set id(int value) {
    _id = value;
  } //String _description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Check for same instance
    if (other is! Set) return false; // Check for same type

    return other._name == _name; // Compare the IDs
  }
  @override
  Future<http.Response> add() async{
    final response = await _service.createSet(_name,_size);
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      _id = data["id"];
      return response;
    } else {
      throw Exception('Failed to create set ${response.statusCode}');
    }
  }

  @override
  static Future<List<Map<String, dynamic>>> fetchSets() async{
    final response = await _service.fetchData();
    return _service.data;
  }

  void addComponent(IComponent component) {
    if (!_components.contains(component)) {
      _components.add(component);
    }
  }

  Future<void> fetchFlashcards() async{
    final response = await _set_flashcardService.fetchData(_id);
    if(response.statusCode == 200) {
      List<Map<String, dynamic>> data = List<Map<String,dynamic>>.from(json.decode(response.body));
      data.forEach((flashcard){
        addComponent(Flashcard(flashcard['id'],flashcard['term'],flashcard['definition'],flashcard['fav']));
      });
    }else{
      throw Exception('Failed to load data');
    }
  }


  Future<void> createRelationSet_Flashcard(Flashcard flashcard) async{
    final response = await _set_flashcardService.createRelationSet_Flashcard(_id, flashcard.id);
    if(response.statusCode == 201){
      return;
    }else{
      throw Exception('Failed to create Set Flashcard relation ${response.statusCode}');
    }
  }

}