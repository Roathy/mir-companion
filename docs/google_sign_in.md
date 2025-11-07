Fixing Google Sign-In Errors in google_sign_in 7.2.0
The error you're encountering is due to breaking API changes in google_sign_in version 7.x compared to the older API. The constructor pattern no longer works, and the authentication method has changed significantly.​

The Core Problem
Starting with google_sign_in 7.1.1 and continuing in 7.2.0:​

The constructor with parameters (GoogleSignIn(scopes: [...])) has been removed

The signIn() method no longer exists

You must use GoogleSignIn.instance instead

Initialization is now mandatory with initialize()

Authentication uses authenticate() method instead of signIn()

Authentication is now event-driven

Solution: Updated Implementation
Replace your auth_service.dart and auth_screen.dart with this pattern:
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // TODO: Get your Web Client ID from Google Cloud Console
  // (APIs & Services > Credentials > OAuth 2.0 Client IDs > Web application)
  final String? _serverClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  Future<void> _initializeGoogleSignIn() async {
    if (_isInitialized) return;
    try {
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      
      return googleUser;
    } on GoogleSignInException catch (e) {
      print('Google Sign In error: $e');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
Update your auth_screen.dart:
import 'package:google_sign_in/google_sign_in.dart';
import 'path/to/auth_service.dart'; // Import your auth service

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = 
          await _authService.signInWithGoogle();
      
      if (googleUser != null) {
        print('Signed in: ${googleUser.email}');
        // Navigate to next screen or update UI
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleGoogleSignIn,
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}

Critical Setup Steps
Obtain your Web Client ID from Google Cloud Console:

Go to APIs & Services > Credentials

Find your Web application OAuth 2.0 Client ID (NOT the Android one)

Copy the client ID and replace YOUR_WEB_CLIENT_ID in the code above

Ensure google-services.json is configured (for Android) in your android/app/ directory with the correct Web client ID

Update pubspec.yaml to confirm you have google_sign_in 7.2.0 or similar:
Initialize before use - Always call _initializeGoogleSignIn() before calling authenticate()