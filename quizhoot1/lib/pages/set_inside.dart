import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/classes/Flashcard.dart';
import '../classes/Set.dart';
import 'package:quizhoot/pages/quiz_creation.dart';
import 'package:quizhoot/pages/cards.dart';
import 'package:quizhoot/pages/scrambledGame.dart';
import 'package:another_flushbar/flushbar.dart';
import '../classes/User.dart';

class SetInside extends StatefulWidget {
  // Default constructor (no parameters)
  const SetInside({super.key});


  @override
  _SetInsideState createState() => _SetInsideState();
}

class _SetInsideState extends State<SetInside> {
  // List of flashcards with terms and their definitions
  late List<Flashcard> flashcards = [];
  final FlutterTts _flutterTts =
  FlutterTts(); // Flutter TTS (Text-to-Speech) instance
  late List<bool> _selectedSets; // List to track selected sets
  late Flashcard _selectedFlashcard;
  bool showSetOptions = false; // Boolean to toggle visibility of set options
  bool showDefinitions = false;
  late User _user;
  late Set _set;
  bool _isLoaded = false;
  late List<Set> _sets;

  @override
  void didChangeDependencies(){
    if(_isLoaded == false) {
      super.didChangeDependencies();
      _user = Provider.of<User>(context,listen:false);
      _sets = _user.getSets();
      _selectedSets = List.filled(_user.components.length, false);
      _set = ModalRoute
          .of(context)
          ?.settings
          .arguments as Set;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchFlashcards();
      });
    }
  }

  Future<void> fetchFlashcards() async{
    try {
      await _set.fetchFlashcards();
      flashcards = _set.getFlashcards();
      setState(() {
        _isLoaded = true;
      });
      return;
    }catch(e){
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Inside'),
        backgroundColor: const Color(0xFF3A1078), // Custom color for the app bar
      ),
      body: _isLoaded
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: _set.size, // Number of flashcards
              itemBuilder: (context, index) {
                final Flashcard flashcard = flashcards[index];
                return Center(
                  child: FlipCard(
                    // Front and back of the flashcard
                    front: _buildCardFace(flashcard.term, context, true, index),
                    back: _buildCardFace(flashcard.definition, context, false, index),
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      String? quizType; // Stores the selected quiz type
                      bool useOnlyFavorites = false; // Checkbox state

                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            color: const Color(0xFF3A1078),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Quiz Type:',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const CreateQuizPage(),
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
                                        _startQuiz(
                                          context,
                                          quizType!,
                                          useOnlyFavorites,
                                        );
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
              _buildNavigationButton(
                context: context,
                label: 'Scrambled Game',
                targetPage: '/scrambledGame',
                argument: _set
              ),
              _buildNavigationButton(
                context: context,
                label: 'Cards',
                targetPage: '/cards',
                argument: _set
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
              child: _buildFlashcardList(), // Display the list of all flashcards in a scrollable view
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
      backgroundColor: const Color(0xFF3A1078), // Custom background color
    );
  }

  void _startQuiz(BuildContext context, String quizType, bool useOnlyFavorites) {
    String message = '';
    int minFlashcards = quizType == 'test' ? 4 : 1;

    if ((useOnlyFavorites && _set.favFlashcardNum >= minFlashcards) ||
        (!useOnlyFavorites && _set.size >= minFlashcards)) {
      Navigator.pushNamed(
        context,
        quizType == 'test' ? '/multipleChoiceQuiz' : '/WrittenQuiz',
        arguments: {
          'set': _set,
          'useOnlyFavorites': useOnlyFavorites,
          'type': quizType
        },
      );
    } else {
      message = quizType == 'test'
          ? "min required number of term is 4 for this quiz type. min 4 flashcard must be fav"
          : "min required number of term is 1 for this quiz type. min 1 flashcard must be fav";
      _showFlushbar(message,  Icons.info_outline, Colors.blue[300]!);
    }
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
                flashcards[index].favStatus ? Icons.favorite : Icons.favorite_border,
                color: flashcards[index].favStatus  ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  flashcards[index].favStatus  =
                  !flashcards[index].favStatus ; // Toggle the favorite status
                  // );
                  flashcards[index].updateFavStatus(_set.id);
                });
                final snackBar = SnackBar(
                  content: Text(flashcards[index].favStatus
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
                  _selectedFlashcard = flashcards[index];
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

    bool anySelected = _selectedSets
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
              Column(
                children: _sets.where((set) => set != _set).map((set) {
                  int index = _user.components.indexOf(set);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(set.name), // Display set name
                      Checkbox(
                        value: _selectedSets[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _selectedSets[index] = value ?? false; // Update the selected set
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
          const SizedBox(height: 10),
          if (anySelected) // Only show the "Add" button if any set is selected
            ElevatedButton(
              onPressed: () {
                // Handle adding selected sets
                addFlashcardToSets();
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

  void addFlashcardToSets() async {
    for (int i = 0; i < _selectedSets.length; i++) {
      if (_selectedSets[i] == true) {
        try {
          Flashcard flashcard = Flashcard.create(
            _selectedFlashcard.term,
            _selectedFlashcard.definition,
          );
          await flashcard.add();
          bool isAdded = _sets[i].addComponent(flashcard);

          if (isAdded) {
            _sets[i].size++;
            await _sets[i].createRelationSet_Flashcard(flashcard);
            _showFlushbar(
              'The Flashcard added to your Set ${_sets[i].name}',
              Icons.info_outline,
              Colors.blue[300]!,
            );
          } else {
            _showFlushbar(
              'The Set ${_sets[i].name} already contains this flashcard',
              Icons.info_outline,
              Colors.blue[300]!,
            );
          }
        } catch (e) {
          _showFlushbar(
            '$e',
            Icons.error_outline,
            Colors.red[300]!,
          );
        }
      }
    }
  }

  void _showFlushbar(String message, IconData icon, Color iconColor) {
    Flushbar(
      message: message,
      icon: Icon(
        icon,
        size: 28.0,
        color: iconColor,
      ),
      duration: const Duration(seconds: 3),
      leftBarIndicatorColor: iconColor,
    ).show(context);
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
            entry.value.term,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(221, 5, 5, 5)),
          ),
          subtitle: Text(
            entry.value.definition,
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
                    _deleteFlashcard(entry.value), // Call delete method
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

// Method to delete a flashcard
  void _deleteFlashcard(Flashcard flashcard) {
    setState(() {
      flashcard.remove();
      _set.removeComponent(flashcard);
      _set.size = _set.components.length;
      flashcards.remove(flashcard);
      // Remove the flashcard at the given index
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
    required String targetPage,
    required var argument,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed ?? () {
        Navigator.pushNamed(
          context,
          targetPage,
          arguments: argument,
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
    TextEditingController(text: flashcards[index].term);
    final definitionController =
    TextEditingController(text: flashcards[index].definition);

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
                  flashcards[index].term = termController.text;
                  flashcards[index].definition = definitionController.text;
                  flashcards[index].update();
                  // Update the flashcard
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
