import 'package:flutter/material.dart';

class DisplayActivityScore extends StatelessWidget {
  final int currentScore;
  final Color starColor;
  static const int maxScore = 3;

  const DisplayActivityScore({
    super.key,
    required this.currentScore,
    this.starColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 81, // Ensuring a defined width for the stars
        height: 42, // Increased height to accommodate the middle star
        child: Stack(
            children: List.generate(maxScore, (index) {
          // Calculate the size of the star
          final double starSize = index == 1 ? 36 : 27; // Middle star is larger

          // Calculate the position of the star
          final double topOffset = index == 0
              ? 0
              : index == 1
                  ? -6 // Middle star slightly overlaps the others
                  : 0; // Right star position
          // Calculate the position of the star
          final double leftOffset = index == 0
              ? 0
              : index == 1
                  ? 20 // Middle star slightly overlaps the others
                  : 50; // Right star position
          return Positioned(
            top: topOffset,
            left: leftOffset,
            child: Icon(
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5, // Larger shadow
                  offset: const Offset(2, 2), // Bottom-right orientation
                )
              ],
              Icons.star,
              size: starSize,
              color: index < currentScore ? starColor : Colors.white,
            ),
          );
        })));
  }
}
