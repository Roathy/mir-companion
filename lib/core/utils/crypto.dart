import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:mironline/env/env.dart';

String createMD5Hash() {
  DateTime now = DateTime.now();
  String formattedDate =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  return md5
      .convert(utf8.encode('${Env.secretKey}-$formattedDate'))
      .toString();
}
