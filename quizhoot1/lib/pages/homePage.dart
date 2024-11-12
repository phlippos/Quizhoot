import 'package:flutter/material.dart';
import 'package:quizhoot/pages/clasroom_creation.dart';
import 'package:quizhoot/pages/classroomsAll.dart';
import 'package:quizhoot/pages/flashcard_creation.dart';
import 'package:quizhoot/pages/flashcardsAll.dart';
import 'package:quizhoot/pages/folder_creation.dart';
import 'package:quizhoot/pages/quiz_creation.dart';
import 'package:quizhoot/pages/wordle.dart';
import 'package:quizhoot/pages/word_chain.dart';
import 'custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Function to handle bottom navigation item tap events
  void _onItemTapped(int index) {
    setState(() {});
  }

  // Function to show add options as a bottom sheet
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option to create flashcards
              ListTile(
                leading: const Icon(Icons.format_list_bulleted_add,
                    color: Colors.blueAccent),
                title: const Text('Create Flashcards'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateFlashcardPage()),
                  );
                },
              ),
              // Option to create a quiz
              ListTile(
                leading: const Icon(Icons.quiz, color: Colors.orange),
                title: const Text('Create Quiz'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateQuizPage()),
                  );
                },
              ),
              // Option to create a folder
              ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.green),
                title: const Text('Create Folder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateFolderPage()),
                  );
                },
              ),
              // Option to create a classroom
              ListTile(
                leading: const Icon(Icons.school, color: Colors.purple),
                title: const Text('Create Classroom'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateClassroomPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Getting the screen height and width for responsive layout
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.05),
            // Quizhoot title
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
            SizedBox(height: height * 0.030),
            // User welcome message and profile section
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to the QuizHoot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 177, 177, 177),
                      ),
                    ),
                    Text(
                      'Abdullah baba',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CircleAvatar(
                  radius: width * 0.075,
                  backgroundImage:
                      const AssetImage('assets/images/Frame 18.png'),
                ),
              ],
            ),
            SizedBox(height: height * 0.05),
            // Button boxes for navigation to different pages
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Button for Wordle page
                  _buildButtonBox(
                      'Wordle', Icons.quiz, width, height, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WordlePage()),
                    );
                  }),
                  SizedBox(height: height * 0.015),
                  // Button for Word Chain page
                  _buildButtonBox('Word Chain', Icons.videogame_asset, width,
                      height, Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WordChainGame()),
                    );
                  }),
                  SizedBox(height: height * 0.015),
                  // Button for Flashcards page
                  _buildButtonBox('Flashcards', Icons.list_alt, width, height,
                      Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FlashcardsAllPage()),
                    );
                  }),
                  SizedBox(height: height * 0.015),
                  // Button for Classroom page
                  _buildButtonBox(
                      'Classroom', Icons.school, width, height, Colors.amber,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ClassroomsAllPage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating action button to show add options
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        backgroundColor: const Color.fromARGB(255, 150, 100, 255),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Custom bottom navigation bar
      bottomNavigationBar: const CustomBottomNav(initialIndex: 0),
    );
  }

  // Helper function to create a button box for navigation
  Widget _buildButtonBox(String title, IconData icon, double width,
      double height, Color boxColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.110,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(width * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: width * 0.04,
              offset: Offset(width * 0.005, height * 0.01),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: width * 0.08, color: Colors.black),
            SizedBox(width: width * 0.03),
            Text(
              title,
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}