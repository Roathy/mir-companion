import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import 'data/datasource/welcome_slides.dart';
import 'widgets/slideshow.dart';

final listLength = Provider<int>((ref) => ref.watch(slidesProvider).length);

class WelcomeTourPage extends ConsumerStatefulWidget {
  const WelcomeTourPage({super.key});

  @override
  ConsumerState<WelcomeTourPage> createState() => _WelcomeTourPageState();
}

class _WelcomeTourPageState extends ConsumerState<WelcomeTourPage> {
  final _currentSlideIndex = StateProvider<int>((ref) => 0);

  @override
  Widget build(BuildContext context) {
    final slides = ref
        .watch(slidesProvider)
        .map((slide) => _AnimationContainer(
              assetUrl: slide.assetUrl,
              title: slide.title,
              textContent: slide.textContent,
              note: slide.note,
              multimedia: slide.multimedia,
            ))
        .toList();

    final isLastSlide = _currentSlideIndex == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: SlideShow(
          slides: slides,
          isLastSlide: isLastSlide,
        ),
      ),
    );
  }
}

class _AnimationContainer extends StatelessWidget {
  final String title;
  final Widget textContent;
  final String assetUrl;
  final String? note;
  final Widget? multimedia;
  const _AnimationContainer({
    required this.assetUrl,
    required this.title,
    required this.textContent,
    this.note,
    this.multimedia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 27),
        Text(
          title,
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 27,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 27),
        textContent,
        note != null
            ? Text(
                note ?? '',
                style: const TextStyle(fontSize: 6),
              )
            : const SizedBox(),
        const SizedBox(height: 27),
        Expanded(
          child: assetUrl == '' ? multimedia! : RiveAnimation.asset(assetUrl),
        ),
      ],
    );
  }
}
