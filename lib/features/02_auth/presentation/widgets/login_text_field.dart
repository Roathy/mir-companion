import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  const LoginTextField(
      {super.key,
      required this.controller,
      required this.label,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
            color: Colors.purple.shade300,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          )),
      Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
              controller: controller,
              keyboardType:
                  obscureText ? TextInputType.text : TextInputType.emailAddress,
              obscureText: obscureText,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.blue.shade400, width: 1),
                  ))))
    ]);
  }
}
