import 'package:equatable/equatable.dart';

class LoginCredentials extends Equatable {
  final String email;
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty && _isValidEmail(email);

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginCredentials{email: $email, password: [HIDDEN]}';
  }

  LoginCredentials copyWith({
    String? email,
    String? password,
  }) {
    return LoginCredentials(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}