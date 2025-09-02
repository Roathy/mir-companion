import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/unified_auth_service.dart';
import '../02_auth/presentation/screens/auth_screen_refactored.dart';
import '../03_today/presentation/screens/today_screen.dart';

/// Refactored splash screen using unified authentication services
/// 
/// This demonstrates how to check authentication status using the
/// unified auth service instead of directly accessing secure storage.
class AnimatedSplashScreenRefactored extends ConsumerStatefulWidget {
  final bool goHome;
  
  const AnimatedSplashScreenRefactored({
    required this.goHome,
    super.key,
  });

  @override
  AnimatedSplashScreenRefactoredState createState() => 
      AnimatedSplashScreenRefactoredState();
}

class AnimatedSplashScreenRefactoredState 
    extends ConsumerState<AnimatedSplashScreenRefactored>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  /// Initialize the splash animation and auth check
  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Start animation and check auth status
    _controller.forward().whenComplete(() {
      _checkAuthenticationAndNavigate();
    });
  }

  /// Check authentication status and navigate appropriately
  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      final authService = ref.read(unifiedAuthServiceProvider);
      
      // Check if user is authenticated and token is valid
      final isAuthenticated = await authService.isAuthenticated();
      final isTokenValid = await authService.validateToken();

      log('Authentication status: $isAuthenticated, Token valid: $isTokenValid');

      if (mounted) {
        if (isAuthenticated && isTokenValid) {
          _navigateToHome();
        } else {
          _navigateToLogin();
        }
      }
    } catch (e) {
      log('Error checking authentication: $e');
      
      // On error, navigate to login to be safe
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildAnimatedLogo(),
      ),
    );
  }

  /// Build the animated logo
  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.slowMiddle,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'mironline-logo',
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(height: 20),
              _buildLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(
          'Checking authentication...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}