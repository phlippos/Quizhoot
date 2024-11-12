import 'package:flutter/material.dart';
import 'quiz_view.dart'; // Import the QuizView page

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final List<Map<String, dynamic>> quizzes = [
    {
      'question': '', // Initial question for the quiz
      'options':
          List.generate(4, (_) => ''), // Initial options for the quiz (empty)
      'correctAnswer': '', // Initial correct answer for the quiz
    },
  ];

  // Function to add a new quiz to the list
  void _addQuiz() {
    setState(() {
      quizzes.add({
        'question': '', // Empty question
        'options': List.generate(4, (_) => ''), // Empty options
        'correctAnswer': '', // Empty correct answer
      });
    });
  }

  // Function to update a specific quiz question, option, or correct answer
  void _updateQuiz(int index, String field, String value) {
    setState(() {
      if (field == 'question') {
        quizzes[index]['question'] = value; // Update question
      } else if (field.startsWith('option')) {
        int optionIndex = int.parse(field.split('_')[1]); // Get option index
        quizzes[index]['options'][optionIndex] = value; // Update option
      } else if (field == 'correctAnswer') {
        quizzes[index]['correctAnswer'] = value; // Update correct answer
      }
    });
  }

  // Navigate to the QuizView page
  void _navigateToQuizView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuizView(), // Navigate to QuizView
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'), // Title of the page
        backgroundColor:
            const Color(0xFF3A1078), // Set background color for the app bar
      ),
      body: Container(
        padding:
            const EdgeInsets.all(16.0), // Padding around the quiz creation form
        color: const Color(0xFF3A1078), // Background color for the body
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Iterate over each quiz in the list and display text fields for editing
              ...quizzes.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> quiz = entry.value;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10), // Card margin
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16.0), // Padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextField for entering the question
                        TextField(
                          onChanged: (value) => _updateQuiz(index, 'question',
                              value), // Update question on text change
                          decoration: const InputDecoration(
                            labelText: 'Question', // Label for the text field
                            hintText:
                                'Enter the question here', // Hint text for the text field
                            border:
                                OutlineInputBorder(), // Border for the text field
                          ),
                          controller: TextEditingController(
                              text: quiz[
                                  'question']), // Set controller with the current question value
                        ),
                        const SizedBox(height: 15), // Space between fields
                        // Generate 4 option fields dynamically
                        ...List.generate(4, (optionIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: TextField(
                              onChanged: (value) => _updateQuiz(
                                  index,
                                  'option_$optionIndex',
                                  value), // Update option on text change
                              decoration: InputDecoration(
                                labelText:
                                    'Option ${optionIndex + 1}', // Label for the option field
                                hintText:
                                    'Enter option ${optionIndex + 1}', // Hint text for the option field
                                border:
                                    const OutlineInputBorder(), // Border for the option field
                              ),
                              controller: TextEditingController(
                                  text: quiz['options'][
                                      optionIndex]), // Set controller with the current option value
                            ),
                          );
                        }),
                        const SizedBox(height: 15), // Space between fields
                        // TextField for entering the correct answer
                        TextField(
                          onChanged: (value) => _updateQuiz(
                              index,
                              'correctAnswer',
                              value), // Update correct answer on text change
                          decoration: const InputDecoration(
                            labelText:
                                'Correct Answer', // Label for the correct answer field
                            hintText:
                                'Enter the correct answer here', // Hint text for the correct answer field
                            border:
                                OutlineInputBorder(), // Border for the correct answer field
                          ),
                          controller: TextEditingController(
                              text: quiz[
                                  'correctAnswer']), // Set controller with the current correct answer value
                        ),
                        const SizedBox(
                            height: 10), // Space at the bottom of the card
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20), // Space before the create button
              // Button to navigate to the QuizView page
              ElevatedButton(
                onPressed:
                    _navigateToQuizView, // Navigate when the button is pressed
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3A1078), // Button background color
                ),
                child: const Text('Create Quiz'), // Button text
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuiz, // Add a new quiz when the button is pressed
        backgroundColor:
            const Color(0xFF3A1078), // Floating button background color
        child: const Icon(Icons.add), // Floating button icon
      ),
    );
  }
}
