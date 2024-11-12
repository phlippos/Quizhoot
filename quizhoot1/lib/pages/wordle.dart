import 'package:flutter/material.dart';
import 'dart:math';

class WordlePage extends StatelessWidget {
  const WordlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WORDLE",
          style: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.w700,
              fontFamily: "Poppins",
              fontSize: 36),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff3A1078),
        elevation: 0,
      ),
      body: WordleGame(), // WordleGame widget'ını burada çağırıyoruz
      backgroundColor: const Color(0xFF3A1078), // Arka plan rengi
    );
  }
}

class WordleGame extends StatefulWidget {
  @override
  _WordleGameState createState() => _WordleGameState();
}

class _WordleGameState extends State<WordleGame> {
  final List<String> wordList = [
    "MOUSE",
    "APPLE",
    "PLANT",
    "GRAPE",
    "HOUSE",
    "BRICK",
    "STORM",
    "CRISP",
    "TRAIN",
    "SHARK",
    "FIELD",
    "CHAIR",
    "TABLE",
    "RIVER",
    "STRAW",
    "PLANE",
    "OCEAN",
    "SHEEP",
    "CRANE",
    "STONE",
    "CLOUD",
    "BRUSH",
    "FLOOR",
    "STAGE",
    "BLANK",
    "BRAND",
    "FLASH",
    "TRACK",
    "CLOCK",
    "WATER",
    "LIGHT",
    "EARTH",
    "SNAKE",
    "GRASS",
    "PAINT",
    "SKY",
    "BEACH",
    "PIZZA",
    "BEANS",
    "SOUND",
    "TRUCK",
    "PLUMB",
    "STORY",
    "SPACE",
    "CANDY",
    "LEMON",
    "WHALE",
    "GLOVE",
    "TOUCH",
    "TIGER",
    "PEACH",
    "THORN",
    "BREAD",
    "GLASS",
    "CHALK",
    "FLAME",
    "FRUIT",
    "SWORD",
    "COAST",
    "DRIVE",
    "HEART",
    "SLOPE",
    "BERRY",
    "GHOST",
    "FEVER",
    "SLICE",
    "CROWN",
    "VIRUS",
    "CROSS",
    "SPOON",
    "STOVE",
    "FENCE",
    "RAISE",
    "SMILE",
    "ANGEL",
    "PLATE",
    "ROBOT",
    "PIANO",
    "CABLE",
    "SWING",
    "MOTOR",
    "MANGO",
    "ALARM",
    "GUEST",
    "JUICE",
    "LAYER",
    "ALGAE",
    "QUICK",
    "FLOAT",
    "GRIND",
    "SPADE",
    "BRAVE",
    "STAND"
  ];

  late String targetWord;
  int currentRow = 0;
  int currentCol = 0;
  List<List<String>> guesses = List.generate(6, (_) => List.filled(5, ""));
  List<Color> keyboardColors = List.filled(26, Colors.grey);

  @override
  void initState() {
    super.initState();
    targetWord = wordList[Random().nextInt(wordList.length)].toUpperCase();
  }

  void enterGuess() {
    final guess = guesses[currentRow].join();
    if (guess.length == 5) {
      if (wordList.contains(guess)) {
        // Check if the guess is a valid word
        updateKeyboardColors(guess);
        if (guess == targetWord) {
          showEndGameDialog("Congratulations!",
              "You've guessed the correct word: $targetWord");
        } else if (currentRow == 5) {
          // If it's the last row and the guess is incorrect
          showEndGameDialog("Game Over", "The correct word was: $targetWord");
        } else {
          setState(() {
            currentRow++;
            currentCol = 0;
          });
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Invalid Word"),
            content: Text("The word you entered is not in the list."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void deleteLetter() {
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        guesses[currentRow][currentCol] = "";
      });
    }
  }

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

  void resetGame() {
    setState(() {
      targetWord = wordList[Random().nextInt(wordList.length)].toUpperCase();
      currentRow = 0;
      currentCol = 0;
      guesses = List.generate(6, (_) => List.filled(5, ""));
      keyboardColors = List.filled(26, Colors.grey);
    });
  }

  void showEndGameDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text("Play Again"),
          ),
        ],
      ),
    );
  }

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
                child: Container(
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: keyboardColors[
                        letter.codeUnitAt(0) - 'A'.codeUnitAt(0)],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
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
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "ENTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: deleteLetter,
              child: Container(
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
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

  Widget buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      itemCount: 30,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;
        return Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: getColor(row, col),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              guesses[row][col],
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Color getColor(int row, int col) {
    if (row >= currentRow) return Colors.grey[800]!;
    if (targetWord[col] == guesses[row][col]) return Colors.green;
    if (targetWord.contains(guesses[row][col])) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: buildGrid(),
          ),
          SizedBox(height: 7),
          Expanded(
            flex: 3,
            child: buildKeyboard(),
          ),
        ],
      ),
    );
  }
}
