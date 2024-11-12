import 'package:flutter/material.dart';
import 'set_view.dart'; // Import the necessary page for navigation

class CreateFlashcardPage extends StatefulWidget {
  const CreateFlashcardPage({super.key});

  @override
  _CreateFlashcardPageState createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {
  // A list to store flashcards with term and definition
  List<Map<String, String>> flashcards = [
    {'term': '', 'definition': ''} // Initial empty flashcard
  ];
  int cardNumber = 1; // Tracks the number of flashcards

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const FlashcardViewPage(), // Navigate to FlashcardViewPage
                ),
              );
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
              child: const TextField(
                decoration: InputDecoration(
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
