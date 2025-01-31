import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print("User Signed In: ${googleUser.displayName}");
        _showSnackbar("Signed in as ${googleUser.displayName}");
      } else {
        _showSnackbar("Google Sign-In cancelled");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      _showSnackbar("Sign-In Failed");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'mironline-logo',
                  child: Image.network(
                    'https://mironline.io//assets/img/logos/logo_mir_color_cut.png', // Path to your PNG
                    width: 240, // Set an appropriate size
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Login to continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 150, left: 24, right: 24, child: OrDivider()),

          // Google Sign-In Button Positioned at Bottom
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                icon: Image.asset(
                  "assets/images/google_logo.png", // Make sure you add a Google logo image in assets
                  height: 24,
                ),
                label: Text(
                  "Login with Google",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding around the container
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey, // Gray line color
              thickness: 1.0, // Line thickness
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0), // Padding around "or"
            child: Text(
              "or",
              style: TextStyle(
                fontSize: 16.0, // Font size for "or"
                color: Colors.black, // Color of the text
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey, // Gray line color
              thickness: 1.0, // Line thickness
            ),
          ),
        ],
      ),
    );
  }
}
