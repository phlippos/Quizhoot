import 'package:flutter/material.dart';
import 'package:quizhoot/pages/flashcard_update.dart';
import 'package:quizhoot/pages/folder_inside.dart';
import 'package:quizhoot/pages/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/pages.dart';
import 'classes/User.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Initialize AuthService singleton before running the app
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding") ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (context) => User(),
      child:
          QuizHoot(onboarding: onboarding), // Pass AuthService as a dependency
    ),
  );
}

class QuizHoot extends StatelessWidget {
  final bool onboarding;

  const QuizHoot({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: onboarding ? const LoginPage() : const OnboardingPage(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/notificationsLogin': (context) => const NotificationsLoginPage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/setView': (context) => const FlashcardViewPage(),
        '/setInside': (context) => const SetInside(),
        '/flashcardUpdate': (context) => const UpdateFlashcardPage(),
        '/multipleChoiceQuiz': (context) => const QuizView(),
        '/WrittenQuiz': (context) => const WrittenQuiz(),
        '/classroomCreate': (context) => const CreateClassroomPage(),
        '/classroomView': (context) => const ClassroomViewPage(),
        '/classroomInside': (context) => const ClassroomInside(),
        '/classroomMembers': (context) => const ClassroomMembers(),
        '/classroomFolders': (context) => const ClassroomFolders(),
        '/folderInside': (context) => const FolderInside(),
        '/cards': (context) => const CardsPage(),
        '/scrambledGame': (context) => const ScrambledGame(),
        '/classroomFolderInside': (context) => const ClassroomFolderInside(),
        '/forgetPassword': (context) => const ForgetPasswordPage(),
      },
    );
  }
}
