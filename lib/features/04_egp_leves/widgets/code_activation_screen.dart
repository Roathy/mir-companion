import 'package:flutter/material.dart';

class CodeActivationScreen extends StatefulWidget {
  const CodeActivationScreen({
    super.key,
  });

  @override
  State<CodeActivationScreen> createState() => _CodeActivationScreenState();
}

class _CodeActivationScreenState extends State<CodeActivationScreen> {
  final TextEditingController _activationController = TextEditingController();

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Material(
            // Make sure the Material widget is transparent
            type: MaterialType.transparency,
            child: Stack(children: [
              // Semi-transparent overlay overlay that covers the entire screen
              Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.3))),
              Container(
                  height: MediaQuery.of(context).size.height * 0.72,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    // boxShadow: [
                    //   BoxShadow(
                    //       color: Colors.black.withOpacity(0.3),
                    //       blurRadius: 10,
                    //       offset: const Offset(0, 4))
                    // ],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContentDetailsForActivation(),
                        ActivationCodeInput(),
                        CancelSubmitButtons(),
                      ]))
            ])));
  }
}

class ContentDetailsForActivation extends StatelessWidget {
  const ContentDetailsForActivation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21.0),
        child: Column(spacing: 9.0, children: [
          const Center(
              child: Icon(Icons.lock_open, color: Colors.lightBlue, size: 30)),
          const Center(
              child: Text('Unlock level',
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          Text.rich(
              TextSpan(
                  text:
                      'Please, enter your activation code to unlock this level. Your code is on your mironline card.\n',
                  children: [
                    TextSpan(
                        text: '\u{26A0} Remember: ',
                        style: TextStyle(color: Colors.red)),
                    TextSpan(text: 'When you activate a new level, '),
                    TextSpan(
                        text: 'you\'ll leave your current group',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: ' to be able to join a new group this semester.')
                  ]),
              style: TextStyle(fontSize: 17))
        ]));
  }
}

class ActivationCodeInput extends StatelessWidget {
  const ActivationCodeInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        spacing: 9.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activation code:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          TextField(
            // controller: _activationController,
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              contentPadding: EdgeInsets.only(left: 9),
              alignLabelWithHint: true,
              hintStyle: TextStyle(color: Colors.black45),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text.rich(
            TextSpan(
                text: '\u{1F625} Lost your mironline card?\t\t',
                style: TextStyle(fontSize: 17),
                children: [
                  TextSpan(
                      text: 'Click here',
                      style: TextStyle(color: Colors.lightBlue)),
                ]),
          ),
        ],
      ),
    );
  }
}

class CancelSubmitButtons extends StatelessWidget {
  const CancelSubmitButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 21.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 9.0,
            children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15),
                  )),
              OutlinedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[100],
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text(
                    'Unlock',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  )),
            ]));
  }
}
