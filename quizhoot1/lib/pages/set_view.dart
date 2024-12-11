import 'package:flutter/material.dart';
import 'package:quizhoot/pages/flashcard_update.dart';
import 'custom_top_nav.dart';
import 'custom_bottom_nav.dart';
import 'set_inside.dart';

import "flashcard_creation.dart";


class FlashcardViewPage extends StatelessWidget {
  const FlashcardViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: CustomTopNav(initialIndex: 0),
        body: SetContent(),
        backgroundColor: Color(0xFF3A1078),
        bottomNavigationBar: CustomBottomNav(initialIndex: 2),
      ),
    );
  }
}

class SetContent extends StatefulWidget {
  const SetContent({super.key});

  @override
  _SetContentState createState() => _SetContentState();
}

class _SetContentState extends State<SetContent> {

  // List of sets
  final List<Map<String, String>> sets = [
    {'setName': 'Set 1', 'termCount': '5 Terms', 'createdBy': 'Creator A'},
    {'setName': 'Set 2', 'termCount': '8 Terms', 'createdBy': 'Creator B'},
    {'setName': 'Set 3', 'termCount': '12 Terms', 'createdBy': 'Creator C'},
  ];

  // Method to delete a set

  void _deleteSet(int index) {
    setState(() {
      sets.removeAt(index); // Remove the set at the specified index
    });
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < sets.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SetCard(
                setName: sets[i]['setName']!,
                termCount: sets[i]['termCount']!,
                createdBy: sets[i]['createdBy']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetInside(),
                    ),
                  );
                },
                onDelete: () => _deleteSet(i), // Pass delete callback
              ),
            ),
          if (sets.isEmpty)
            const Text(
              'No sets available.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
        ],
      ),

    );
  }
}

class SetCard extends StatelessWidget {
  final String setName;
  final String termCount;
  final String createdBy;
  final VoidCallback onTap;

  final VoidCallback onDelete; // New callback for deleting a set


  const SetCard({
    super.key,
    required this.setName,
    required this.termCount,
    required this.createdBy,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_numbered, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    setName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (context) => const CreateFlashcardPage(),

                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed: onDelete, // Call delete function
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20),
                const SizedBox(width: 5),
                Text(termCount),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20),
                const SizedBox(width: 5),
                Text(createdBy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
