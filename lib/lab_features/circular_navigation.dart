import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Current page provider
final currentPageProvider = StateProvider<int>((ref) => 0);

// Items provider
final itemsProvider =
    Provider<List<String>>((ref) => ['Page 1', 'Page 2', 'Page 3']);

class CircularNavigationScreen extends ConsumerStatefulWidget {
  const CircularNavigationScreen({super.key});

  @override
  ConsumerState<CircularNavigationScreen> createState() =>
      _InfinitePageViewState();
}

class _InfinitePageViewState extends ConsumerState<CircularNavigationScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);
    final currentPage = ref.watch(currentPageProvider);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              // Use modulo to ensure the page index is always within bounds
              final adjustedPage = page % items.length;
              ref.read(currentPageProvider.notifier).state = adjustedPage;

              // Smoothly animate to the adjusted page to avoid jank
              if (page != adjustedPage) {
                Future.microtask(() {
                  _pageController.animateToPage(
                    adjustedPage + items.length * 1000,
                    duration: const Duration(milliseconds: 1),
                    curve: Curves.linear,
                  );
                });
              }
            },
            itemBuilder: (context, index) {
              // Use modulo to cycle through items
              final itemIndex = index % items.length;
              return Container(
                color: Colors.primaries[itemIndex % Colors.primaries.length],
                child: Center(
                  child: Text(
                    items[itemIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Page Indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
