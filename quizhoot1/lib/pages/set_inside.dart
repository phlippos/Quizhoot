import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  ];

  final FlutterTts _flutterTts =
      FlutterTts(); // Flutter TTS (Text-to-Speech) instance
  List<bool> favorites =
      List.filled(5, false); // List to track favorite status for each flashcard
  List<bool> selectedSets =
      List.filled(3, false); // List to track selected sets
  bool showSetOptions = false; // Boolean to toggle visibility of set options

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
          ElevatedButton(
            onPressed: () {
              // Navigate to QuizView when the button is pressed
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const QuizView()),
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
            child: const Text('Start Quiz'),
          ),
          const SizedBox(height: 20),
          _buildSetOptions(), // Display set options widget
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
    await _flutterTts.setLanguage("en-US"); // Set language to English
    await _flutterTts.setPitch(10.0); // Increase the pitch for higher tone
    await _flutterTts.setSpeechRate(0.5); // Adjust the speech rate
    await _flutterTts.speak(text); // Speak the text
  }
}