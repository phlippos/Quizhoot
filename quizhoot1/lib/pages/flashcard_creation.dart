import 'dart:convert';
import 'package:flutter/material.dart';
import 'set_view.dart'; // Import the necessary page for navigation
import '../services/set_service.dart';
import '../services/flashcard_service.dart';
import '../services/set_flashcard_service.dart';

class CreateFlashcardPage extends StatefulWidget {
  const CreateFlashcardPage({super.key});

  @override
  _CreateFlashcardPageState createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {

  List<int> nullTermOrDefinitionIndices = [];
  List<int> duplicateIndices = [];

  int setID = -1;
  SetService _setService = SetService();
  FlashcardService _flashcardService = FlashcardService();
  Set_FlashcardService _set_flashcardService = Set_FlashcardService();
  int cardNumber = 1; // Tracks the number of flashcards
  final TextEditingController _setNameController = TextEditingController();

  Future<void> _createSet() async {
    if (_setNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title for the set.')),
      );
      return;
    }
    try {
      final response = await _setService.createSet(_setNameController.text,cardNumber);
      if (response.statusCode == 201) {
        final Map<String,dynamic> data = jsonDecode(response.body);
        setID = data['id'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard set created successfully!')),
        );

      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('set creation failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('set creation failed $e')),
      );
    }
  }

  Future<void> _createRelationSet_Flashcard(int setID,int flashcardID) async {
    try{
      final response = await _set_flashcardService.createRelationSet_Flashcard(setID, flashcardID);
      if(response.statusCode == 201){
        return;
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _createFlashcard(Map<String,String>? wordPair) async{
    if( wordPair != null && (wordPair['term']!.isEmpty || wordPair['definition']!.isEmpty)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('fields are required')),
      );
      return;
    }
    try{
      final response = await _flashcardService.createFlashcard(wordPair?['term'],wordPair?['definition']);
      if(response.statusCode == 201){
        final Map<String,dynamic> data = jsonDecode(response.body);
        await _createRelationSet_Flashcard(setID, data['id']);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard creation failed')),
        );
        return;
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashcard creation failed $e')),
      );
    }
  }


  List<Map<String, String>> flashcards = [
    {'term': '', 'definition': ''} // Initial empty flashcard
  ];


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
            onPressed:() async {

              if(_flashcardService.checkExistanceNullFlashcard(flashcards)) {
                if (_flashcardService.checkDuplication(flashcards)) {
                  await _createSet();

                  for (Map<String, String> wordPair in flashcards) {
                    await _createFlashcard(wordPair);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const FlashcardViewPage(), // Navigate to FlashcardViewPage
                    ),
                  );
                }else{
                  duplicateIndices = _flashcardService.getDuplicateIndices(flashcards);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicate terms are not allowed.')),
                  );
                }
              }else{
                nullTermOrDefinitionIndices = _flashcardService.getNullTermOrDefinitionIndices(flashcards);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('All cards must have both term and definition.')),
                );
              }
            }, // Save the set on button press
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