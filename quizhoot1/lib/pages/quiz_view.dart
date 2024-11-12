import 'package:flutter/material.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  // List of questions with options and the correct answer
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Apple',
      'options': ['Apfel', 'Aprikose', 'Kirsche', 'Melone'],
      'answer': 'Apfel'
    },
    {
      'question': 'Cherry',
      'options': ['Aprikose', 'Melone', 'Kirsche', 'Apfel'],
      'answer': 'Kirsche'
    },
    {
      'question': 'Apricot',
      'options': ['Aprikose', 'Kirsche', 'Birne', 'Melone'],
      'answer': 'Aprikose'
    },
    {
      'question': 'Pear',
      'options': ['Melone', 'Apfel', 'Kirsche', 'Birne'],
      'answer': 'Birne'
    },
    {
      'question': 'Melon',
      'options': ['Apfel', 'Melone', 'Aprikose', 'Apfel'],
      'answer': 'Melone'
    },
  ];

  int currentQuestionIndex = 0; // Keeps track of the current question
  int score = 0; // User's score
  String? selectedAnswer; // Selected answer by the user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'), // AppBar title
        backgroundColor: const Color(0xFF3A1078), // AppBar background color
      ),
      // Display the quiz or result based on the question index
      body: currentQuestionIndex < questions.length
          ? _buildQuizQuestion() // Show question if there are more questions
          : _buildResult(), // Show result if all questions are answered
      backgroundColor:
          const Color(0xFF3A1078), // Background color of the screen
    );
  }

  // Builds the quiz question UI
  Widget _buildQuizQuestion() {
    final question =
        questions[currentQuestionIndex]; // Get the current question

    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding for the content
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          Text(
            question['question'], // Display the question
            style: const TextStyle(
                fontSize: 20, color: Colors.white), // Text style
            textAlign: TextAlign.center, // Center the question text
          ),
          const SizedBox(height: 20), // Space between question and options
          // Generate radio buttons for each option
          ...question['options'].map((option) {
            return Container(
              margin: const EdgeInsets.symmetric(
                  vertical: 8.0), // Margin for each option
              decoration: BoxDecoration(
                color: selectedAnswer == option
                    ? Colors.grey[600] // Highlight selected answer
                    : Colors.grey[300], // Default background for unselected
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: RadioListTile<String>(
                title: Text(option,
                    style: const TextStyle(color: Colors.black)), // Option text
                value: option, // Option value
                groupValue: selectedAnswer, // Group value for radio button
                onChanged: (value) {
                  setState(() {
                    selectedAnswer = value; // Update selected answer
                  });
                },
                activeColor:
                    const Color(0xFF3A1078), // Active radio button color
                controlAffinity: ListTileControlAffinity
                    .trailing, // Move radio button to the right
              ),
            );
          }).toList(),
          const SizedBox(height: 20), // Space between options and submit button
          ElevatedButton(
            onPressed: selectedAnswer == null
                ? null // Disable button if no answer is selected
                : () {
                    _checkAnswer(); // Check the selected answer
                  },
            child: const Text('Submit'), // Submit button text
          ),
        ],
      ),
    );
  }

  // Check the selected answer and update score and question index
  void _checkAnswer() {
    if (selectedAnswer == questions[currentQuestionIndex]['answer']) {
      score++; // Increase score if the answer is correct
    }

    setState(() {
      currentQuestionIndex++; // Move to the next question
      selectedAnswer = null; // Reset the selected answer
    });
  }

  // Builds the result UI after all questions are answered
  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          Text(
            'Your Score: $score/${questions.length}', // Display user's score
            style: const TextStyle(
                fontSize: 24, color: Colors.white), // Text style
          ),
          const SizedBox(height: 20), // Space between score and button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the previous page
            },
            child: const Text('Back to Flashcards'), // Button text
          ),
        ],
      ),
    );
  }
}
