import 'package:flutter/material.dart';
import 'custom_top_nav.dart'; // Custom top navigation widget
import 'custom_bottom_nav.dart'; // Custom bottom navigation widget
import 'set_inside.dart'; // Imports the page to show individual set details

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

class SetContent extends StatelessWidget {
  const SetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: [
          SetCard(
            setName: 'Set 1',
            termCount: '5 Terms', // Number of terms in the set
            createdBy: 'Creator A', // Set creator's name
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SetInside()), // Navigates to set details page
              );
            },
          ),
          const SizedBox(height: 16), // Spacing between set cards
          SetCard(
            setName: 'Set 2',
            termCount: '8 Terms',
            createdBy: 'Creator B',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SetInside()), // Navigates to set details page
              );
            },
          ),
        ],
      ),
    );
  }
}

class SetCard extends StatelessWidget {
  final String setName; // Name of the set
  final String termCount; // Number of terms in the set
  final String createdBy; // Creator's name
  final VoidCallback onTap; // Function to execute on tap

  const SetCard({
    super.key,
    required this.setName,
    required this.termCount,
    required this.createdBy,
    required this.onTap,
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
          mainAxisSize: MainAxisSize
              .min, // Makes column size minimum based on its children
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_numbered,
                    size: 40), // Icon for set
                const SizedBox(width: 10), // Spacing between icon and text
                Text(
                  setName, // Displays set name
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8), // Spacing between rows
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20), // Icon for term count
                const SizedBox(width: 5),
                Text(termCount), // Displays term count
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20), // Icon for creator
                const SizedBox(width: 5),
                Text(createdBy), // Displays creator's name
              ],
            ),
          ],
        ),
      ),
    );
  }
}
