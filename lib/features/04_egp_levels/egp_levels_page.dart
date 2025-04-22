import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/slideshow.dart';

final slidesProvider = Provider<List<Widget>>((ref) => [
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/a11-card.jpg')),
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/a12-card.png')),
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/a21-card.png')),
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/a22-card.png')),
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/b11-card.png')),
      ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset('assets/images/egp-levels/b12-card.png')),
    ]);

final listLength = Provider<int>((ref) => ref.watch(slidesProvider).length);

class EGPLevels extends StatelessWidget {
  const EGPLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ))
        ],
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final slides = ref.watch(slidesProvider);
            return SlideShow(
              slides: slides,
              paths: [
                '/a1-1',
                '/a1-1',
                '/a1-1',
                '/a1-1',
                '/a1-1',
                '/a1-1',
              ],
            );
          },
        ),
      ),
    );
  }
}
