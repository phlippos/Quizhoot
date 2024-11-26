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
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }
    try {
      final response = await _setService.createSet(_setNameController.text,cardNumber);
      if (response.statusCode == 201) {
        final Map<String,dynamic> data = jsonDecode(response.body);
        setID = data['id'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Set created ')),
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
          SnackBar(content: Text('flashcard creation failed')),
        );
        return;
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('flashcard creation failed $e')),
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context)
        .size
        .width; // Get the screen width for responsive layout

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set background color
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3A1078), // Match the app bar color with background
        title: const Text(
          'Create Flashcard', // Title of the page
          style: TextStyle(color: Colors.black), // Text color in the app bar
        ),
        actions: [
          // Button to navigate to Flashcard view
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
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
                }
              }else{
                nullTermOrDefinitionIndices = _flashcardService.getNullTermOrDefinitionIndices(flashcards);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the body content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input field for entering a title for the flashcard set
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              width: width * 0.9, // 90% of the screen width
              decoration: BoxDecoration(
                color: Colors
                    .grey[200], // Light grey background for the input field
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              child: TextField(
                controller: _setNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none, // No border
                  hintText: 'Enter a title', // Placeholder text
                ),
              ),
            ),
            const SizedBox(
                height: 20), // Space between title input and flashcard list
            Expanded(
              child: ListView.builder(
                itemCount: flashcards.length, // Number of flashcards to display
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: width *
                          0.9, // 90% of the screen width for each flashcard container
                      decoration: BoxDecoration(
                        color: Colors
                            .grey[200], // Light grey background for flashcards
                        borderRadius: BorderRadius.circular(
                            8.0), // Rounded corners for flashcards
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the card number
                          Text(
                            'Card ${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height:
                                  10), // Space between title and input fields
                          // Text field for entering the term
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText:
                                  'Enter term', // Label for the term input field
                            ),
                            onChanged: (value) {
                              flashcards[index]['term'] =
                                  value; // Update the term when changed
                            },
                          ),
                          const SizedBox(
                              height:
                                  10), // Space between term input and definition input
                          // Text field for entering the definition
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText:
                                  'Enter definition', // Label for the definition input field
                            ),
                            onChanged: (value) {
                              flashcards[index]['definition'] =
                                  value; // Update the definition when changed
                            },
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
      // Floating action button to add new flashcards
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard, // Call addFlashcard function on press
        backgroundColor: const Color.fromARGB(
            255, 150, 100, 255), // Custom background color for the button
        child: const Icon(
            Icons.add), // Plus icon to represent adding a new flashcard
      ),
    );
  }
}
