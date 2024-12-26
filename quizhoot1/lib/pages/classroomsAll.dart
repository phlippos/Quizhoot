import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizhoot/pages/classroom_inside.dart';
import 'package:quizhoot/services/classroom_service.dart'; // Make sure to import the ClassroomService for fetching classrooms
import 'custom_bottom_nav.dart';
import 'package:quizhoot/classes/Classroom.dart'; // Import the Classroom class
import '../classes/User.dart';

// Main ClassroomsAllPage to display classrooms with tabs and bottom navigation
// Main ClassroomsAllPage to display classrooms with tabs and bottom navigation
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
        bottomNavigationBar: CustomBottomNav(initialIndex: 0), // Custom navigation bar
      ),
    );
  }
}

// Body widget for the FlashcardsPage containing the header and the SetContent
class FlashcardsBody extends StatelessWidget {
  const FlashcardsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context), // Header with the title and back button
        const SizedBox(height: 10),
        const Expanded(child: SetContent()), // Content with the list of classrooms, scrollable
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
      backgroundColor: const Color(0xFF3A1078), // Same background color as the page
    );
  }
}
// Stateful widget to handle classroom data fetching and display dynamically
class SetContent extends StatefulWidget {
  const SetContent({super.key});

  @override
  _SetContentState createState() => _SetContentState();
}

// Stateful widget to handle classroom data fetching and display dynamically
class _SetContentState extends State<SetContent> {
  List<Classroom> _classrooms = [];
  List<Classroom> _filteredClassrooms = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  late User _user;
  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context,listen:false);
    _fetchClassrooms();
    _searchController.addListener(_filterClassrooms); // Listen for search input changes
  }

  // Fetch classrooms from ClassroomService
  Future<void> _fetchClassrooms() async {
    try {
      List<Classroom> classrooms = await Classroom.getAllClassrooms();
      setState(() {
        _classrooms = classrooms;
        _filteredClassrooms = classrooms; // Initially show all classrooms
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load classrooms: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter classrooms based on the search query
  void _filterClassrooms() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClassrooms = _classrooms
          .where((classroom) =>
          classroom.classroomName.toLowerCase().contains(query))
          .toList();
    });
  }

  // Method to handle the join action
  Future<void> _joinClassroom(Classroom classroom) async {
    try {
      final response = await classroom.joinClassroom(_user); // Add the method to join classroom
      if (response) {
        // Successfully joined, show a success message or update UI
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Joined ${classroom.classroomName} successfully!'),
        ));
        setState(() {
          _classrooms;
        });
        // Optionally, reload classrooms or update the UI
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to join the classroom.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error joining the classroom. $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search classrooms...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3A1078)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._filteredClassrooms.map((classroom) {
            return Column(
              children: [
                ClassroomCard(
                  className: classroom.classroomName,
                  studentCount: '${classroom.size} Students',
                  teacherName: classroom.creatorName,
                  onTap: () {

                  },
                  onJoin: () => _joinClassroom(classroom), // Handle the join button click
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


// Widget for displaying each classroom as a card
class ClassroomCard extends StatelessWidget {
  final String className;
  final String studentCount;
  final String teacherName;
  final VoidCallback onTap;
  final VoidCallback onJoin;

  const ClassroomCard({
    super.key,
    required this.className,
    required this.studentCount,
    required this.teacherName,
    required this.onTap,
    required this.onJoin,  // Adding the join callback
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
          borderRadius: BorderRadius.circular(12), // Rounded corners for the card
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
                      fontSize: 20, fontWeight: FontWeight.bold), // Text style for class name
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
                const Icon(Icons.account_circle, size: 20), // Icon for teacher's profile
                const SizedBox(width: 5),
                Text(teacherName), // Display teacher's name
              ],
            ),
            const SizedBox(height: 16),
            // Add the Join button here
            ElevatedButton(
              onPressed: onJoin, // When pressed, call the onJoin callback
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
