import 'package:flutter/material.dart';
import 'package:quizhoot/pages/flashcard_update.dart';
import 'package:quizhoot/pages/onboarding.dart';
import 'pages/pages.dart';
import 'classes/User.dart';
import 'package:provider/provider.dart';


void main() {
  // Initialize AuthService singleton before running the app

  runApp(
    ChangeNotifierProvider(
      create: (context) => User(),
      child: QuizHoot(),  // Pass AuthService as a dependency
    ),
  );
}

class QuizHoot extends StatelessWidget {

  const QuizHoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const OnboardingPage(),
      routes: {
        '/notificationsLogin': (context) => NotificationsLoginPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/setView': (context) => FlashcardViewPage(),
        '/setInside': (context) => SetInside(),
        '/flashcardUpdate': (context) => UpdateFlashcardPage(),
        '/multipleChoiceQuiz': (context) => QuizView(),
        '/WrittenQuiz': (context) => WrittenQuiz()
      },
    );
  }
}