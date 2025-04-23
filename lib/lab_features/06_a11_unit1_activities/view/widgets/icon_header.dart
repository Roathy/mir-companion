import 'package:flutter/material.dart';

class IconHeader extends StatelessWidget {
  final Color bottomColor, topColor;
  final String subtitle, level;

  const IconHeader({
    super.key,
    // this.bottomColor = Colors.orange,
    // this.topColor = Colors.red,
    this.bottomColor = Colors.orange,
    this.topColor = Colors.orange,
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
        height: 120,
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
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
    return const Stack(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('UNIT 1', style: TextStyle(color: Colors.white)),
            Row(children: [
              Icon(
                Icons.star,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 3),
              Column(children: [
                Text('A1.1', style: TextStyle(color: Colors.white)),
                Text('Exp 55', style: TextStyle(color: Colors.white))
              ]),
            ]),
          ]),
          Wrap(children: [
            Text.rich(TextSpan(
              text: 'ENGLISH AND YOU',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
            )),
          ]),
          SizedBox(height: 12),
        ]),
      ),
    ]);
  }
}
