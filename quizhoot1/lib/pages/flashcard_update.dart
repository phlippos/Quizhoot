import 'package:flutter/material.dart';
import 'package:quizhoot/classes/Flashcard.dart';

import '../classes/Set.dart';

class UpdateFlashcardPage extends StatefulWidget {


  const UpdateFlashcardPage({
    super.key,
  });

  @override
  _UpdateFlashcardPageState createState() => _UpdateFlashcardPageState();
}

class _UpdateFlashcardPageState extends State<UpdateFlashcardPage> {
  late Set _set;
  late TextEditingController _setNameController;
  late List<Map<String, TextEditingController>>
  flashcardControllers; // Use controllers for term and definition
  bool _isLoaded = false;
  late List<Flashcard> _oldComponents;
  late List<Flashcard> _newComponents;
  bool _onlyOnce = false;
  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    if(_onlyOnce == false) {
      _set = ModalRoute
          .of(context)
          ?.settings
          .arguments as Set;
      _setNameController = TextEditingController(text: _set.name);
      _loadFlashcards();
    }
  }

  Future<void> _loadFlashcards() async {
    await _set.fetchFlashcards();
    flashcardControllers = _set.components.whereType<Flashcard>().map((flashcard) {
      return {
        'term': TextEditingController(text: flashcard.term),
        'definition': TextEditingController(text: flashcard.definition),
      };
    }).toList();
    setState(() {
      _oldComponents = _set.components.whereType<Flashcard>().toList();
      _newComponents = _set.components.whereType<Flashcard>().toList();
      _isLoaded = true;
      _onlyOnce = true;
    });
  }

  @override
  void dispose() {
    _setNameController.dispose();
    for (var controllerPair in flashcardControllers) {
      controllerPair['term']!.dispose();
      controllerPair['definition']!.dispose();
    }
    super.dispose();
  }

  void addFlashcard() {
    setState(() {
      flashcardControllers.add({
        'term': TextEditingController(),
        'definition': TextEditingController(),
      });
      _newComponents.add(Flashcard.create("",""));
    });
  }

  void deleteFlashcard(int index) {
    setState(() {
      flashcardControllers[index]['term']!.dispose();
      flashcardControllers[index]['definition']!.dispose();
      flashcardControllers.removeAt(index);
    });
    _newComponents.removeAt(index);
  }

  Future<void> _updateSet() async {

    if (_setNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the set.')),
      );
      return;
    }

    for(int i = 0; i < flashcardControllers.length; i++){
      Flashcard flashcard = _newComponents.elementAt(i) as Flashcard;
      flashcard.term = flashcardControllers.elementAt(i)['term']!.text;
      flashcard.definition = flashcardControllers.elementAt(i)['definition']!.text;
    }

    if (_newComponents
        .any((card) => card.term == "" || card.definition == "")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All cards must have both term and definition.')),
      );
      return;
    }

    List<Flashcard> deletedComponents = _oldComponents.where((oldComponent) {
      return !_newComponents.any((newComponent) => newComponent.id == oldComponent.id);
    }).toList();

    List<Flashcard> newFlashcards = _newComponents.where((newComponent) {
      return newComponent.id == null;
    }).toList();

    List<Flashcard> updatedComponents = _newComponents.where((newComponent) {
      if(newComponent.id != null) {
        Flashcard? matchingOldComponent = _oldComponents.firstWhere(
              (oldComponent) => oldComponent.id == newComponent.id,
        );
          return matchingOldComponent != null;
      }else {
        return false;
      }
    }).toList();

    for (Flashcard deletedComponent in deletedComponents) {
      await deletedComponent.remove();
    }

    for (Flashcard newFlashcard in newFlashcards) {
      await newFlashcard.add();
      await _set.createRelationSet_Flashcard(newFlashcard);
    }

    for (Flashcard updatedComponent in updatedComponents) {
      await updatedComponent.update();
    }

    _set.components = _newComponents;
    _set.name = _setNameController.text;
    _set.update();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set updated successfully!')),
    );

    Navigator.pushNamed(context, '/setView');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text(
          'Update Flashcard',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: Colors.green,
            onPressed: _updateSet,
          ),
        ],
      ),
      body: _isLoaded ?
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(

                controller: _setNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a title',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: flashcardControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8.0,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Card ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter term',
                                ),
                                controller: flashcardControllers[index]['term'],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter definition',
                                ),
                                controller: flashcardControllers[index]
                                ['definition'],
                              ),
                            ],
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFF3A1078),
                                size: 28,
                              ),
                              onPressed: () => deleteFlashcard(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ) :  const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard,
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}