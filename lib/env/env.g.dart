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
    3084509521,
    2148228017,
    3522494366,
    2062619951,
    3836462317,
    864276085,
  ];

  static const List<int> _envieddatasecretKey = <int>[
    3084509542,
    2148227972,
    3522494380,
    2062619931,
    3836462293,
    864276035,
  ];

  static final String secretKey = String.fromCharCodes(List<int>.generate(
    _envieddatasecretKey.length,
    (int i) => i,
    growable: false,
  ).map((int i) => _envieddatasecretKey[i] ^ _enviedkeysecretKey[i]));
}
