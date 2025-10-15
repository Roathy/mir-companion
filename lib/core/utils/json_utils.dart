import 'dart:convert';

import 'package:flutter/foundation.dart';

// This function is designed to be run in a separate isolate.
Future<Map<String, dynamic>> parseJsonInBackground(String jsonString) async {
  return await compute(jsonDecode, jsonString);
}

Map<String, dynamic> jsonDecode(String jsonString) {
  return json.decode(jsonString);
}
