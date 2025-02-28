import 'package:flutter/material.dart';

class ActivityScore extends StatelessWidget {
  final int score;
  final int totalScore;

  const ActivityScore({
    super.key,
    required this.score,
    this.totalScore = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalScore, (index) {
          // Show success star for indices less than score, otherwise show fail star
          return Icon(Icons.star);
        }));
  }
}
