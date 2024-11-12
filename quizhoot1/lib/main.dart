import 'package:flutter/material.dart';
import 'package:quizhoot/pages/onboarding.dart';

void main() {
  runApp(const QuizHoot());
}

class QuizHoot extends StatelessWidget {
  const QuizHoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: const OnboardingPage());
  }
}
