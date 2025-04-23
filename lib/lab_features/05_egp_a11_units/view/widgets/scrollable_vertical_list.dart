import 'package:flutter/material.dart';

class ScrollableVerticalList extends StatelessWidget {
  const ScrollableVerticalList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 30),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: tiles.length + 1,
        itemBuilder: (context, index) {
          return index == 0 ? const SizedBox(height: 0) : WideTileBackground(tile: tiles[index - 1]);
        },
      ),
    );
  }
}

class WideTileContent extends StatelessWidget {
  final Tile tile;
  const WideTileContent({
    super.key,
    required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          tile.unit,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 9),
        Wrap(children: [
          Text.rich(TextSpan(text: tile.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
        ]),
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(8, (_) => const Icon(Icons.star, color: Colors.white, size: 21)))
      ],
    );
  }
}

class Tile {
  String unit;
  String title;
  String path; // New field for path

  Color leftColor, rightColor;

  Tile(
    this.unit,
    this.title,
    this.leftColor,
    this.rightColor,
    this.path,
  );
}

final List<Tile> tiles = [
  Tile(
    'UNIT 1',
    'ENGLISH AND YOU',
    const Color(0xFF2E3192),
    const Color(0xFF1BFFFF),
    "/a11-activities",
  ),
  Tile(
    'UNIT 2',
    'MEXICO AND HIDALGO IN ENGLISH',
    const Color(0xFFD4145A),
    const Color(0xFFFBB03B),
    "/a11-activities",
  ),
  Tile(
    'UNIT 3',
    'TRAVEL AND TOURISM',
    const Color(0xFF02AABD),
    const Color(0xFF00CDAC),
    "/a11-activities",
  ),
  Tile(
    'UNIT 4',
    'ENGLISH FOR STUDY AND WORK',
    const Color(0xFF662D8C),
    const Color(0xFFED1E79),
    "/a11-activities",
  ),
];

// Update the onPress callback to perform navigation to the respective path
class WideTileBackground extends StatelessWidget {
  final Tile tile;
  const WideTileBackground({
    super.key,
    required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Move GestureDetector to wrap everything
      onTap: () {
        Navigator.pushNamed(context, tile.path);
      },
      behavior: HitTestBehavior.opaque, // Ensures taps on empty areas register
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: <Color>[
            tile.leftColor,
            tile.rightColor
          ]),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black45,
              blurRadius: 1,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              tile.unit,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 9),
            Wrap(children: [
              Text.rich(TextSpan(text: tile.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            ]),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(8, (_) => const Icon(Icons.star, color: Colors.white, size: 21)))
          ],
        ),
      ),
    );
  }
}
