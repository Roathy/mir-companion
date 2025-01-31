import 'package:flutter/material.dart';

class Slide {
  final String title;
  final Widget textContent;
  final String assetUrl;
  final String? note;
  final Widget? multimedia;

  Slide({required this.title, required this.textContent, required this.assetUrl, this.note, this.multimedia});
}
