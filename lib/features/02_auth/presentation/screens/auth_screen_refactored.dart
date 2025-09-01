import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_providers.dart';
import '../states/auth_state.dart';
import '../widgets/widgets.dart';
import '../../../03_today/presentation/screens/today_screen.dart';

/// Refactored authentication screen using clean architecture patterns
/// 
/// This screen demonstrates the proper separation of concerns:
/// - UI logic only in the widget
/// - Business logic in use cases
/// - State management through Riverpod
/// - Dependency injection through providers
class LoginPageRefactored extends ConsumerStatefulWidget {
  const LoginPageRefactored({super.key});

  @override
  LoginPageRefactoredState createState() => LoginPageRefactoredState();
}

class LoginPageRefactoredState extends ConsumerState<LoginPageRefactored> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    // Initialize auth state when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authInitializationProvider);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes for navigation and feedback
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {
          // No action needed for initial state
        },
        loading: () {
          // Loading state is handled in the UI
        },
        authenticated: (user) {
          _handleSuccessfulLogin(user.name ?? user.email);
        },
        unauthenticated: () {
          // Could show a message or clear form
        },
        error: (failure) {
          _showError(failure.message);
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, top: 150, right: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 16),
              _buildLoginCard(authState),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the app logo
  Widget _buildLogo() {
    return Hero(
      tag: 'mironline-logo',
      child: Image.asset('assets/logo.png', width: 240),
    );
  }

  /// Builds the main login card
  Widget _buildLoginCard(AuthState authState) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          spacing: 12,
          children: [
            _buildTitle(),
            _buildGoogleLoginSection(),
            const OrDivider(),
            _buildEmailLoginSection(authState),
          ],
        ),
      ),
    );
  }

  /// Builds the title
  Widget _buildTitle() {
    return Text(
      "Student Login",
      style: GoogleFonts.poppins(
        fontSize: 28,
        color: Colors.blue[400],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the Google login section
  Widget _buildGoogleLoginSection() {
    return const GoogleLoginButton();
  }

  /// Builds the email login section
  Widget _buildEmailLoginSection(AuthState authState) {
    return Column(
      spacing: 12,
      children: [
        _buildEmailLoginHeader(),
        _buildEmailLoginForm(authState),
      ],
    );
  }

  /// Builds the email login header
  Widget _buildEmailLoginHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mail_outline, color: Colors.blue[900]),
        const SizedBox(width: 6),
        Text(
          "Login with e-mail",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.blue[900],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Builds the email login form
  Widget _buildEmailLoginForm(AuthState authState) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      color: Colors.grey.shade100,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          spacing: 12,
          children: [
            _buildEmailField(),
            _buildPasswordField(),
            _buildLoginButton(authState),
          ],
        ),
      ),
    );
  }

  /// Builds the email input field with validation
  Widget _buildEmailField() {
    return LoginTextField(
      controller: _emailController,
      label: "Your e-mail:",
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  /// Builds the password input field with validation
  Widget _buildPasswordField() {
    return LoginTextField(
      controller: _passwordController,
      label: "Your password:",
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  /// Builds the login button that adapts to auth state
  Widget _buildLoginButton(AuthState authState) {
    return authState.when(
      initial: () => LoginButton(handleLogin: _handleLogin),
      loading: () => _buildLoadingButton(),
      authenticated: (_) => _buildSuccessButton(),
      unauthenticated: () => LoginButton(handleLogin: _handleLogin),
      error: (_) => LoginButton(handleLogin: _handleLogin),
    );
  }

  /// Builds the loading button state
  Widget _buildLoadingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null, // Disabled during loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Logging in...",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the success button state
  Widget _buildSuccessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null, // Disabled after success
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Login Successful!",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles the login button press
  void _handleLogin() {
    // Clear any previous errors
    ref.read(authControllerProvider.notifier).clearError();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Trigger login through the controller
    ref.read(authControllerProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  /// Handles successful login
  void _handleSuccessfulLogin(String userName) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Welcome back, $userName! Redirecting..."),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to home screen after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  /// Shows error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}