import 'package:flutter/material.dart';
import 'package:quizhoot/pages/notificationsLogin.dart';
import 'package:sign_in_button/sign_in_button.dart';
// Import the signup page
import 'signUpPage.dart'; // Import the signup page

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height; // Get screen height
    double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: const Color(0xFF3A1078), // Set background color
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: SingleChildScrollView(
          // Enable vertical scrolling
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05),
              // App name
              Text(
                'Quizhoot',
                style: TextStyle(
                  fontSize: width * 0.09,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: Offset(width * 0.01, height * 0.01),
                      blurRadius: width * 0.02,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height: 40), // Space between app name and input fields
              Center(
                child: Column(
                  children: [
                    // Email input field
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    // Password input field
                    TextField(
                      obscureText: true, // Hide password text
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.visibility_off,
                              color: Colors.grey),
                          onPressed: () {
                            // Toggle password visibility
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    // Forgot Password text button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Action when forgot password is clicked
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login button
                    SizedBox(
                      width: double.infinity, // Full-width button
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to HomePage on login
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NotificationsLoginPage(), // Navigate to NotificationsLoginPage
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Google Sign-In button
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            1, // Full width for Google button
                        height: 44, // Height of the Google button
                        child: SignInButton(
                          Buttons.google,
                          text: "Sign in with Google",
                          onPressed: () {},
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Rounded corners for Google button
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Sign up redirect row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const SignUpPage(), // Navigate to SignUpPage
                        ),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
