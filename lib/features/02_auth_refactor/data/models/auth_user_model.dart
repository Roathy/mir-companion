import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String token,
    String? name,
    String? email,
  }) = _AuthUserModel;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  factory AuthUserModel.fromEntity(AuthUserModel authUser) {
    return AuthUserModel(
      id: authUser.id,
      token: authUser.token,
      name: authUser.name,
      email: authUser.email,
    );
  }
}

extension AuthUserModelX on AuthUserModel {
  AuthUser toEntity() => AuthUser(
        id: id,
        token: token,
        name: name,
        email: email,
      );
}
