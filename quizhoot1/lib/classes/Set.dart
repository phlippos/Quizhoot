import 'dart:convert';

import 'package:quizhoot/classes/IComponent.dart';
import 'package:quizhoot/classes/Quiz.dart';
import 'package:quizhoot/services/set_flashcard_service.dart';
import 'package:quizhoot/services/set_service.dart';
import 'package:http/http.dart' as http;
import 'Flashcard.dart';

class Set implements IComponent{
  late int _id;
  String _name;
  int _size;
  late String creatorName;
  List<IComponent> _components = [];
  Quiz _quiz = Quiz(0.0,0,0,false);
  late int _favFlashcardNum;


  int get favFlashcardNum {
    calculateFavFlashcardNum();
    return _favFlashcardNum;
  }

  static SetService _service = SetService.instance;
  static Set_FlashcardService _set_flashcardService = Set_FlashcardService.instance;
  Set.create(this._name,this._size);
  Set(this._id,this._name,this._size);

  String get name => _name;

  set name(String value) {
    _name = value;
    update();
  }

  int get size => _size;

  set size(int value) {
    _size = value;
    update();
  }

  List<IComponent> get components => _components;

  set components(List<IComponent> value) {
    _components = value;
    size = components.length;
  }

  static SetService get service => _service;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  Quiz get quiz => _quiz;

  set quiz(Quiz value) {
    _quiz = value;
  }

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

  static Future<List<Map<String, dynamic>>> fetchSets() async{
    await _service.fetchData();
    return _service.data;
  }

  bool addComponent(IComponent component){
    if (!_components.contains(component)) {
      _components.add(component);
      return true;
    }
    return false;
  }

  void removeComponent(IComponent component){
    if (_components.contains(component)) {
      _components.remove(component);
    }
  }


  Future<void> fetchFlashcards() async{
    final response = await _set_flashcardService.fetchData(_id);
    if(response.statusCode == 200) {
      List<Map<String, dynamic>> data = List<Map<String,dynamic>>.from(json.decode(response.body));
      _components.clear();
      data.forEach((flashcard){
        addComponent(Flashcard(flashcard['id'],flashcard['term'],flashcard['definition'],flashcard['fav']));
      });
      size = components.length;
    }else{
      throw Exception('Failed to load data');
    }
  }

  static Future<List<Set>> fetchAllSets() async{
    List<Set> sets = [];
    final response = await SetService.instance.fetchAllSets();
    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      for(var set in data){
        Set newSet = Set(
            set['id'],
            set['set_name'],
            set['size']
        );
        newSet.creatorName = set['createdBy'];

        sets.add(newSet);
      }
      return sets;
    }else{
      throw Exception('Failed to fetch all sets!');
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

  @override
  Future<bool> update() async{
    final response = await _service.updateSet(_id, _name, _size);
    if (response.statusCode == 200) {
      return true; // Successfully updated the set
    } else {
      throw Exception('Failed to update set. Status: ${response.statusCode}');
    }
  }

  @override
  Future<bool> remove() async{
    final response = await _service.deleteSet(_id);
    if (response.statusCode == 204) {
      return true; // Successfully deleted the set
    } else {
      throw Exception('Failed to delete set. Status: ${response.statusCode}');
    }
  }

  void calculateFavFlashcardNum(){
    _favFlashcardNum = components.whereType<Flashcard>().where((fc) => fc.favStatus).toList().length;
  }

  List<Flashcard> getFlashcards(){
    return _components.whereType<Flashcard>().toList();
  }

  List<String> getTerms(){
    List<String> terms = [];
    getFlashcards().forEach(
        (flashcard){
          terms.add(flashcard.term);
        }
    );
    return terms;
  }
}