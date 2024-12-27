import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';
import '../classes/Set.dart'; // Import the Set model

class FlashcardsAllPage extends StatelessWidget {
  const FlashcardsAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Defines the number of tabs (if needed)
      initialIndex: 0, // Sets the initial tab index
      child: Scaffold(
        backgroundColor: Color(0xFF3A1078), // Sets background color
        body: FlashcardsBody(), // Main content of the page
        bottomNavigationBar: CustomBottomNav(
            initialIndex: 0), // Custom navigation bar at the bottom
      ),
    );
  }
}

class FlashcardsBody extends StatefulWidget {
  const FlashcardsBody({super.key});

  @override
  _FlashcardsBodyState createState() => _FlashcardsBodyState();
}

class _FlashcardsBodyState extends State<FlashcardsBody> {
  bool _isLoading = true;
  List<Set> _sets = [];
  List<Set> _filteredSets = [];

  @override
  void initState() {
    super.initState();
    _fetchSets();
  }

  Future<void> _fetchSets() async {
    final sets = await Set.fetchAllSets();
    setState(() {
      _sets = sets;
      _filteredSets = sets;
      _isLoading = false;
    });
  }

  void _filterSets(String query) {
    setState(() {
      _filteredSets = _sets
          .where((set) => set.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context), // AppBar with title and back button
        const SizedBox(height: 10), // Adds space below header
        _buildSearchBar(), // Search bar for filtering flashcards
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SetContent(sets: _filteredSets), // Displays flashcards in a scrollable area
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppBar(
      title: const Text('All Flashcards'), // Title of the page
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Back button icon
        onPressed: () {
          Navigator.pop(context); // Navigates to the previous page
        },
      ),
      backgroundColor: const Color(0xFF3A1078), // AppBar background color
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search flashcards...', // Placeholder text in search bar
          filled: true, // Enables background fill color
          fillColor: Colors.white, // Background color of the search bar
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide: BorderSide.none, // Removes border outline
          ),
          prefixIcon: const Icon(Icons.search,
              color: Color(0xFF3A1078)), // Search icon inside text field
        ),
        onChanged: _filterSets, // Calls _filterSets on text change
      ),
    );
  }
}

class SetContent extends StatelessWidget {
  final List<Set> sets; // List of sets to display

  const SetContent({super.key, required this.sets});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Makes content scrollable
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32), // Adds space above each set
          ...sets.map((set) => Column(
            children: [
              SetCard(
                setName: set.name,
                termCount: '${set.size} Terms',
                createdBy: set.creatorName,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/setInside',
                    arguments: set,
                  );
                },
              ),
              const SizedBox(height: 16), // Adds space between sets
            ],
          )),
        ],
      ),
    );
  }
}

class SetCard extends StatelessWidget {
  final String setName; // Name of the flashcard set
  final String termCount; // Number of terms in the set
  final String createdBy; // Creator's name
  final VoidCallback onTap; // Action to take on tap

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
      onTap: onTap, // Calls the onTap action when tapped
      child: Container(
        width: 300, // Width of each set card
        padding: const EdgeInsets.all(16), // Inner padding for card content
        decoration: BoxDecoration(
          color: Colors.white, // Card background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 8, // Blur level of the shadow
              offset: Offset(0, 2), // Offset for the shadow position
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjusts height based on content
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_numbered,
                    size: 40), // Icon for set
                const SizedBox(width: 10), // Space between icon and text
                Text(
                  setName, // Displays set name
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8), // Space between rows
            Row(
              children: [
                const Icon(Icons.workspaces, size: 20), // Icon for term count
                const SizedBox(width: 5), // Space between icon and text
                Text(termCount), // Displays term count
              ],
            ),
            const SizedBox(height: 4), // Space between rows
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20), // Icon for creator
                const SizedBox(width: 5), // Space between icon and text
                Text(createdBy), // Displays creator's name
              ],
            ),
          ],
        ),
      ),
    );
  }
}
