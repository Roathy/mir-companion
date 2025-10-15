// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeysecretKey = <int>[
    1672114422,
    1731611367,
    2411801656,
    3919952226,
    3615377372,
    3183516755,
  ];

  static const List<int> _envieddatasecretKey = <int>[
    1672114369,
    1731611346,
    2411801610,
    3919952214,
    3615377380,
    3183516773,
  ];

  static final String secretKey = String.fromCharCodes(List<int>.generate(
    _envieddatasecretKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatasecretKey[i] ^ _enviedkeysecretKey[i]));
}
