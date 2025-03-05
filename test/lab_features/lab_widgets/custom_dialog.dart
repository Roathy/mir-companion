import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({super.key});

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _isChecked = false; // State for the checkbox

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Dialog background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Make the column take only the space it needs
        children: [
          // Row with Checkbox and Label
          Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false; // Update the checkbox state
                  });
                },
              ),
              Text(
                'Don\'t show this again',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 20), // Spacing between the row and the button
          // Button
          ElevatedButton(
            onPressed: () {
              // Handle button press
              Navigator.of(context).pop(_isChecked); // Return the checkbox state
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
