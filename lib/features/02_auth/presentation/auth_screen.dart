import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../network/api_endpoints.dart';
import '../../03_1_students_profile/students_profile_screen.dart';

// Dio instance and Riverpod providers
final dioProvider = Provider<Dio>((ref) => Dio());
final authTokenProvider = StateProvider<String>((ref) => "");

String createMD5Hash() {
  DateTime now = DateTime.now();
  String formattedDate =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day}';
  return md5.convert(utf8.encode('752486-$formattedDate')).toString();
}

Future<void> login(WidgetRef ref, String email, String password) async {
  if (email.isEmpty || password.isEmpty) return;

  try {
    final dio = ref.read(dioProvider);
    String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsLogin}";

    Response response = await dio.post(
      fullUrl,
      data: {"email": email, "password": password},
      options: Options(headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-App-MirHorizon": createMD5Hash(),
      }),
    );

    String? token = response.data['data']['token'];
    if (token != null && token.isNotEmpty) {
      ref.read(authTokenProvider.notifier).state = token;
    }
  } catch (e) {
    debugPrint("Login error: $e");
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    await login(
        ref, _emailController.text.trim(), _passwordController.text.trim());

    // After login is successful and token is set
    final authToken = ref.read(authTokenProvider);

    // Ensure the token is available
    if (authToken.isNotEmpty) {
      // Navigate to the student profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentTodayScreen()),
      );
    } else {
      // Handle case where the token is not available
      debugPrint("No token found. Login failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, top: 150, right: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'mironline-logo',
                    child: Image.asset('assets/logo.png', width: 240),
                  ),
                  const SizedBox(height: 16),
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          child: Column(spacing: 12, children: [
                            // Title
                            Text("Student Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  color: Colors.blue[400],
                                  fontWeight: FontWeight.bold,
                                )),
                            // Google Login Button
                            _buildGoogleLoginButton(),
                            OrDivider(),
                            // Email Login Row
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.mail_outline,
                                      color: Colors.blue[900]),
                                  const SizedBox(width: 6),
                                  Text("Login with e-mail",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.w400,
                                      ))
                                ]),
                            // Inner Card (Email, Password, Login Button)
                            Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                color: Colors.grey.shade100,
                                elevation: 1,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                    child: Column(spacing: 12, children: [
                                      _buildTextField(_emailController,
                                          "Your e-mail:", false),
                                      _buildTextField(_passwordController,
                                          "Your password:", true),
                                      _buildLoginButton(),
                                    ])))
                          ])))
                ])));
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              color: Colors.purple.shade300,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            )),
        Material(
          elevation: 0, // Default no shadow
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
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            surfaceTintColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Login",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        ));
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Image.asset("assets/images/google_logo.png", height: 24),
        label:
            Text("Login with Google", style: GoogleFonts.poppins(fontSize: 16)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

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
