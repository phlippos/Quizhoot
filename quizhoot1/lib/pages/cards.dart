import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:quizhoot/classes/Flashcard.dart';
import '../classes/Set.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {

  List<Flashcard> unknownWords = [];
  int currentIndex = 0; // Tracks the current card index
  int correctCount = 0; // Number of correct answers (swiped right)
  int incorrectCount = 0; // Number of incorrect answers (swiped left)
  Offset _dragOffset = Offset.zero; // Tracks the swipe offset
  double _opacity = 1.0; // Controls the card's opacity
  late List<Flashcard> flashcards;
  late Set _set;
  @override
  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
    _set = ModalRoute.of(context)?.settings.arguments as Set;
    flashcards = _set.getFlashcards();
    unknownWords.addAll(flashcards); // Initially all words are unknown
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: Center(
        child: unknownWords.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Known and Unknown Counts
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Known: $correctCount Unknown: ${unknownWords.length}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dragOffset += details.delta;
                });
              },
              onPanEnd: (details) {
                if (_dragOffset.dx > 200) {
                  _swipeRight(); // Swipe right to the next card
                } else if (_dragOffset.dx < -200) {
                  _swipeLeft(); // Swipe left to the next card
                } else {
                  setState(() {
                    _dragOffset = Offset.zero; // Reset position
                    _opacity = 1.0; // Reset opacity
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(
                  _dragOffset.dx,
                  0, // Vertical movement is fixed
                  0,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _opacity,
                  child: FlipCard(
                    key: ValueKey(currentIndex), // Reset flip state
                    front: _buildCardFace(
                      unknownWords[currentIndex].term,
                      _getCardColor(),
                    ),
                    back: _buildCardFace(
                      unknownWords[currentIndex].definition,
                      _getCardColor(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
            : const Text(
          'All cards finished!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      backgroundColor: const Color(0xff3A1078),
    );
  }

  // Swipe right to mark as correct
  void _swipeRight() {
    setState(() {
      _dragOffset = Offset.zero;
      _opacity = 1.0;
      correctCount++; // Increment correct count for swipe right
      // Remove the card from unknownWords only when swiped right
      unknownWords.removeAt(currentIndex);

      // Ensure the current index stays within the bounds
      if (currentIndex >= unknownWords.length) {
        currentIndex = unknownWords.length -
            1; // If we reached the end, reset to the last card
      }
    });
  }

  // Swipe left to mark as incorrect
  void _swipeLeft() {
    setState(() {
      _dragOffset = Offset.zero;
      _opacity = 1.0;
      incorrectCount++; // Increment incorrect count for swipe left
      // Do not remove the card, just move it to the back
      Flashcard currentCard = unknownWords[currentIndex];
      unknownWords.add(currentCard); // Add the card back to the list
      unknownWords.removeAt(currentIndex); // Remove it from the current index

      // Ensure the current index stays within the bounds
      if (currentIndex >= unknownWords.length) {
        currentIndex = unknownWords.length -
            1; // If we reached the end, reset to the last card
      }
    });
  }

  // Get card color dynamically
  Color _getCardColor() {
    if (_dragOffset.dx > 0) {
      return Colors.green.withOpacity((_dragOffset.dx / 200).clamp(0.0, 1.0));
    } else if (_dragOffset.dx < 0) {
      return Colors.red.withOpacity((-_dragOffset.dx / 200).clamp(0.0, 1.0));
    }
    return Colors.white;
  }

  // Build a single card face
  Widget _buildCardFace(String text, Color color) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

