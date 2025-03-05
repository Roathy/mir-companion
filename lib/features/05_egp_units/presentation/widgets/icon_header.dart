import 'package:flutter/material.dart';

class IconHeader extends StatelessWidget {
  final Color bottomColor, topColor;
  final String subtitle, level;

  const IconHeader({
    super.key,
    this.bottomColor = Colors.white,
    this.topColor = Colors.white,
    required this.subtitle,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return IconHeaderBackground(
      bottomColor: bottomColor,
      topColor: topColor,
      subtitle: subtitle,
      level: level,
    );
  }
}

class IconHeaderBackground extends StatelessWidget {
  final Color topColor, bottomColor;
  final String subtitle, level;
  const IconHeaderBackground({
    super.key,
    required this.topColor,
    required this.bottomColor,
    required this.subtitle,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 81,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          topColor,
          bottomColor,
        ])),
        child: IconHeaderContent(
          subtitle: subtitle,
          level: level,
        ));
  }
}

class IconHeaderContent extends StatelessWidget {
  final String subtitle, level;
  const IconHeaderContent({super.key, required this.subtitle, required this.level});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(width: double.infinity),
        const SizedBox(height: 12),
        Wrap(children: [
          Text.rich(TextSpan(text: 'Level ', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18), children: <InlineSpan>[
            TextSpan(text: level, style: const TextStyle(color: Colors.purple))
          ])),
        ]),
        const SizedBox(height: 12),
        Text(subtitle, style: const TextStyle(color: Colors.black, fontSize: 15)),
      ]),
    ]);
  }
}
