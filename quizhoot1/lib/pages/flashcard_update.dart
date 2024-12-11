import 'package:flutter/material.dart';
import 'set_view.dart';
import '../services/flashcard_service.dart'; // for future backend integration..

class UpdateFlashcardPage extends StatefulWidget {
  final String setName; // Existing set name
  final List<Map<String, String>> flashcards; // Existing flashcards

  const UpdateFlashcardPage({
    super.key,
    required this.setName,
    required this.flashcards,
  });

  @override
  _UpdateFlashcardPageState createState() => _UpdateFlashcardPageState();
}

class _UpdateFlashcardPageState extends State<UpdateFlashcardPage> {
  final TextEditingController _setNameController = TextEditingController();
  late List<Map<String, TextEditingController>>
      flashcardControllers; // Use controllers for term and definition
  final FlashcardService _flashcardService = FlashcardService();

  @override
  void initState() {
    super.initState();
    _setNameController.text = widget.setName;

    // Initialize controllers for each flashcard
    flashcardControllers = widget.flashcards
        .map((flashcard) => {
              'term': TextEditingController(text: flashcard['term']),
              'definition':
                  TextEditingController(text: flashcard['definition']),
            })
        .toList();
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
    });
  }

  void deleteFlashcard(int index) {
    setState(() {
      flashcardControllers[index]['term']!.dispose();
      flashcardControllers[index]['definition']!.dispose();
      flashcardControllers.removeAt(index);
    });
  }

  Future<void> _updateSet() async {
    // Collect updated flashcard data
    List<Map<String, String>> updatedFlashcards = flashcardControllers
        .map((controllerPair) => {
              'term': controllerPair['term']!.text,
              'definition': controllerPair['definition']!.text,
            })
        .toList();

    if (_setNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the set.')),
      );
      return;
    }

    if (updatedFlashcards
        .any((card) => card['term']!.isEmpty || card['definition']!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All cards must have both term and definition.')),
      );
      return;
    }

    // TODO: Add backend update logic here

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcard set updated successfully!')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FlashcardViewPage(),
      ),
    );
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
                                  labelText: 'Enter termö',
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addFlashcard,
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}
