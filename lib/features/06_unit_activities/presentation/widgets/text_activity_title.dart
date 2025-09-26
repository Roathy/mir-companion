import 'package:flutter/material.dart';

class TextActivityTitle extends StatelessWidget {
  const TextActivityTitle({
    super.key,
    required this.currentActivity,
  });

  final dynamic currentActivity;

  @override
  Widget build(BuildContext context) {
    return Text(currentActivity['titulo'],
        style: TextStyle(
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 1), // Shadow color
              offset: Offset(1.8, 1.8), // Shadow offset (x, y)
              blurRadius: 3, // Shadow blur radius
            )
          ],
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ));
  }
}
