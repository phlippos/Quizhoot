import 'package:flutter/material.dart';
import 'package:quizhoot/pages/custom_bottom_nav.dart';
import 'settings.dart'; // New settings page added

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true; // Initial state for notifications
  bool _soundEnabled = true; // Initial state for sound
  double _soundLevel = 0.5; // Sound level (between 0.0 and 1.0)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A1078),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1078),
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50, // Profile image size
                backgroundImage: AssetImage(
                    'assets/images/Frame 18.png'), // Profile image URL
              ),
              const SizedBox(height: 16),
              const Text(
                'abdullahbaba@gmail.com', // Email text
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  // Navigate to settings page when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
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
                  child: const Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notifications button with toggle switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Notification settings action can be added here
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
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
                      child: const Center(
                        child: Text(
                          'Notifications',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled, // Toggle notification state
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value; // Update state
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sound settings toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sound',
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: _soundEnabled, // Sound toggle state
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value; // Update sound state
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sound volume slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Volume',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: _soundLevel,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() {
                          _soundLevel = value; // Update sound level
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                      '${(_soundLevel * 100).round()}%'), // Display current volume level
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          const CustomBottomNav(initialIndex: 3), // Custom bottom navigation
    );
  }
}
