import 'package:flutter/material.dart';
import 'quiz_view.dart';
import 'quiz_creation.dart'; // Quiz oluşturma sayfası için import

class StartQuizView extends StatefulWidget {
  const StartQuizView({super.key});

  @override
  _StartQuizViewState createState() => _StartQuizViewState();
}

class _StartQuizViewState extends State<StartQuizView> {
  String? quizType; // Stores the selected quiz type
  bool useOnlyFavorites = false; // Checkbox state for using only favorite cards

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Quiz'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      backgroundColor: const Color(0xFF3A1078),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Quiz Type:',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            RadioListTile<String>(
              title: const Text(
                'Test',
                style: TextStyle(color: Colors.white),
              ),
              value: 'test',
              groupValue: quizType,
              onChanged: (value) {
                setState(() {
                  quizType = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text(
                'Written',
                style: TextStyle(color: Colors.white),
              ),
              value: 'written',
              groupValue: quizType,
              onChanged: (value) {
                setState(() {
                  quizType = value;
                });
              },
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Use only favorite cards',
                  style: TextStyle(color: Colors.white)),
              value: useOnlyFavorites,
              onChanged: (value) {
                setState(() {
                  useOnlyFavorites = value ?? false;
                });
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateQuizPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text(
                    'Create Quiz',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: quizType == null
                      ? null
                      : () {
                          if (quizType == 'test') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QuizView(
                                    useOnlyFavorites: useOnlyFavorites),
                              ),
                            );
                          } else if (quizType == 'written') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WrittenQuizPlaceholder(),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Start Quiz',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            )
          ],
        ),
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
