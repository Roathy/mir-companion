import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../welcome_tour_page.dart';

final currentIndexPage = StateProvider<int>((ref) => 0);

class SlideShow extends StatelessWidget {
  final List<Widget> slides;

  const SlideShow({
    super.key,
    required this.slides,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SlideShow(slides),
      _SlidesNav(),
    ]);
  }
}

class _SlideShow extends ConsumerStatefulWidget {
  final List<Widget> slides;

  const _SlideShow(this.slides);
  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends ConsumerState<_SlideShow> {
  late final PageController pageViewController;

  @override
  void initState() {
    pageViewController = PageController()
      ..addListener(() {
        ref.read(currentIndexPage.notifier).state = pageViewController.page!.round();
      });
    super.initState();
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      physics: const BouncingScrollPhysics(
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      controller: pageViewController,
      children: widget.slides.map((slide) => _Slide(slide: slide)).toList(),
    ));
  }
}

class _Slide extends StatelessWidget {
  final Widget slide;
  const _Slide({
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.only(left: 9, right: 9),
      child: slide,
    );
  }
}

class _SlidesNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 27,
        child: Consumer(builder: (context, ref, child) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ref.watch(listLength),
                (index) => _SlideNavIndicator(index: index),
              ));
        }));
  }
}

class _SlideNavIndicator extends ConsumerWidget {
  final int index;

  const _SlideNavIndicator({required this.index});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pageViewIndex = ref.watch(currentIndexPage);

    return AnimatedContainer(
        curve: Curves.bounceOut,
        duration: const Duration(milliseconds: 300),
        height: 9,
        width: 9,
        margin: const EdgeInsets.symmetric(horizontal: 3.0),
        decoration: BoxDecoration(
          color: (pageViewIndex == index) ? Colors.grey : Colors.blue,
          shape: BoxShape.circle,
        ));
  }
}
