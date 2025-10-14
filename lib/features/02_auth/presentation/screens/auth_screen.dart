import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mironline/services/device-id/device_info_repo_impl.dart';
import 'package:mironline/services/device-id/presentation/login_view_model.dart';
import 'package:app_set_id/app_set_id.dart';
import 'package:mironline/services/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final authTokenProvider = StateProvider<String>((ref) => "");

Future<LoginResult> login(WidgetRef ref, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return LoginResult(
        status: LoginStatus.failure,
        message: "Email and password cannot be empty");
  }

  try {
    final apiClient = ref.read(apiClientProvider);
    String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsLogin}";

    final appSetIdPlugin = AppSetId();
    final deviceInfoRepository = DeviceInfoRepoImpl(appSetIdPlugin);
    final loginViewModel = LoginViewModel(deviceInfoRepository);
    final appSetId = await loginViewModel.login();

    Response response = await apiClient.dio.post(
      fullUrl,
      data: {
        "email": email,
        "password": password,
        "device_id": appSetId,
      },
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
    // TODO: Add proper error handling

    // Handle error response
    final errorMessage = e.response?.data['error']['message'];
    return LoginResult(
        status: LoginStatus.failure,
        message: errorMessage ?? 'Something failed, try again later.');
  } catch (e) {
    // TODO: Add proper error handling
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

  // --- NEW: STATE AND INITIALIZATION LOGIC ---
  bool _rememberMe = false;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  /// Loads credentials from secure storage if they exist.
  Future<void> _loadCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');

      if (email != null && email.isNotEmpty) {
        final String? password = await _storage.read(key: 'password');
        if (mounted) {
          setState(() {
            _emailController.text = email;
            _passwordController.text = password ?? '';
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      // It's better not to show an error to the user for this,
      // but logging it helps during development.
    }
  }
  // --- END OF NEW LOGIC ---

  void _handleLogin() async {
    LoginResult result = await login(
      ref,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result.status == LoginStatus.success) {
      // --- NEW: SAVE/CLEAR LOGIC ADDED HERE ---
      // This is the only addition within this method.
      // It runs only after a successful login and before navigation.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('email', _emailController.text.trim());
        await _storage.write(
            key: 'password', value: _passwordController.text.trim());
      } else {
        await prefs.remove('email');
        await _storage.delete(key: 'password');
      }
      // --- END OF ADDITION ---

      // YOUR ORIGINAL SUCCESS AND NAVIGATION LOGIC IS PRESERVED AND UNTOUCHED
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
                          child: Column(spacing: 12,children: [
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
                                ]),
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

                                      // --- NEW: CHECKBOX WIDGET INSERTED HERE ---
                                      // Placed between the password field and the login button.
                                      CheckboxListTile(
                                        title: const Text("Remember Me"),
                                        value: _rememberMe,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _rememberMe = newValue ?? false;
                                          });
                                        },
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                      // --- END OF ADDITION ---

                                      LoginButton(handleLogin: _handleLogin),
                                    ])))
                          ])))
                ])));
  }
}
