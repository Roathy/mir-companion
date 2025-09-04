import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/scroll_physics.dart';

final currentIndexPage = StateProvider<int>((ref) => 0);

class SlideShow extends StatelessWidget {
  final List<Widget> slides;
  final List<String> paths; // ✅ List of route paths

  const SlideShow({super.key, required this.slides, required this.paths});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            const SizedBox(height: 45),
            const Text(
              'General English',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              'Choose a level to study:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
        _SlideShow(slides: slides, paths: paths),
        const Spacer(),
        _SlidesNav(slideCount: slides.length),
        const SizedBox(height: 15),
      ],
    );
  }
}

class _SlideShow extends ConsumerStatefulWidget {
  final List<Widget> slides;
  final List<String> paths; // ✅ Receive list of paths

  const _SlideShow({required this.slides, required this.paths});
  @override
  _SlideShowState createState() => _SlideShowState();
}

class _SlideShowState extends ConsumerState<_SlideShow> {
  late final PageController pageViewController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(currentIndexPage.notifier).state = 0;
    });

    pageViewController = PageController(initialPage: 0)
      ..addListener(() {
        final currentPage = pageViewController.page?.round() ?? 0;
        if (ref.read(currentIndexPage) != currentPage) {
          ref.read(currentIndexPage.notifier).state = currentPage;
        }
      });
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 360,
        minHeight: 300,
        maxWidth: 500,
        minWidth: 300,
      ),
      child: PageView(
        physics: const FreeScrollPhysics(),
        controller: pageViewController,
        children: widget.slides
            .asMap()
            .entries
            .map((entry) => _Slide(
                  slide: entry.value,
                  routePath: widget.paths[entry.key], // ✅ Pass route path
                ))
            .toList(),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Widget slide;
  final String routePath; // ✅ Route path

  const _Slide({required this.slide, required this.routePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routePath); // ✅ Navigate using route name
      },
      child: slide,
    );
  }
}

class _SlidesNav extends StatelessWidget {
  final int slideCount; // ✅ Receive slide count

  const _SlidesNav({required this.slideCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27,
      child: Consumer(builder: (context, ref, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slideCount, // ✅ Use slide count instead of undefined provider
            (index) => _SlideNavIndicator(index: index),
          ),
        );
      }),
    );
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
        color: (pageViewIndex != index) ? Colors.grey : Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
