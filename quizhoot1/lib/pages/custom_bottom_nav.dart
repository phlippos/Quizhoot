import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:quizhoot/pages/notificationPage.dart';
import 'package:quizhoot/pages/set_view.dart';
import 'homePage.dart';
import 'profilePage.dart';

class CustomBottomNav extends StatelessWidget {
  final int initialIndex;

  const CustomBottomNav({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return GNav(
      gap: 8, // Space between the icons
      backgroundColor:
          Colors.grey, // Background color for the bottom navigation bar
      color: Colors.white, // Color for unselected tab icons
      activeColor: Colors.black, // Color for the active tab icon
      tabBackgroundColor:
          Colors.white, // Background color when a tab is selected
      selectedIndex: initialIndex, // Set the initial index to the provided one
      onTabChange: (index) {
        // Handles the tab change based on selected index
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const FlashcardViewPage()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            break;
        }
      },
      tabs: const [
        // Home tab
        GButton(
          icon: Icons.home,
          text: 'Home',
        ),
        // Notifications tab
        GButton(
          icon: Icons.notifications,
          text: 'Notifications',
        ),
        // My Library tab
        GButton(
          icon: Icons.folder,
          text: 'My Library',
        ),
        // Profile tab
        GButton(
          icon: Icons.account_circle,
          text: 'Profile',
        ),
      ],
    );
  }
}