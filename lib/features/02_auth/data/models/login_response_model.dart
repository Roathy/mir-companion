import 'package:json_annotation/json_annotation.dart';
import 'auth_token_model.dart';
import 'user_model.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final bool success;
  final String? message;
  final LoginDataModel? data;
  final Map<String, dynamic>? error;

  const LoginResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  /// Helper getter to extract token from response
  String? get token => data?.token;

  /// Helper getter to extract user from response
  UserModel? get user => data?.user;

  /// Helper getter to get expiration date
  DateTime? get expiresAt => data?.expiresAt;
}

@JsonSerializable()
class LoginDataModel {
  final String? token;
  final UserModel? user;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @JsonKey(name: 'token_type')
  final String? tokenType;

  const LoginDataModel({
    this.token,
    this.user,
    this.expiresAt,
    this.expiresIn,
    this.tokenType,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) =>
      _$LoginDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataModelToJson(this);

  /// Converts to AuthTokenModel
  AuthTokenModel? toAuthToken() {
    if (token == null) return null;

    DateTime calculatedExpiresAt;
    if (expiresAt != null) {
      calculatedExpiresAt = expiresAt!;
    } else if (expiresIn != null) {
      calculatedExpiresAt = DateTime.now().add(Duration(seconds: expiresIn!));
    } else {
      // Default to 24 hours
      calculatedExpiresAt = DateTime.now().add(const Duration(hours: 24));
    }

    return AuthTokenModel(
      accessToken: token!,
      expiresAt: calculatedExpiresAt,
      tokenType: tokenType ?? 'Bearer',
    );
  }
}