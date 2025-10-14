import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/services/providers.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CodeActivationScreen extends StatefulWidget {
  const CodeActivationScreen({
    super.key,
  });

  @override
  State<CodeActivationScreen> createState() => _CodeActivationScreenState();
}

class _CodeActivationScreenState extends State<CodeActivationScreen> {
  final TextEditingController _activationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Material(
            type: MaterialType.transparency,
            child: Stack(children: [
              Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.3))),
              Container(
                  height: MediaQuery.of(context).size.height * 0.72,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ContentDetailsForActivation(),
                        ActivationCodeInput(controller: _activationController),
                        CancelSubmitButtons(
                          activationController: _activationController,
                          isLoading: _isLoading,
                          setLoading: _setLoading,
                        ),
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
        child: Column(children: [
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
                    const TextSpan(
                        text: '\u{26A0} Remember: ',
                        style: TextStyle(color: Colors.red)),
                    const TextSpan(text: 'When you activate a new level, '),
                    const TextSpan(
                        text: 'you\'ll leave your current group',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: ' to be able to join a new group this semester.')
                  ]),
              style: const TextStyle(fontSize: 17))
        ]));
  }
}

class ActivationCodeInput extends StatelessWidget {
  const ActivationCodeInput({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activation code:',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              contentPadding: const EdgeInsets.only(left: 9),
              alignLabelWithHint: true,
              hintStyle: const TextStyle(color: Colors.black45),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45)),
              focusedBorder: const OutlineInputBorder(
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
                style: const TextStyle(fontSize: 17),
                children: [
                  const TextSpan(
                      text: 'Click here',
                      style: TextStyle(color: Colors.lightBlue)),
                ]),
          ),
        ],
      ),
    );
  }
}

class CancelSubmitButtons extends ConsumerWidget {
  const CancelSubmitButtons({
    super.key,
    required this.activationController,
    required this.isLoading,
    required this.setLoading,
  });

  final TextEditingController activationController;
  final bool isLoading;
  final Function(bool) setLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.only(right: 21.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15),
                  )),
              OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setLoading(true);
                          try {
                            final response = await ref
                                .read(authServiceProvider)
                                .unlockLevel(activationController.text);
                            setLoading(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? 'Level unlocked successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true); // Return true to indicate success
                          } catch (e) {
                            setLoading(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Unlock',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        )),
            ]));
  }
}
