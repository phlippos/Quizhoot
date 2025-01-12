import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/classes/Flashcard.dart';
import '../classes/User.dart';
import '../classes/Set.dart';


class CreateFlashcardPage extends StatefulWidget {
  const CreateFlashcardPage({super.key});

  @override
  _CreateFlashcardPageState createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {

  List<int> nullTermOrDefinitionIndices = [];
  List<int> duplicateIndices = [];
  late User _user;
  late Set _set;
  int cardNumber = 1; // Tracks the number of flashcards
  final TextEditingController _setNameController = TextEditingController();
  List<Map<String, String>> flashcards = [
    {'term': '', 'definition': ''} // Initial empty flashcard
  ];


  void initState() {
    _user = Provider.of<User>(context,listen:false);
    super.initState();
  }

  void _createSet() async {
    if (_setNameController.text.isEmpty) {
      _showSnackBar('Please enter a title for the set.');
      return;
    }

    bool setExists = _user.components.any((component) =>
    component is Set && component.name == _setNameController.text
    );
    if (setExists) {
      _showSnackBar('A set with this name already exists. Please choose a different name.');
      return;
    }

    if (!Flashcard.checkExistanceNullFlashcard(flashcards)) {
      nullTermOrDefinitionIndices = Flashcard.getNullTermOrDefinitionIndices(flashcards);
      _showSnackBar('All cards must have both term and definition.');
      return;
    }

    if (!Flashcard.checkDuplication(flashcards)) {
      duplicateIndices = Flashcard.getDuplicateIndices(flashcards);
      _showSnackBar('Duplicate terms are not allowed.');
      return;
    }

    try {
      _set = Set.create(_setNameController.text, cardNumber);
      final responseSet = await _set.add();

      if (responseSet.statusCode == 201) {
        _user.addComponent(_set);
        await _addFlashcardsToSet(_set);
        Navigator.pushNamed(context, '/setView');
      } else {
        _showSnackBar('Set creation failed.');
      }
    } catch (e) {
      _showSnackBar('Set creation failed: $e');
    }
  }

  Future<void> _addFlashcardsToSet(Set set) async {
    for (Map<String, String> flashcard in flashcards) {
      Flashcard flashcardObj = Flashcard.create(flashcard['term']!, flashcard['definition']!);
      final responseFlashcard = await flashcardObj.add();

      if (responseFlashcard.statusCode == 201) {
        await set.createRelationSet_Flashcard(flashcardObj);
        set.addComponent(flashcardObj);
      } else {
        _showSnackBar('Flashcard creation failed.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  // Function to add a new flashcard
  void addFlashcard() {
    setState(() {
      flashcards.add({'term': '', 'definition': ''});
      cardNumber++; // Increment the card number for each added flashcard
    });
  }

  // Function to delete a flashcard
  void deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
      cardNumber--;
    });
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text(
          'Create Flashcard',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: Colors.green,
            onPressed:_createSet, // Save the set on button press
          ),
        ],
      ),
      body: Padding(
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
                itemCount: flashcards.length,
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
                            offset: Offset(2, 4), // Shadow position
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
                                onChanged: (value) {
                                  flashcards[index]['term'] = value;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter definition',
                                ),
                                onChanged: (value) {
                                  flashcards[index]['definition'] = value;
                                },
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard,
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}