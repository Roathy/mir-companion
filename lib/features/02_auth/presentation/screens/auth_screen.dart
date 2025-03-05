import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../03_today/presentation/screens/today_screen.dart';
import '../widgets/widgets.dart';

final dioProvider = Provider<Dio>((ref) => Dio());
final authTokenProvider = StateProvider<String>((ref) => "");

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
    if (e is DioException) {
      debugPrint("Login error: ${e.response?.data}");
    }
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
                            GoogleLoginButton(),
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
                                      LoginTextField(
                                          controller: _emailController,
                                          label: "Your e-mail:",
                                          obscureText: false),
                                      LoginTextField(
                                          controller: _passwordController,
                                          label: "Your password:",
                                          obscureText: true),
                                      LoginButton(handleLogin: _handleLogin),
                                    ])))
                          ])))
                ])));
  }
}
