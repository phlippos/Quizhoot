import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quizhoot/pages/cards.dart';
import 'package:quizhoot/pages/scrambledGame.dart';
import 'quiz_view.dart';

class SetInside extends StatefulWidget {
  const SetInside({super.key});

  @override
  _SetInsideState createState() => _SetInsideState();
}

class _SetInsideState extends State<SetInside> {
  // List of flashcards with terms and their definitions
  final List<Map<String, String>> flashcards = [
    {'term': 'Apple', 'definition': 'Apfel'},
    {'term': 'Apricot', 'definition': 'Aprikose'},
    {'term': 'Cherry', 'definition': 'Kirsche'},
    {'term': 'Melon', 'definition': 'Melone'},
    {'term': 'Pear', 'definition': 'Birne'},
    {'term': 'Banana', 'definition': 'Banane'},
    {'term': 'Grape', 'definition': 'Traube'},
    {'term': 'Orange', 'definition': 'Orange'},
    {'term': 'Strawberry', 'definition': 'Erdbeere'},
    {'term': 'Peach', 'definition': 'Pfirsich'},
  ];

  final FlutterTts _flutterTts =
      FlutterTts(); // Flutter TTS (Text-to-Speech) instance
  List<bool> favorites = List.filled(
      10, false); // List to track favorite status for each flashcard
  List<bool> selectedSets =
      List.filled(3, false); // List to track selected sets
  bool showSetOptions = false; // Boolean to toggle visibility of set options
  bool showDefinitions =
      false; // Boolean to toggle showing definitions (Show button functionality)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Inside'),
        backgroundColor:
            const Color(0xFF3A1078), // Custom color for the app bar
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: flashcards.length, // Number of flashcards
              itemBuilder: (context, index) {
                final flashcard = flashcards[index];
                return Center(
                  child: FlipCard(
                    // Front and back of the flashcard
                    front: _buildCardFace(
                        flashcard['term']!, context, true, index),
                    back: _buildCardFace(
                        flashcard['definition']!, context, false, index),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavigationButton(
                context: context,
                label: 'Start Quiz',
                targetPage: const QuizView(),
              ),
              _buildNavigationButton(
                context: context,
                label: 'Scrambled Game',
                targetPage: const ScrambledGame(),
              ),
              _buildNavigationButton(
                context: context,
                label: 'Cards',
                targetPage: const CardsPage(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSetOptions(), // Display set options widget
          const SizedBox(height: 10),
          _buildShowDefinitionsButton(), // Display Show Definitions button
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child:
                  _buildFlashcardList(), // Display the list of all flashcards in a scrollable view
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF3A1078), // Custom background color
    );
  }

  // Builds the front or back face of a flashcard
  Widget _buildCardFace(
      String text, BuildContext context, bool isTerm, int index) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.8, // Card width relative to screen size
      height: MediaQuery.of(context).size.height *
          0.5, // Card height relative to screen size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        // Stack allows placing multiple widgets on top of each other
        children: [
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                favorites[index] ? Icons.favorite : Icons.favorite_border,
                color: favorites[index] ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  favorites[index] =
                      !favorites[index]; // Toggle the favorite status
                });
                final snackBar = SnackBar(
                  content: Text(favorites[index]
                      ? 'Added to favorites'
                      : 'Removed from favorites'), // Show feedback message
                  duration: const Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(snackBar); // Display the snackbar message
              },
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.file_present,
                  size: 30, color: Color(0xFF3A1078)),
              onPressed: () {
                setState(() {
                  showSetOptions =
                      !showSetOptions; // Toggle visibility of set options
                });
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width *
                0.35, // Center the volume icon
            child: IconButton(
              icon: const Icon(Icons.volume_up,
                  size: 30, color: Color(0xFF3A1078)),
              onPressed: () => _speak(text), // Trigger text-to-speech
            ),
          ),
        ],
      ),
    );
  }

  // Builds the set options section, displayed when toggle is enabled
  Widget _buildSetOptions() {
    if (!showSetOptions)
      return Container(); // Hide the set options if the toggle is off

    bool anySelected = selectedSets
        .any((selected) => selected); // Check if any set is selected

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Choose a Set:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(3, (index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Set ${index + 1}'), // Display set number
                Checkbox(
                  value: selectedSets[index],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedSets[index] =
                          value ?? false; // Update the selected set
                    });
                  },
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          if (anySelected) // Only show the "Add" button if any set is selected
            ElevatedButton(
              onPressed: () {
                // Handle adding selected sets
                String addedSets = selectedSets
                    .asMap()
                    .entries
                    .where((entry) => entry.value)
                    .map((entry) => 'Set ${entry.key + 1}')
                    .join(', ');
                final snackBar = SnackBar(
                  content: Text(
                      '$addedSets added to your sets'), // Feedback message for added sets
                  duration: const Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                setState(() {
                  showSetOptions = false; // Hide set options after adding
                });
              },
              child: const Text('Add'),
            )
          else // Show a message if no sets are selected
            const Text('No sets selected'),
        ],
      ),
    );
  }

  // Method to trigger text-to-speech for a given text
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

// Displays the list of all flashcards, including the edit button, with toggle functionality
// Displays the list of all flashcards, including the edit and delete buttons, with toggle functionality
  Widget _buildFlashcardList() {
    if (!showDefinitions) {
      return const SizedBox(); // Return an empty container when hidden
    }

    return Column(
      children: flashcards
          .asMap()
          .entries
          .map(
            (entry) => ListTile(
              title: Text(
                entry.value['term']!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 5, 5, 5)),
              ),
              subtitle: Text(
                entry.value['definition']!,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 198, 189, 189)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Color.fromARGB(255, 198, 189, 189)),
                    onPressed: () =>
                        _editFlashcard(entry.key), // Call edit method
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Color.fromARGB(255, 198, 189, 189)),
                    onPressed: () =>
                        _deleteFlashcard(entry.key), // Call delete method
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

// Method to delete a flashcard
  void _deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index); // Remove the flashcard at the given index
    });

    final snackBar = SnackBar(
      content: const Text('Flashcard deleted'), // Show feedback message
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(snackBar); // Display the snackbar message
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required String label,
    required Widget targetPage,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  // Displays the "Show Words" button
  Widget _buildShowDefinitionsButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showDefinitions =
              !showDefinitions; // Toggle showing words and edit button
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(showDefinitions ? 'Hide Words' : 'Show Words'),
    );
  }

// Opens a dialog to edit a flashcard
  void _editFlashcard(int index) {
    final termController =
        TextEditingController(text: flashcards[index]['term']);
    final definitionController =
        TextEditingController(text: flashcards[index]['definition']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: termController,
                decoration: const InputDecoration(labelText: 'Term'),
              ),
              TextField(
                controller: definitionController,
                decoration: const InputDecoration(labelText: 'Definition'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  flashcards[index] = {
                    'term': termController.text,
                    'definition': definitionController.text,
                  }; // Update the flashcard
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
