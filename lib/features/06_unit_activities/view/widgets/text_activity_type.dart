import 'package:flutter/material.dart';

class TextActivityType extends StatelessWidget {
  const TextActivityType({
    super.key,
    required this.currentActivity,
  });

  final dynamic currentActivity;

  @override
  Widget build(BuildContext context) {
    return Text(currentActivity['tipo'], // The skill type text
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            shadows: [
              Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: Offset(1, 1),
                  blurRadius: 9.0)
            ]));
  }
}
