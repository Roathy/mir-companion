import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => !isExpired && accessToken.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, tokenType];

  @override
  String toString() {
    return 'AuthToken{tokenType: $tokenType, expiresAt: $expiresAt, isExpired: $isExpired}';
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }
}