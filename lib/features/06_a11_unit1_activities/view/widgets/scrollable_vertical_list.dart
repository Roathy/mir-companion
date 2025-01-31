import 'package:flutter/material.dart';

class ScrollableVerticalList extends StatelessWidget {
  const ScrollableVerticalList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 81),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: tiles.length + 1,
          itemBuilder: (context, index) {
            return index == 0
                ? const Center(
                    child: Text('Choose an activity:'),
                  )
                : WideTileBackground(tile: tiles[index - 1]);
          }),
    );
  }
}

class WideTileBackground extends StatelessWidget {
  final Tile tile;
  const WideTileBackground({
    super.key,
    required this.tile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ]),
      child: WideTileContent(tile: tile),
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
    return GestureDetector(
        onTap: tile.onPress,
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(
            tile.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 21),
          ),
          Wrap(children: [
            Text.rich(TextSpan(text: tile.skill, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: 15))),
          ]),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => Icon(Icons.star, color: Colors.white, size: (index == 1) ? 45 : 30)))
        ]));
  }
}

class Tile {
  String title;
  String skill;
  void Function() onPress;
  Color leftColor, rightColor;
  Tile(this.title, this.skill, this.leftColor, this.rightColor, this.onPress);
}

final List<Tile> tiles = [
  Tile('Ximena\'s Instagram', 'Skills Work', const Color(0xFF2E3192), const Color(0xFF1BFFFF), () {
    print('taptap');
  }),
  Tile('The number is...', 'Vocabulary', const Color(0xFFD4145A), const Color(0xFFFBB03B), () {
    print('taptap');
  }),
  Tile('Jobsheet', 'Vocabulary', const Color(0xFF02AABD), const Color(0xFF00CDAC), () {
    print('taptap');
  }),
  Tile('Who are they?', 'Grammar', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('Sandra\'s Interview', 'Grammar', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('Jaime\'s email', 'Skills Work', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('Family Members', 'Vocabulary', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('Family Members 2', 'Vocabulary', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('Simple present', 'Grammar', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
  Tile('This belongs to...', 'Grammar', const Color(0xFF662D8C), const Color(0xFFED1E79), () {
    print('taptap');
  }),
];
