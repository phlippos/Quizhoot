import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class WordlePage extends StatelessWidget {
  const WordlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WORDLE",
          style: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w700,
              fontFamily: "Poppins",
              fontSize: 36),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff3A1078),
        elevation: 0,
      ),
      body: const WordleGame(), // Calling the WordleGame widget here
      backgroundColor: const Color(0xFF3A1078), // Background color
    );
  }
}

class WordleGame extends StatefulWidget {
  const WordleGame({super.key});

  @override
  _WordleGameState createState() => _WordleGameState();
}

class _WordleGameState extends State<WordleGame> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer; // AudioPlayer instance
  late String targetWord; // Target word for the game
  int currentRow = 0; // Current row in the grid
  int currentCol = 0; // Current column in the grid
  List<List<String>> guesses =
      List.generate(6, (_) => List.filled(5, "")); // List of guesses
  List<Color> keyboardColors = List.filled(26, Colors.grey); // Keyboard colors
  List<String> wordList = []; // List of valid words
  bool _isLoading = true; // Loading state

  late AnimationController
      _controller; // Animation controller for grid animation
  late Animation<Offset> _animation; // Animation for translating cells

  @override
  void initState() {
    super.initState();

    // Initialize AudioPlayer
    _audioPlayer = AudioPlayer();

    // Initialize animation controller
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    // Define the animation
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Fetch the words
    fetchWords();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Function to fetch words from an API
  Future<void> fetchWords() async {
    setState(() {
      _isLoading = true; // Set loading state to true when fetching words
    });

    final response = await http.get(
      Uri.parse(
          'https://random-word-api.herokuapp.com/word?number=8500&length=5'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        wordList = data
            .where((word) => (word as String).length == 5)
            .map<String>((word) => word.toUpperCase())
            .toList();

        if (wordList.isNotEmpty) {
          targetWord = wordList[Random().nextInt(wordList.length)];
          print('Target Word: $targetWord');
        } else {
          throw Exception('No valid 5-letter words found.');
        }
        _isLoading = false; // Set loading state to false when words are loaded
      });
    } else {
      setState(() {
        _isLoading = false; // If API request fails, stop loading
      });
      throw Exception('Failed to load words');
    }
  }

  // Function to play sound
  void playSound(String soundPath) async {
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource(soundPath)); // Play sound
  }

  // Function to handle guess submission
  void enterGuess() {
    final guess = guesses[currentRow].join();
    if (guess.length == 5) {
      if (wordList.contains(guess)) {
        updateKeyboardColors(guess);

        // Animation starts
        if (guess == targetWord) {
          playSound('images/success.mp3');
          showEndGameDialog("Congratulations!",
              "You've guessed the correct word: $targetWord");
        } else if (currentRow == 5) {
          playSound('images/failure.mp3');
          showEndGameDialog("Game Over", "The correct word was: $targetWord");
        } else {
          playSound('images/incorrect.mp3');
          setState(() {
            currentRow++;
            currentCol = 0;
          });

          // Trigger animation
          _controller.forward(from: 0.0); // Start animation
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Word"),
            content: const Text("The word you entered is not in the list."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
        playSound('images/wrong.mp3');
      }
    }
  }

  // Function to delete a letter
  void deleteLetter() {
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        guesses[currentRow][currentCol] = "";
      });
    }
  }

  // Function to update keyboard colors based on the guess
  void updateKeyboardColors(String guess) {
    for (int i = 0; i < guess.length; i++) {
      if (targetWord.contains(guess[i])) {
        if (targetWord[i] == guess[i]) {
          keyboardColors[guess[i].codeUnitAt(0) - 'A'.codeUnitAt(0)] =
              Colors.green;
        } else {
          keyboardColors[guess[i].codeUnitAt(0) - 'A'.codeUnitAt(0)] =
              Colors.orange;
        }
      } else {
        keyboardColors[guess[i].codeUnitAt(0) - 'A'.codeUnitAt(0)] =
            Colors.black54;
      }
    }
  }

  // Function to reset the game
  void resetGame() {
    setState(() {
      targetWord = wordList[Random().nextInt(wordList.length)];
      currentRow = 0;
      currentCol = 0;
      guesses = List.generate(6, (_) => List.filled(5, ""));
      keyboardColors = List.filled(26, Colors.grey);
      print('Target Word: $targetWord');
    });
  }

  // Function to show the end game dialog
  void showEndGameDialog(String title, String message) {
    Color dialogTitleColor =
        title == "Congratulations!" ? Colors.green : Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: dialogTitleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame(); // Reset the game
            },
            child: const Text(
              "Play Again",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the on-screen keyboard
  Widget buildKeyboard() {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              return GestureDetector(
                onTap: () {
                  if (currentCol < 5 && currentRow < 6) {
                    setState(() {
                      guesses[currentRow][currentCol] = letter;
                      currentCol++;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: keyboardColors[
                        letter.codeUnitAt(0) - 'A'.codeUnitAt(0)],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: enterGuess,
              child: Container(
                margin: const EdgeInsets.all(2),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "ENTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: deleteLetter,
              child: Container(
                margin: const EdgeInsets.all(2),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.backspace,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Function to build the grid of the game
  Widget buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      itemCount: 30,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;

        return AnimatedBuilder(
          animation: _controller, // Link the animation controller
          builder: (context, child) {
            // Translate the cell based on animation value
            if (row == currentRow) {
              return Transform.translate(
                offset:
                    _controller.value != 0.0 ? _animation.value : Offset.zero,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: getColor(row, col),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      guesses[row][col], // Display the letter
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: getColor(row, col),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    guesses[row][col], // Display the letter
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Color getColor(int row, int col) {
    if (row >= currentRow) return Colors.grey[800]!; // For unfilled rows

    String guessLetter = guesses[row][col];
    int correctCount = 0; // Correct (green) count
    int misplacedCount = 0; // Misplaced (orange) count

    // Hedef kelime harflerinin sayısını tut
    Map<String, int> targetLetterCount = {};
    for (var letter in targetWord.split('')) {
      targetLetterCount[letter] = (targetLetterCount[letter] ?? 0) + 1;
    }

    // Doğru pozisyondaki harfleri (yeşil) kontrol et
    for (int i = 0; i < 5; i++) {
      if (guesses[row][i] == targetWord[i]) {
        targetLetterCount[guesses[row][i]] =
            targetLetterCount[guesses[row][i]]! - 1;
        if (i == col) return Colors.green; // Bu pozisyon zaten yeşil
      }
    }

    // Yanlış pozisyondaki harfleri (turuncu) kontrol et
    for (int i = 0; i < 5; i++) {
      if (guesses[row][i] != targetWord[i] &&
          targetWord.contains(guesses[row][i])) {
        if (targetLetterCount[guesses[row][i]]! > 0) {
          targetLetterCount[guesses[row][i]] =
              targetLetterCount[guesses[row][i]]! - 1;
          if (i == col) return Colors.orange; // Bu pozisyon turuncu
        }
      }
    }

    return Colors.grey; // Hiçbir şartı sağlamıyorsa gri
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading Game...",
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildGrid(),
                const SizedBox(height: 10),
                buildKeyboard(),
              ],
            ),
          );
  }
}
