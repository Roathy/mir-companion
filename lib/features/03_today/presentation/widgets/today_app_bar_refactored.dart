import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/unified_auth_service.dart';
import '../../../02_auth/presentation/screens/auth_screen_refactored.dart';

/// Refactored TodayAppBar using unified authentication services
/// 
/// This widget demonstrates how to use the unified auth service
/// instead of directly accessing the old AuthService.
class TodayAppBarRefactored extends ConsumerWidget implements PreferredSizeWidget {
  final String userName;
  final int mircoins;

  const TodayAppBarRefactored({
    super.key,
    required this.userName,
    required this.mircoins,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8.0,
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildUserSection(context, ref),
        ],
      ),
    );
  }

  /// Build the app logo
  Widget _buildLogo() {
    return Hero(
      tag: 'mironline-logo',
      child: Image.network(
        'https://mironline.io//assets/img/logos/logo_mir_color_cut.png',
        width: 120,
        height: 120,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Build the user section with actions
  Widget _buildUserSection(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildGroupsButton(),
        _buildMircoinsDisplay(),
        const SizedBox(width: 4),
        _buildUserMenu(context, ref),
      ],
    );
  }

  /// Build groups button
  Widget _buildGroupsButton() {
    return IconButton(
      icon: const Icon(Icons.groups, color: Colors.black),
      onPressed: () {
        // TODO: Implement groups functionality
      },
    );
  }

  /// Build mircoins display
  Widget _buildMircoinsDisplay() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          "$mircoins",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  /// Build user menu with logout functionality
  Widget _buildUserMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<int>(
      onSelected: (value) => _handleMenuSelection(value, context, ref),
      itemBuilder: (context) => [
        _buildMenuItem(1, "Your Profile", Icons.person),
        _buildMenuItem(2, "Help & Support", Icons.help),
        _buildMenuItem(3, "Logout", Icons.exit_to_app),
      ],
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          userName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Build menu item with icon
  PopupMenuItem<int> _buildMenuItem(int value, String text, IconData icon) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  /// Handle menu selection
  Future<void> _handleMenuSelection(int value, BuildContext context, WidgetRef ref) async {
    switch (value) {
      case 1:
        _handleProfile(context);
        break;
      case 2:
        _handleHelp(context);
        break;
      case 3:
        await _handleLogout(context, ref);
        break;
    }
  }

  /// Handle profile action
  void _handleProfile(BuildContext context) {
    // TODO: Navigate to profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle help action
  void _handleHelp(BuildContext context) {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle logout using unified auth service
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use unified auth service for logout
      final authService = ref.read(unifiedAuthServiceProvider);
      final success = await authService.logout();

      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        _showSuccessAndNavigate(context);
      } else {
        _showError(context, 'Logout failed. Please try again.');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      _showError(context, 'Error during logout: ${e.toString()}');
    }
  }

  /// Show success message and navigate to login
  void _showSuccessAndNavigate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logout successful!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to login screen after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPageRefactored(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  /// Show error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}