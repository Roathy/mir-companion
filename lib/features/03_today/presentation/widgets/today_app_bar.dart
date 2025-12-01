import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/services/providers.dart';
import '../../../../services/user_data_provider.dart';

import '../../../02_auth/presentation/screens/auth_screen.dart';

class TodayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final int mircoins;

  const TodayAppBar(
      {super.key, required this.userName, required this.mircoins});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8.0,
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'mironline-logo',
            child: Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.groups, color: Colors.grey),
                onPressed: () {
                  Navigator.pushNamed(context, '/join-group');
                },
              ),
              Row(
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
              ),
              const SizedBox(width: 4),
              Consumer(builder: (context, ref, child) {
                return PopupMenuButton<int>(
                  onSelected: (value) async {
                    if (value == 3) {
                      try {
                        await ref.read(authServiceProvider).logoutUser();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logout successful!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error al cerrar sesión: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }

                      // Always perform local cleanup and navigation
                      ref.read(authTokenProvider.notifier).state = '';
                      ref.read(userDataProvider.notifier).clear();

                      // Navigate immediately
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    // _buildMenuItem(1, "Your Profile"),
                    // _buildMenuItem(2, "Help & Support"),
                    _buildMenuItem(3, "Logout"),
                  ],
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _buildMenuItem(int value, String text) {
    return PopupMenuItem<int>(
      value: value,
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
