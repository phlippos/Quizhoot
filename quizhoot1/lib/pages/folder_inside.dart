import 'package:flutter/material.dart';
import 'custom_top_nav.dart'; // Custom top navigation widget
import 'custom_bottom_nav.dart'; // Custom bottom navigation widget
import 'set_inside.dart'; // Imports the page to show individual set details
import 'package:provider/provider.dart'; // For managing state and actions

class FolderInside extends StatelessWidget {
  const FolderInside({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Defines the number of tabs
      initialIndex: 1, // Sets the initial tab index
      child: Scaffold(
        appBar: CustomTopNav(
            initialIndex: 1), // Custom top navigation bar with a specific index
        body: SetContent(), // Body content with a list of sets
        backgroundColor: Color(0xFF3A1078), // Background color for the scaffold
        bottomNavigationBar:
        CustomBottomNav(initialIndex: 2), // Custom bottom navigation bar
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
  List<Set> sets = [
    Set(name: 'Set 1', size: 5, creator: 'Creator A'),
    Set(name: 'Set 2', size: 8, creator: 'Creator B'),
  ];

  // Delete set method
  void _deleteSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sets.map((set) {
          return Column(
            children: [
              SetCard(
                  set: set,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetInside(),
                      ),
                    );
                  },
                  onDelete: () => _deleteSet(sets.indexOf(set)),
                  onEdit: () => {}),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class SetCard extends StatelessWidget {
  final Set set;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SetCard({
    super.key,
    required this.set,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Executes the onTap function when tapped
      child: Container(
        width: 300, // Width of the card
        padding: const EdgeInsets.all(16), // Padding inside the card
        decoration: BoxDecoration(
          color: Colors.white, // Card background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 8, // Shadow blur effect
              offset: Offset(0, 2), // Shadow position
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
                    set.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF3A1078)),
                    onPressed: () => {}
                  //     // should be similar to flashcard_update.dart
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF3A1078)),
                  onPressed:
                  onDelete, // Executes the onDelete function when pressed
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20),
                const SizedBox(width: 5),
                Text(set.size.toString()),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20),
                const SizedBox(width: 5),
                Text(set.creator),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Assuming Set class definition
class Set {
  final String name;
  final int size;
  final String creator;

  Set({required this.name, required this.size, required this.creator});
}