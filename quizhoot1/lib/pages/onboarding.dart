import 'package:flutter/material.dart';
import 'package:quizhoot/pages/loginPage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Welcome to the Quizhoot',
    'What is Quizhoot?',
    'Ready to begin?',
  ];

  final List<String> _descriptions = [
    'Here’s a good place to boost your vocabulary and learning experience!',
    'Quizhoot is an interactive platform that helps users learn and retain information through tools like flashcards, quizzes, and games.',
    'Let’s make each card a step toward mastering something new!',
  ];

  final List<String> _images = [
    'assets/images/Welcome!.png',
    'assets/images/Welcome2.png',
    'assets/images/Welcome3.png',
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: _titles.length,
        itemBuilder: (context, index) {
          return _buildPage(index, height, width);
        },
      ),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  // Builds individual pages for onboarding flow
  Widget _buildPage(int index, double height, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.05),
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
          SizedBox(height: height * 0.05),
          Center(
            child: Column(
              children: [
                // Display image for each page
                Image.asset(
                  _images[index],
                  height: height * 0.3,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: height * 0.02),
                Text(
                  _titles[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.015),
                Text(
                  _descriptions[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.045,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds bottom sheet with navigation controls
  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF3A1078),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              _pageController.jumpToPage(_titles.length - 1);
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Row(
            children: List.generate(
              _titles.length,
              (index) => _buildDot(index),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _titles.length - 1) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _currentPage == _titles.length - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a dot indicator for each page in the onboarding process
  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
