import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, name, lastLoginAt];

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, lastLoginAt: $lastLoginAt}';
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}