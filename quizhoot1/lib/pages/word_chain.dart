import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const WordChainApp());

class WordChainApp extends StatelessWidget {
  const WordChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WordChainGame(),
    );
  }
}

class WordChainGame extends StatefulWidget {
  const WordChainGame({super.key});

  @override
  _WordChainGameState createState() => _WordChainGameState();
}

class _WordChainGameState extends State<WordChainGame> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _usedWords = [];
  String _currentWord = '';
  int _timeLeft = 20;
  int _score = 0;
  int _highestScore = 0;
  Timer? _timer;
  String _warningMessage = '';
  final TextEditingController _controller = TextEditingController();
  List<String> _wordList = [];
  bool _isLoading = true;
  bool _isGameStarted = false;

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  Future<void> fetchWords() async {
    try {
      final response = await http.get(
        Uri.parse('https://random-word-api.herokuapp.com/word?number=1000'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _wordList = data.map<String>((word) => word.toUpperCase()).toList();
          if (_wordList.isNotEmpty) {
            _currentWord = _wordList[Random().nextInt(_wordList.length)];
            _isLoading = false;
          } else {
            throw Exception('No valid words found.');
          }
        });
      } else {
        throw Exception('Failed to load words: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching words: $e");
    }
  }

  void _startTimer() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('images/timer.mp3'));

    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _audioPlayer.setReleaseMode(ReleaseMode.stop);
          _gameOver();
        }
      });
    });
  }

  void _gameOver() {
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource('images/failure.mp3'));
    _timer?.cancel();
    setState(() {
      _highestScore = _score > _highestScore ? _score : _highestScore;
    });
  }

  Future<void> _checkWord() async {
  String inputWord = _controller.text;
  if (inputWord.isEmpty) return;

  await _audioPlayer.stop();

  if (inputWord[0].toLowerCase() != _currentWord[_currentWord.length - 1].toLowerCase() ||
      _usedWords.contains(inputWord.toLowerCase())) {
    setState(() {
      _warningMessage = 'Invalid word! Try again.';
    });

    await _audioPlayer.play(AssetSource('images/error.mp3'));
    await Future.delayed(const Duration(seconds: 1)); 
  } else {
    bool isWordInDictionary = await _isWordInDictionary(inputWord);
    if (!isWordInDictionary) {
      setState(() {
        _warningMessage = 'This word is not in the dictionary. Try another one!';
      });

      await _audioPlayer.play(AssetSource('images/error.mp3'));
      await Future.delayed(const Duration(seconds: 1)); 
    } else {
      await _audioPlayer.play(AssetSource('images/correct.mp3'));
      await Future.delayed(const Duration(milliseconds: 1000)); 

      setState(() {
        _warningMessage = '';
        _usedWords.add(inputWord.toLowerCase());
        _currentWord = inputWord;
        _score++;
        _timeLeft += 5;
        _controller.clear();
      });
    }
  }

  await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  await _audioPlayer.play(AssetSource('images/timer.mp3'));
}



  Future<bool> _isWordInDictionary(String word) async {
    final response = await http.get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.isNotEmpty;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text(
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
        child: _isLoading
            ? _buildLoadingScreen()
            : !_isGameStarted
                ? _buildStartScreen()
                : (_timeLeft > 0
                    ? _buildGameScreen()
                    : _buildGameOverScreen()),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Colors.yellow,
        ),
        SizedBox(height: 20),
        Text(
          'Loading words...',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
  return Stack(
    children: [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Word Chain!',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGameStarted = true;
                  _startTimer();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
              child: const Text('Play',
                  style: TextStyle(color: Color(0xFF3A1078), fontSize: 20, fontFamily: "Poppins")),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF3A1078), // Arka plan rengi
                    content: Text(
                      "Challenge your vocabulary! Enter a word that starts with the last letter of the previous word. Be quick—the clock is ticking!",
                      style: const TextStyle(
                        color: Colors.yellow, // Yazı rengi
                        fontSize: 16,
                        fontFamily: "Poppins-SemiBold",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.yellow,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}



  Widget _buildGameScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/chain.png',
          height: 150,
        ),
        const SizedBox(height: 20),
        const Text('WORD CHAIN',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                decoration: TextDecoration.underline,
                decorationColor: Color.fromARGB(255, 255, 235, 59))),
        const SizedBox(height: 20),
        Text(
            'Next word must start with letter "${_currentWord[_currentWord.length - 1].toUpperCase()}"',
            style: const TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        const SizedBox(height: 10),
        Text(_currentWord.toUpperCase(),
            style: const TextStyle(
                color: Colors.yellow,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        const SizedBox(height: 20),
        Text('Time Left: $_timeLeft seconds',
            style:
                const TextStyle(color: Colors.yellow, fontFamily: "Poppins")),
        const SizedBox(height: 12),
        if (_warningMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(_warningMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
          ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                _controller.text = value.toUpperCase();
                _controller.selection = TextSelection.fromPosition(TextPosition(
                    offset: _controller.text.length));
              });
            },
            inputFormatters: [UpperCaseTextInputFormatter()],
            decoration: const InputDecoration(
              hintText: 'Type here...',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _checkWord,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
          child:
              const Text('Submit', style: TextStyle(color: Color(0xFF3A1078))),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Game Over',
            style: TextStyle(
                color: Colors.yellow,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins")),
        const SizedBox(height: 20),
        Text('Your Score: $_score',
            style: const TextStyle(
                color: Colors.yellow, fontSize: 20, fontFamily: "Poppins")),
        Text('Highest Score: $_highestScore',
            style: const TextStyle(
                color: Colors.yellow, fontSize: 20, fontFamily: "Poppins")),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _usedWords.clear();
              _score = 0;
              _currentWord = _wordList.isNotEmpty
                  ? _wordList[Random().nextInt(_wordList.length)]
                  : 'PENCIL';
              _warningMessage = '';
              _startTimer();
              _controller.clear();
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
          child: const Text('Play Again',
              style: TextStyle(color: Color(0xFF3A1078))),
        ),
      ],
    );
  }
}

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset),
    );
  }
}


