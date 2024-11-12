import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this to use TextInputFormatter

void main() => runApp(WordChainApp());

class WordChainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WordChainGame(),
    );
  }
}

class WordChainGame extends StatefulWidget {
  @override
  _WordChainGameState createState() => _WordChainGameState();
}

class _WordChainGameState extends State<WordChainGame> {
  final List<String> _usedWords = [];
  String _currentWord = 'PENCIL';
  int _timeLeft = 20;
  int _score = 0;
  int _highestScore = 0;
  Timer? _timer;
  String _warningMessage = '';
  TextEditingController _controller =
      TextEditingController(); // Controller for the input field

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _gameOver();
        }
      });
    });
  }

  void _gameOver() {
    _timer?.cancel();
    setState(() {
      // Update the highest score before resetting the current score
      _highestScore = _score > _highestScore ? _score : _highestScore;
    });
  }

  void _checkWord() {
    String inputWord = _controller.text; // Get the text from the controller
    if (inputWord.isEmpty) return;

    if (inputWord[0].toLowerCase() !=
            _currentWord[_currentWord.length - 1].toLowerCase() ||
        _usedWords.contains(inputWord.toLowerCase())) {
      // Invalid word logic: Show warning, no extra time added
      setState(() {
        _warningMessage = 'Invalid word! Try again.';
      });
    } else {
      // Valid word logic
      setState(() {
        _warningMessage = ''; // Clear warning if word is valid
        _usedWords.add(inputWord.toLowerCase());
        _currentWord = inputWord;
        _score++;
        _timeLeft += 5; // Add 5 seconds for a valid word
        _controller.clear(); // Clear the input field after a valid word
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: Text(
          'Word Chain',
          style: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w700,
              fontFamily: "Poppins",
              fontSize: 36),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: Center(
        child: _timeLeft > 0 ? _buildGameScreen() : _buildGameOverScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display the image here
        Image.asset(
          'assets/images/chain.png', // This is the path to your image in the assets folder
          height: 150, // Set the height or width as per your requirement
        ),
        SizedBox(height: 20),
        Text('Word Chain',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                decoration: TextDecoration.underline,
                decorationColor: Color.fromARGB(255, 255, 235, 59))),
        SizedBox(height: 20),
        Text(
            'Next word must start with letter "${_currentWord[_currentWord.length - 1].toUpperCase()}"',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        SizedBox(height: 10),
        Text(_currentWord.toUpperCase(),
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        SizedBox(height: 20),
        Text('Time Left: $_timeLeft seconds',
            style: TextStyle(color: Colors.yellow, fontFamily: "Poppins")),
        SizedBox(height: 12),
        if (_warningMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(_warningMessage,
                style: TextStyle(color: Colors.red, fontSize: 16)),
          ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _controller, // Use the controller to manage input
            onChanged: (value) {
              setState(() {
                // Automatically updates the text in the controller
                _controller.text = value.toUpperCase(); // Force uppercase input
                _controller.selection = TextSelection.fromPosition(TextPosition(
                    offset:
                        _controller.text.length)); // Keep the cursor at the end
              });
            },
            inputFormatters: [
              // Custom input formatter to convert text to uppercase
              UpperCaseTextInputFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'Type here...',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkWord,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
          child:
              Text('Submit', style: TextStyle(color: const Color(0xFF3A1078))),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Game Over',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        SizedBox(height: 20),
        Text('Your Score: $_score',
            style: TextStyle(
                color: Colors.yellow, fontSize: 20, fontFamily: "Poppins")),
        Text('Highest Score: $_highestScore',
            style: TextStyle(
                color: Colors.yellow, fontSize: 20, fontFamily: "Poppins")),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _usedWords.clear();
              _score = 0;
              _currentWord = 'PENCIL';
              _warningMessage = '';
              _startTimer();
              _controller.clear(); // Clear the input field on game restart
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
          child: Text('Play Again',
              style: TextStyle(color: const Color(0xFF3A1078))),
        ),
      ],
    );
  }
}

// Custom InputFormatter to force uppercase input
class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Converts the input text to uppercase
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset),
    );
  }
}
