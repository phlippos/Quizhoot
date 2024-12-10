import 'package:flutter/material.dart';
import 'package:quizhoot/classes/Flashcard.dart';
import '../classes/Set.dart';

class QuizView extends StatefulWidget {

  const QuizView({super.key});
  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  // List of questions with options and the correct answer
  late List<Map<String, dynamic>> questions ;
  List<String> answers = [];
  late Set _set ;
  bool _isLoaded = false;

  @override
  void didChangeDependencies(){
    if(_isLoaded == false) {
      super.didChangeDependencies();
      _set = ModalRoute
          .of(context)!
          .settings
          .arguments as Set;
      questions = _set.quiz.service.generateQuestionListMC(
          _set.components.whereType<Flashcard>().toList());
      _isLoaded = true;
    }
  }

  int currentQuestionIndex = 0; // Keeps track of the current question
  int score = 0; // User's score
  String? selectedAnswer; // Selected answer by the user

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
          : Center(
        child: CircularProgressIndicator(), // Show loading indicator
      ),
      backgroundColor: const Color(0xFF3A1078),
    );
  }

  // Builds the quiz question UI
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
              _storeAnswerAndGo();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Check the selected answer and update score and question index
  void _storeAnswerAndGo() async{
    setState(() {
      answers.add(selectedAnswer!);
      currentQuestionIndex++; // Move to the next question
      selectedAnswer = null; // Reset the selected answer
    });
    if(currentQuestionIndex == questions.length ){
      List<String> answerKey = questions.map((element) => element['answer'].toString()).toList();
      try{
        _set.quiz.calculateStatistics(answerKey, answers);
        bool responseResult = await _set.quiz.add(_set.id);
        if(responseResult == true){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quiz saved',
              ),
            ),
          );
        }
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
            ),
          ),
        );
      }
    }

  }

  // Builds the result UI after all questions are answered
  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          Text(
            'Your Score: ${_set.quiz.result}', // Display user's score
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

class WrittenQuizPlaceholder extends StatelessWidget {
  const WrittenQuizPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Written Quiz'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: const Center(
        child: Text(
          'Written quiz!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}