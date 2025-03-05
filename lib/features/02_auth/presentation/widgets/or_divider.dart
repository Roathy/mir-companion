import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: Divider(
        color: Colors.grey.shade400,
        thickness: 1,
      )),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text("or",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
              ))),
      Expanded(
          child: Divider(
        color: Colors.grey.shade400,
        thickness: 1,
      ))
    ]);
  }
}
