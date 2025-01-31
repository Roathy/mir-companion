import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ], // Requesting email access
  );

  GoogleSignInAccount? _user;

  Future<void> _signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled login

      setState(() {
        _user = googleUser;
      });

      debugPrint("Signed in as: ${_user!.displayName}");
      debugPrint("Email: ${_user!.email}");
      debugPrint("Profile Pic: ${_user!.photoUrl}");
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $error")),
      );
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Sign-In")),
      body: Center(
        child: _user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sign in with Google"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signIn,
                    icon: Icon(Icons.login),
                    label: Text("Sign in with Google"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoUrl ?? ""),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text("Hello, ${_user!.displayName}"),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: Icon(Icons.logout),
                    label: Text("Sign out"),
                  ),
                ],
              ),
      ),
    );
  }
}
