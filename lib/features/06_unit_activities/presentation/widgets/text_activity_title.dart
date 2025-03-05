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
              color: Colors.black.withOpacity(0.8), // Shadow color
              offset: Offset(2, 2), // Shadow offset (x, y)
              blurRadius: 9, // Shadow blur radius
            )
          ],
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ));
  }
}
