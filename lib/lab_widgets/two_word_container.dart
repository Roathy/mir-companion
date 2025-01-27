import 'package:flutter/material.dart';

class TwoWordContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;
  final double height;

  const TwoWordContainer({
    super.key,
    required this.title,
    required this.subtitle,
    this.width = 200, // Default width
    this.height = 100, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      // No decoration to keep container transparent without borders
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title centered
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Subtitle positioned above and slightly to the left
          Positioned(
            bottom: height * 0.6, // Moves it up relative to center
            right: width * 0.55, // Moves it left relative to center
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
