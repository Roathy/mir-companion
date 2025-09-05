import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../03_today/presentation/screens/today_screen.dart';
import '../widgets/widgets.dart';

enum LoginStatus { success, failure, error }

class LoginResult {
  final LoginStatus status;
  final String? message;

  LoginResult({required this.status, this.message});
}

final dioProvider = Provider<Dio>((ref) => Dio());
final authTokenProvider = StateProvider<String>((ref) => "");

Future<LoginResult> login(WidgetRef ref, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return LoginResult(
        status: LoginStatus.failure,
        message: "Email and password cannot be empty");
  }

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

    if (response.data["success"] == true) {
      String? token = response.data['data']['token'];

      if (token != null && token.isNotEmpty) {
        final storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);

        ref.read(authTokenProvider.notifier).state = token;
        return LoginResult(status: LoginStatus.success);
      }
    }
  } on DioException catch (e) {
    debugPrint('Network error: ${e.message}');
    debugPrint('Status code: ${e.response?.statusCode}');
    debugPrint('Response data: ${e.response?.data}');
    // Handle error response
    final errorMessage = e.response?.data['error']['message'];
    return LoginResult(
        status: LoginStatus.failure,
        message: errorMessage ?? 'Something failed, try again later.');
  } catch (e) {
    debugPrint("Login error: $e");
    return LoginResult(status: LoginStatus.error, message: e.toString());
  }

  return LoginResult(
      status: LoginStatus.failure,
      message: "Login failed due to an unknown error");
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
    LoginResult result = await login(
      ref,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return; // Check if the widget is still in the tree.

    if (result.status == LoginStatus.success) {
      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login successful! Redirecting..."),
            duration: Duration(seconds: 2)),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentTodayScreen()),
          );
        }
      });
    } else {
      // Show failure message from the server in the SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.message ?? "Login failed."),
            duration: const Duration(seconds: 2)),
      );
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
                            Text(
                              "Student Login",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                color: Colors.blue[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GoogleLoginButton(),
                            OrDivider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mail_outline,
                                    color: Colors.blue[900]),
                                const SizedBox(width: 6),
                                Text(
                                  "Login with e-mail",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
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
                                        label: "Your e-mail",
                                        obscureText: false,
                                      ),
                                      LoginTextField(
                                        controller: _passwordController,
                                        label: "Your password",
                                        obscureText: true,
                                      ),
                                      LoginButton(handleLogin: _handleLogin),
                                    ])))
                          ])))
                ])));
  }
}
