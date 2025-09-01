import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    super.refreshToken,
    required super.expiresAt,
    super.tokenType = 'Bearer',
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      tokenType: token.tokenType,
    );
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }

  /// Creates an AuthTokenModel from API response
  factory AuthTokenModel.fromApiResponse(Map<String, dynamic> json) {
    // Handle different API response formats
    final token = json['token'] as String? ?? json['access_token'] as String?;
    final refreshToken = json['refresh_token'] as String?;
    
    if (token == null) {
      throw const FormatException('Token not found in API response');
    }

    // Calculate expiration time if not provided
    DateTime expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'] as String);
    } else if (json['expires_in'] != null) {
      final expiresInSeconds = json['expires_in'] as int;
      expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    } else {
      // Default to 24 hours if no expiration info
      expiresAt = DateTime.now().add(const Duration(hours: 24));
    }

    return AuthTokenModel(
      accessToken: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }
}