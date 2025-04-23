import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BgImageContainer extends StatelessWidget {
  final double? height, width, borderRadius;
  final String imageUrl;
  final Widget? content;
  const BgImageContainer({
    super.key,
    required this.imageUrl,
    this.content,
    this.height = 90,
    this.width = 90,
    this.borderRadius = 9,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: height, width: width),
      child: Stack(alignment: Alignment.center, children: [
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius!)),
            alignment: Alignment.center,
            child: Image.network(
              height: height,
              width: width,
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(child: content ?? Container()),
      ]),
    );
  }
}
