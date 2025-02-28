import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../welcome_tour_page.dart';

final currentIndexPage = StateProvider<int>((ref) => 0);

class SlideShow extends StatelessWidget {
  final List<Widget> slides;
  final bool isLastSlide;

  const SlideShow({
    super.key,
    required this.slides,
    required this.isLastSlide,
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
  bool _showTour = false;

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

  void _onPageChanged(int index) {
    if (index == widget.slides.length - 1) {
      _showLastPageDialog();
    }
  }

  Future<void> _savePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dontShowTour', value);
  }

  void _showLastPageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("You're on the last page!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Do you want to continue?"),
                  Row(
                    children: [
                      Checkbox(
                        value: _showTour,
                        onChanged: (value) {
                          setDialogState(() {
                            _showTour = value!; // Update the local state
                          });
                          _savePreference(value!); // Save the preference
                        },
                      ),
                      Text("Don't show again"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("Continue"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      onPageChanged: _onPageChanged,
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
