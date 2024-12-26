import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../classes/Set.dart';

class ScrambledGame extends StatefulWidget {
  const ScrambledGame({super.key});

  @override
  _ScrambledGameState createState() => _ScrambledGameState();
}

class _ScrambledGameState extends State<ScrambledGame> {
  late List<String> words;
  late String selectedWord;
  late List<String> scrambledLetters;
  List<String> userGuess = [];
  int score = 0;
  int lives = 3;
  double progress = 0.0;
  Timer? timer;
  bool isGameStopped = false;
  late Set _set;
  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    _set = ModalRoute.of(context)?.settings.arguments as Set;
    words =  _set.getTerms();
    _startNewGame();
  }
  void _startNewGame() {
    setState(() {
      isGameStopped = false;
      selectedWord = (words..shuffle()).first;
      scrambledLetters = _scrambleWord(selectedWord);
      userGuess = List.filled(selectedWord.length, '');
      progress = 0.0;
      _startTimer();
    });
  }

  List<String> _scrambleWord(String word) {
    List<String> characters = word.split('');
    characters.shuffle(Random());
    return characters;
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isGameStopped) {
        setState(() {
          progress += 0.01;
          if (progress >= 1.0) {
            _loseLife();
          }
        });
      }
    });
  }

  void _loseLife() {
    timer?.cancel();
    setState(() {
      lives--;
      if (lives <= 0) {
        _showGameOverDialog();
      } else {
        _startNewGame();
      }
    });
  }

  void _checkGuess() {
    if (userGuess.join() == selectedWord) {
      int bonus = ((1.0 - progress) * 100).toInt();
      setState(() {
        score += 10 + bonus;
      });
      _startNewGame();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                score = 0;
                lives = 3;
              });
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  void _toggleGameStatus() {
    setState(() {
      isGameStopped = !isGameStopped;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Quizhoot başlığı ve durdurma butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quizhoot',
                    style: TextStyle(
                      fontSize: width * 0.09,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: Offset(width * 0.01, height * 0.01),
                          blurRadius: width * 0.02,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Geri gitme butonu
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: width * 0.08,
                        ),
                        onPressed: () {
                          // Burada geri gitme işlemi yapılacak
                          Navigator.pop(
                              context); // Örneğin, önceki sayfaya dönme işlemi
                        },
                      ),
                      // Oyun durdurma/pause butonu
                      IconButton(
                        icon: Icon(
                          isGameStopped ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: width * 0.08,
                        ),
                        onPressed: () {
                          _toggleGameStatus();
                          if (isGameStopped) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Game Stopped"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),
              // Lives
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,

                  (index) => Icon(

                    index < lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: width * 0.08,
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
              // User guess boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(selectedWord.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: width * 0.02),
                    width: width * 0.1,
                    height: width * 0.1,
                    decoration: BoxDecoration(
                      color: userGuess[index].isNotEmpty
                          ? Colors.green
                          : Colors.transparent,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userGuess[index],
                      style: TextStyle(
                          fontSize: width * 0.05, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
              SizedBox(height: height * 0.03),
              // Clear Guess Button
              TextButton(
                onPressed: () {
                  setState(() {
                    userGuess = List.filled(selectedWord.length, '');
                    scrambledLetters = _scrambleWord(selectedWord);
                  });
                },
                child: const Text("Clear Guess",
                    style: TextStyle(color: Colors.white)),
              ),
              // Scrambled letters
              Wrap(
                spacing: width * 0.02,
                runSpacing: width * 0.02,
                children: scrambledLetters.map((letter) {
                  return GestureDetector(
                    onTap: () {
                      int emptyIndex = userGuess.indexOf('');
                      if (emptyIndex != -1) {
                        setState(() {
                          userGuess[emptyIndex] = letter;
                          scrambledLetters[scrambledLetters.indexOf(letter)] =

                              '';

                        });
                        _checkGuess();
                      }
                    },
                    child: Container(
                      width: width * 0.1,
                      height: width * 0.1,
                      decoration: BoxDecoration(
                        color: letter.isNotEmpty ? Colors.white : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: height * 0.03),
              // Shuffle Button
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white),
                onPressed: () {
                  setState(() {
                    scrambledLetters.shuffle();
                  });
                },
              ),
              SizedBox(height: height * 0.03),
              // Progress Bar (Timer)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.orange,
                color: Colors.deepPurple,
                minHeight: height * 0.01,
              ),
              SizedBox(height: height * 0.02),
              // Score
              Center(
                child: Text(
                  "Score: $score",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

}

