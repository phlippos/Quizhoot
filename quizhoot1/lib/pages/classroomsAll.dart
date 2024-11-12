import 'package:flutter/material.dart';
import 'package:quizhoot/pages/classroom_inside.dart';
import 'custom_bottom_nav.dart';
// Import the custom bottom navigation bar

class ClassroomsAllPage extends StatelessWidget {
  const ClassroomsAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3, // Defines the number of tabs in the TabController
      initialIndex: 0, // The initial tab selected
      child: Scaffold(
        backgroundColor: Color(0xFF3A1078), // Background color of the page
        body: FlashcardsBody(), // The main content of the page
        bottomNavigationBar:
            CustomBottomNav(initialIndex: 0), // Custom navigation bar
      ),
    );
  }
}

class FlashcardsBody extends StatelessWidget {
  const FlashcardsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context), // Header with the title and back button
        const SizedBox(height: 10),
        _buildSearchBar(), // Search bar widget for filtering classrooms
        const Expanded(
            child:
                SetContent()), // Content with the list of classrooms, scrollable
      ],
    );
  }

  // Builds the AppBar with a back button and title
  Widget _buildHeader(BuildContext context) {
    return AppBar(
      title: const Text('All Classrooms'), // Title of the page
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Back arrow icon
        onPressed: () {
          Navigator.pop(context); // Go back to the previous page
        },
      ),
      backgroundColor:
          const Color(0xFF3A1078), // Same background color as the page
    );
  }

  // Builds the search bar to filter classrooms
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search classrooms...', // Placeholder text
          filled: true,
          fillColor: Colors.white, // Background color of the search bar
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide: BorderSide.none, // No border line
          ),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF3A1078)), // Search icon
        ),
      ),
    );
  }
}

class SetContent extends StatelessWidget {
  const SetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Makes the content scrollable if it exceeds screen height
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the items vertically
        children: [
          const SizedBox(height: 16),
          ClassroomCard(
            className: 'Class 1', // Name of the classroom
            studentCount: '17 Students', // Number of students in the class
            teacherName: 'Teacher A', // Teacher's name
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ClassroomInside()), // Navigate to the classroom inside page
              );
            },
          ),
          const SizedBox(height: 16),
          ClassroomCard(
            className: 'Class 2',
            studentCount: '21 Students',
            teacherName: 'Teacher B',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ClassroomInside()),
              );
            },
          ),
          const SizedBox(height: 16),
          ClassroomCard(
            className: 'Class 3',
            studentCount: '20 Students',
            teacherName: 'Teacher C',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ClassroomInside()),
              );
            },
          ),
          const SizedBox(height: 16),
          ClassroomCard(
            className: 'Class 4',
            studentCount: '10 Students',
            teacherName: 'Teacher Baba',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ClassroomInside()),
              );
            },
          ),
          const SizedBox(height: 16),
          ClassroomCard(
            className: 'Class 5',
            studentCount: '33 Students',
            teacherName: 'Teacher Elma',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ClassroomInside()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ClassroomCard extends StatelessWidget {
  final String className;
  final String studentCount;
  final String teacherName;
  final VoidCallback onTap;

  const ClassroomCard({
    super.key,
    required this.className,
    required this.studentCount,
    required this.teacherName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback when the card is tapped
      child: Container(
        width: 300, // Width of the classroom card
        padding: const EdgeInsets.all(16), // Padding inside the card
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the card
          borderRadius:
              BorderRadius.circular(12), // Rounded corners for the card
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Shadow color
              blurRadius: 8, // Blur radius of the shadow
              offset: Offset(0, 2), // Shadow offset
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum space needed
          children: [
            Row(
              children: [
                const Icon(Icons.groups, size: 40), // Icon for group/class
                const SizedBox(width: 10),
                Text(
                  className, // Display the class name
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold), // Text style for class name
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 20), // Icon for student count
                const SizedBox(width: 5),
                Text(studentCount), // Display the number of students
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_circle,
                    size: 20), // Icon for teacher's profile
                const SizedBox(width: 5),
                Text(teacherName), // Display teacher's name
              ],
            ),
          ],
        ),
      ),
    );
  }
}
