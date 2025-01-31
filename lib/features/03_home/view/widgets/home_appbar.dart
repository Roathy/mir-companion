import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 8.0, // Adds a bit of padding to the title section
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left-aligned icon
          Hero(
            tag: 'mironline-logo',
            child: Image.network(
              'https://mironline.io//assets/img/logos/logo_mir_color_cut.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),

          // Right-aligned elements
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.groups, color: Colors.black), // Icon representing a group of people
                onPressed: () {
                  // Add functionality
                },
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber), // Filled yellow star
                  const SizedBox(width: 4), // Spacing between icon and number
                  Text(
                    "120", // Example score value
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4), // Spacing between score and profile
              // User Profile Menu
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1) {
                    // Navigate to profile
                  } else if (value == 2) {
                    // Help & Support
                  } else if (value == 3) {
                    // Logout
                  }
                },
                itemBuilder: (context) => [
                  _buildMenuItem(1, "Your Profile"),
                  _buildMenuItem(2, "Help & Support"),
                  _buildMenuItem(3, "Logout"),
                ],
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
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
