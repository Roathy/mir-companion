import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 8.0,
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: 'mironline-logo',
            child: Image.network(
              'https://mironline.io//assets/img/logos/logo_mir_color_cut.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.groups, color: Colors.black),
                onPressed: () {},
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    "120",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1) {
                  } else if (value == 2) {
                  } else if (value == 3) {}
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
