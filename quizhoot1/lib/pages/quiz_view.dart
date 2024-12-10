import 'package:flutter/material.dart';
import '../classes/Set.dart';
import 'package:quizhoot/classes/Flashcard.dart';

abstract class QuizViewBase extends StatefulWidget {
  const QuizViewBase({super.key});

  @override
  QuizViewBaseState createState();
}

abstract class QuizViewBaseState<T extends QuizViewBase> extends State<T> {
  late List<Map<String, dynamic>> questions;
  List<String> answers = [];
  late Set _set;
  bool _isLoaded = false;
  late String _type;
  late bool _useOnlyFavorites;
  int currentQuestionIndex = 0;

  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      super.didChangeDependencies();
      final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _set = args['set'];
      _useOnlyFavorites = args['useOnlyFavorites'];
      _type = args['type'];
      questions = _set.quiz.service.generateQuestionListMC(
          _set.components.whereType<Flashcard>().toList(), _type, onlyFavorites: _useOnlyFavorites);
      _isLoaded = true;
    }
  }

  // Common method for quiz submission logic
  void _storeAnswerAndGo() async {
    setState(() {
      currentQuestionIndex++; // Move to the next question
    });
    if (currentQuestionIndex == questions.length) {
      List<String> answerKey = _set.quiz.service.getAnswerKey(questions);
      try {
        _set.quiz.calculateStatistics(answerKey, answers);
        bool responseResult = await _set.quiz.add(_set.id);
        if (responseResult == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz saved'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  // Builds the result UI after all questions are answered
  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your Score: ${_set.quiz.result}', // Display user's score
            style: const TextStyle(fontSize: 24, color: Colors.white),
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

  @override
  Widget build(BuildContext context);
}


class QuizView extends QuizViewBase {
  const QuizView({super.key});

  @override
  QuizViewState createState() => QuizViewState();
}

class QuizViewState extends QuizViewBaseState<QuizView> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: _isLoaded
          ? (currentQuestionIndex < questions.length
          ? _buildQuizQuestion()
          : _buildResult())
          : const Center(child: CircularProgressIndicator()), // Show loading indicator
      backgroundColor: const Color(0xFF3A1078),
    );
  }

  Widget _buildQuizQuestion() {
    final question = questions[currentQuestionIndex];

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
          ...question['options'].map<Widget>((option) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: selectedAnswer == option
                    ? Colors.grey[600]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.black),
                ),
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
              answers.add(selectedAnswer!);
              _storeAnswerAndGo();
              selectedAnswer = null; // Reset the selected answer
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
class WrittenQuiz extends QuizViewBase {
  const WrittenQuiz({super.key});

  @override
  _WrittenQuizState createState() => _WrittenQuizState();
}

class _WrittenQuizState extends QuizViewBaseState<WrittenQuiz> {
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Written Quiz'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: _isLoaded
          ? (currentQuestionIndex < questions.length
          ? _buildWrittenQuizQuestion()
          : _buildResult())
          : const Center(child: CircularProgressIndicator()), // Show loading indicator
      backgroundColor: const Color(0xFF3A1078),
    );
  }

  Widget _buildWrittenQuizQuestion() {
    final question = questions[currentQuestionIndex];

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
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              hintText: 'Type your answer here',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              answers.add(_answerController.text);
              _storeAnswerAndGo();
              _answerController.clear(); // Clear the input field
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
