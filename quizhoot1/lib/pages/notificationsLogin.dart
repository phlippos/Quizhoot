import 'package:flutter/material.dart';
import 'package:quizhoot/pages/homePage.dart';

class NotificationsLoginPage extends StatefulWidget {
  const NotificationsLoginPage({super.key});

  @override
  _NotificationsLoginPageState createState() => _NotificationsLoginPageState();
}

class _NotificationsLoginPageState extends State<NotificationsLoginPage> {
  int?
      selectedSessions; // Variable to store the selected number of sessions per week

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Get screen height
    double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set background color
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05), // Horizontal padding
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the content horizontally
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          children: [
            SizedBox(height: height * 0.05), // Space between top and the title

            // App title 'Quizhoot'
            Text(
              'Quizhoot',
              style: TextStyle(
                fontSize:
                    width * 0.09, // Font size proportional to screen width
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: Offset(width * 0.01, height * 0.01),
                    blurRadius: width * 0.02, // Shadow effect
                  ),
                ],
              ),
            ),
            SizedBox(
                height: height * 0.05), // Space between title and next text

            // Main question text
            Text(
              'How often do you want to do a mindfulness session each week?',
              style: TextStyle(
                fontSize:
                    width * 0.06, // Font size proportional to screen width
                fontWeight: FontWeight.bold, // Bold text style
                color: Colors.white,
              ),
              textAlign: TextAlign.center, // Center the text
            ),
            SizedBox(
                height: height *
                    0.02), // Space between question and additional text
            Text(
              'Aim for what feels right to you! You can always change this later.',
              style: TextStyle(
                fontSize:
                    width * 0.04, // Font size proportional to screen width
                color: Colors.grey, // Grey color for secondary text
              ),
              textAlign: TextAlign.center, // Center the text
            ),
            SizedBox(
                height: height * 0.04), // Space between text and choice chips

            // Choice chips for selecting number of sessions
            Wrap(
              alignment: WrapAlignment.center, // Center the chips horizontally
              spacing: 10.0, // Space between the chips
              children: List.generate(7, (index) {
                return ChoiceChip(
                  label: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Adjust chip size based on content
                    children: [
                      Text('${index + 1}'), // Display the number of sessions
                      if (index ==
                          6) // Special label for the last option (7 sessions)
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 8.0), // Space between text
                          child: Text(
                            'Perfect choice!',
                            style: TextStyle(
                              color: Colors
                                  .green, // Encourage the user with a green color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  selected: selectedSessions ==
                      index + 1, // Check if this chip is selected
                  onSelected: (isSelected) {
                    setState(() {
                      selectedSessions = isSelected
                          ? index + 1
                          : null; // Update selected sessions
                    });
                  },
                  selectedColor: Colors.blue, // Color when the chip is selected
                  labelStyle: TextStyle(
                      color: selectedSessions == index + 1
                          ? Colors.white // White text when selected
                          : Colors.black), // Black text when not selected
                  backgroundColor: Colors.white, // Background color of the chip
                );
              }),
            ),
            SizedBox(height: height * 0.04), // Space before the submit button

            // Submit button
            ElevatedButton(
              onPressed: selectedSessions != null
                  ? () {
                      // When selectedSessions is not null, proceed with submission
                      print('Selected sessions per week: $selectedSessions');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const HomePage()), // Navigate to HomePage
                      );
                    }
                  : null, // Disable button if no selection is made
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // White background for the button
                foregroundColor: Colors.black, // Black text on the button
                padding:
                    const EdgeInsets.symmetric(vertical: 12), // Button padding
              ),
              child: const Text('Submit'), // Button text
            ),
          ],
        ),
      ),
    );
  }
}
