import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quizhoot/pages/quiz_creation.dart';
//import 'quiz_view.dart';
import '../services/set_flashcard_service.dart';
import '../services/flashcard_service.dart';
import 'package:quizhoot/pages/cards.dart';
import 'package:quizhoot/pages/scrambledGame.dart';
import 'package:quizhoot/pages/quiz_view.dart';

class SetInside extends StatefulWidget {
  final int? setID; // Set ID can be nullable for the default constructor

  // Default constructor (no parameters)
  const SetInside({super.key}) : setID = null;

  const SetInside.withSetID({super.key, required this.setID});

  @override
  _SetInsideState createState() => _SetInsideState();
}

class _SetInsideState extends State<SetInside> {
  Set_FlashcardService _set_flashcardService = Set_FlashcardService();
  FlashcardService _flashcardService = FlashcardService();

  // List of flashcards with terms and their definitions
  List<Map<String, dynamic>> flashcards = [];

  final FlutterTts _flutterTts =
      FlutterTts(); // Flutter TTS (Text-to-Speech) instance
  List<bool> selectedSets =
      List.filled(3, false); // List to track selected sets
  bool showSetOptions = false; // Boolean to toggle visibility of set options
  bool showDefinitions = false;

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    try {
      await _set_flashcardService.fetchData(widget.setID!);
      List<Map<String, dynamic>> fetchedFlashcards = _set_flashcardService.data;
      setState(() {
        flashcards = fetchedFlashcards;
      });
    } catch (e) {
      print('Error fetching sets: $e');
    }
  }

  void _updateFavStatus(int flashcardID, bool fav) async {
    try {
      final response =
          await _set_flashcardService.updateFavStatus(flashcardID, fav);
      if (response.statusCode == 200) {
        if (fav) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('added fav list')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('removed from fav list')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('fav operation failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('fav creation failed $e')),
      );
    }
  }

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
              ElevatedButton(
                onPressed: () {
                  if (flashcards.length > 4) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        String? quizType; // Stores the selected quiz type
                        bool useOnlyFavorites = false; // Checkbox state

                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Container(
                              padding: const EdgeInsets.all(16.0),
                              color: const Color(0xFF3A1078),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Select Quiz Type:',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text(
                                      'Test',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: 'test',
                                    groupValue: quizType,
                                    onChanged: (value) {
                                      setState(() {
                                        quizType = value;
                                      });
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: const Text(
                                      'Written',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: 'written',
                                    groupValue: quizType,
                                    onChanged: (value) {
                                      setState(() {
                                        quizType = value;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text(
                                      'Use only favorite cards',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: useOnlyFavorites,
                                    onChanged: (value) {
                                      setState(() {
                                        useOnlyFavorites = value ?? false;
                                      });
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CreateQuizPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                        ),
                                        child: const Text(
                                          'Create Quiz',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: quizType == null
                                            ? null
                                            : () {
                                                if (quizType == 'test') {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          QuizView.withFlashcards(
                                                              flashcards:
                                                                  flashcards),
                                                    ),
                                                  );
                                                } else if (quizType ==
                                                    'written') {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const WrittenQuiz(),
                                                    ),
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                        ),
                                        child: const Text(
                                          'Start Quiz',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'min required number of term is 4 for this quiz type.',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Quiz'),
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
                flashcards[index]['fav']
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: flashcards[index]['fav'] ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  flashcards[index]['fav'] =
                      !flashcards[index]['fav']; // Toggle the favorite status
                  _updateFavStatus(
                      flashcards[index]['id'], flashcards[index]['fav']);
                });
                final snackBar = SnackBar(
                  content: Text(flashcards[index]['fav']
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

  void _deleteFlashcard(int index) async {
    final flashcardID = flashcards[index]['id'];  // Get the flashcard ID

    try {
      // Call the delete API service
      final response = await _flashcardService.deleteFlashcard(flashcardID);

      if (response.statusCode == 204) {
        // If delete was successful, remove the flashcard from the local list
        setState(() {
          flashcards.removeAt(index);
        });

        // Show success message
        final snackBar = SnackBar(
          content: const Text('Flashcard deleted'),
          duration: const Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // Show error message if the delete failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting flashcard')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete flashcard: $e')),
      );
    }
  }


  Widget _buildNavigationButton({
    required BuildContext context,
    required String label,
    required Widget targetPage,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed ??
          () {
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
              onPressed: () async {
                final updatedTerm = termController.text;
                final updatedDefinition = definitionController.text;

                // Call the method to update the flashcard
                await _flashcardService.updateFlashcard(flashcardID, updatedTerm, updatedDefinition);

                // Close the dialog
                Navigator.of(context).pop();

                // Refresh the flashcards after the update
                await _fetchFlashcards(); // Fetch updated flashcards

                // Optional: Show a confirmation snackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Flashcard updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

