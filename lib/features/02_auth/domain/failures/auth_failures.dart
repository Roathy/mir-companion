import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  final String message;
  final String? code;
  
  const AuthFailure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AuthFailure: $message${code != null ? ' (Code: $code)' : ''}';
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String? message]) 
      : super(message ?? 'Invalid email or password', code: 'INVALID_CREDENTIALS');
}

class EmptyCredentialsFailure extends AuthFailure {
  const EmptyCredentialsFailure() 
      : super('Email and password cannot be empty', code: 'EMPTY_CREDENTIALS');
}

class InvalidEmailFormatFailure extends AuthFailure {
  const InvalidEmailFormatFailure() 
      : super('Please enter a valid email address', code: 'INVALID_EMAIL_FORMAT');
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure([String? message]) 
      : super(message ?? 'Network error occurred. Please check your connection.', code: 'NETWORK_ERROR');
}

class ServerFailure extends AuthFailure {
  final int? statusCode;
  
  const ServerFailure([String? message, this.statusCode]) 
      : super(message ?? 'Server error occurred. Please try again later.', code: 'SERVER_ERROR');

  @override
  List<Object?> get props => [message, code, statusCode];
}

class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure() 
      : super('Authentication token has expired. Please login again.', code: 'TOKEN_EXPIRED');
}

class UnauthorizedFailure extends AuthFailure {
  const UnauthorizedFailure() 
      : super('Access denied. Please check your credentials.', code: 'UNAUTHORIZED');
}

class UnknownFailure extends AuthFailure {
  const UnknownFailure([String? message]) 
      : super(message ?? 'An unexpected error occurred. Please try again.', code: 'UNKNOWN_ERROR');
}

class AccountLockedFailure extends AuthFailure {
  const AccountLockedFailure() 
      : super('Account is locked. Please contact support.', code: 'ACCOUNT_LOCKED');
}

class TooManyAttemptsFailure extends AuthFailure {
  const TooManyAttemptsFailure() 
      : super('Too many login attempts. Please try again later.', code: 'TOO_MANY_ATTEMPTS');
}