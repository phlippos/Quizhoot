import 'package:flutter/material.dart';

class QuizView extends StatefulWidget {
  final bool useOnlyFavorites;

  const QuizView({super.key, required this.useOnlyFavorites});

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Apple',
      'options': ['Apfel', 'Aprikose', 'Kirsche', 'Melone'],
      'answer': 'Apfel',
      'isFavorite': true
    },
    {
      'question': 'Cherry',
      'options': ['Aprikose', 'Melone', 'Kirsche', 'Apfel'],
      'answer': 'Kirsche',
      'isFavorite': false
    },
  ];

  late List<Map<String, dynamic>> filteredQuestions;
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    filteredQuestions = widget.useOnlyFavorites
        ? questions.where((q) => q['isFavorite'] == true).toList()
        : questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: currentQuestionIndex < filteredQuestions.length
          ? _buildQuizQuestion()
          : _buildResult(),
      backgroundColor: const Color(0xFF3A1078),
    );
  }

  Widget _buildQuizQuestion() {
    final question = filteredQuestions[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question['question'],
            style: const TextStyle(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...question['options'].map((option) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: selectedAnswer == option
                    ? Colors.grey[600]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: RadioListTile<String>(
                title:
                    Text(option, style: const TextStyle(color: Colors.black)),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    selectedAnswer = value;
                  });
                },
                activeColor: const Color(0xFF3A1078),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedAnswer == null
                ? null
                : () {
                    _checkAnswer();
                  },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    if (selectedAnswer == filteredQuestions[currentQuestionIndex]['answer']) {
      score++;
    }

    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
    });
  }

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your Score: $score/${filteredQuestions.length}',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Flashcards'),
          ),
        ],
      ),
    );
  }
}
