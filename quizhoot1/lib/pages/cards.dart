import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final List<Map<String, String>> flashcards = [
    {'term': 'Apple', 'definition': 'Apfel'},
    {'term': 'Apricot', 'definition': 'Aprikose'},
    {'term': 'Cherry', 'definition': 'Kirsche'},
    {'term': 'Melon', 'definition': 'Melone'},
    {'term': 'Pear', 'definition': 'Birne'},
  ];

  int currentIndex = 0; // Tracks the current card index
  Offset _dragOffset = Offset.zero; // Tracks the swipe offset
  double _opacity = 1.0; // Controls the card's opacity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: const Color(0xFF3A1078),
      ),
      body: Center(
        child: currentIndex < flashcards.length
            ? GestureDetector(
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
                  flashcards[currentIndex]['term']!,
                  _getCardColor(),
                ),
                back: _buildCardFace(
                  flashcards[currentIndex]['definition']!,
                  _getCardColor(),
                ),
              ),
            ),
          ),
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
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
      } else {
        currentIndex = flashcards.length; // Finish cards
      }
    });
  }

  // Swipe left to mark as incorrect
  void _swipeLeft() {
    setState(() {
      _dragOffset = Offset.zero;
      _opacity = 1.0;
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
      } else {
        currentIndex = flashcards.length; // Finish cards
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