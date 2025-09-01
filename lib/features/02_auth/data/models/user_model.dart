import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      lastLoginAt: user.lastLoginAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      lastLoginAt: lastLoginAt,
    );
  }
}