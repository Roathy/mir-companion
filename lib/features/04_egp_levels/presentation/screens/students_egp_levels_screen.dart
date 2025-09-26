import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mironline/services/providers.dart';

import '../../../../core/utils/utils.dart';
import '../../../05_egp_units/presentation/screens/levels_s_units_screen.dart';
import '../../../../network/api_endpoints.dart';
import '../../../02_auth/presentation/screens/auth_screen.dart';
import '../widgets/code_activation_screen.dart';

final studentEGPProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      // TODO: Add proper error handling
      // debugPrint("No auth token found");
      return null;
    }

    String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsEgp}";

    Response response = await apiClient.dio.get(fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }));
    return response.data['data'];
  } catch (e) {
    // TODO: Add proper error handling
    // debugPrint("Error fetching student EGP levels: $e");
    return null;
  }
});
// Add a provider to track the current page index
final currentPageProvider = StateProvider.autoDispose<int>((ref) => 0);
// Add a provider to track the level tag provider
final levelTagProvider = StateProvider<String>((ref) => '');

class StudentsEgpLevelsScreen extends ConsumerStatefulWidget {
  const StudentsEgpLevelsScreen({super.key});

  @override
  ConsumerState<StudentsEgpLevelsScreen> createState() =>
      _StudentsEgpLevelsScreenState();
}

class _StudentsEgpLevelsScreenState
    extends ConsumerState<StudentsEgpLevelsScreen> {
  late PageController _pageController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int page, int totalPages) {
    // If we're near the end of our "fake" infinite scroll,
    // jump back to the middle without animation
    if (page < 2 || page > totalPages * 2 - 2) {
      _pageController.jumpToPage(totalPages + (page % totalPages));
    }

    // Update the state with the wrapped index
    ref.read(currentPageProvider.notifier).state = page % totalPages;
  }

  @override
  Widget build(BuildContext context) {
    final levelsAsync = ref.watch(studentEGPProvider);

    return levelsAsync.when(
      data: (levelsData) {
        if (levelsData == null) {
          return const Scaffold(
            body: SafeArea(child: Center(child: Text('No levels found'))),
          );
        }

        final List niveles = levelsData['niveles'];
        final int mircoins = levelsData['alumno']['mircoins'];

        // Initialize controller with 3 copies of the content
        // This allows one full set before and after the middle set
        // Start at the beginning of middle set
        _pageController = PageController(initialPage: niveles.length);

        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: EGPAppBar(mircoins: mircoins),
            body: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Flexible(
                    flex: 5,
                    child: PageView.builder(
                        controller: _pageController,
                        itemBuilder: (context, index) {
                          final adjustedIndex = index % niveles.length;
                          final currentLevel = niveles[adjustedIndex];
                          final bool isLevelActive = currentLevel['activacion'];

                          return Stack(children: [
                            Center(
                                child: LevelDetailsCard(
                                    isLevelActive: isLevelActive,
                                    currentLevel: currentLevel))
                          ]);
                        },
                        itemCount: niveles.length * 3,
                        onPageChanged: (index) =>
                            _handlePageChange(index, niveles.length)),
                  ),
                  Flexible(
                    flex: 4,
                    child: NavStateIndicator(niveles: niveles),
                  ),
                  const Spacer()
                ])));
      },
      loading: () => const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(child: Center(child: Text(error.toString()))),
      ),
    );
  }
}

void _handleLevelTap(BuildContext context, bool isLevelActive,
    Map<String, dynamic> currentLevel) {
  if (isLevelActive) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LevelsSUnitsScreen(
                  queryParam: currentLevel['nivel_tag'],
                )));
  } else {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (context, animation, secondaryAnimation) =>
                CodeActivationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            }));
  }
}

class LevelDetailsCard extends StatelessWidget {
  const LevelDetailsCard(
      {super.key, required this.isLevelActive, required this.currentLevel});

  final bool isLevelActive;
  final dynamic currentLevel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleLevelTap(context, isLevelActive, currentLevel),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(0, 0))
                ]),
            clipBehavior: Clip.hardEdge,
            child: Stack(children: [
              Image.network(
                currentLevel['tarjeta'],
                fit: BoxFit.contain,
              ),
              isLevelActive
                  ? const SizedBox()
                  : Positioned.fill(
                      child: Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          child: const Icon(Icons.lock,
                              size: 90, color: Colors.white)))
            ])));
  }
}

class EGPAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EGPAppBar({super.key, required this.mircoins});
  final int mircoins;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        'General English',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Column(
          children: [
            Text(
              'Exp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(mircoins.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
        SizedBox(
          width: 15.0,
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavStateIndicator extends StatelessWidget {
  const NavStateIndicator({
    super.key,
    required this.niveles,
  });

  final List niveles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          niveles.length,
          (index) {
            return Consumer(
              builder: (context, ref, child) {
                final currentPage = ref.watch(currentPageProvider);
                return Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 7.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index ? Colors.grey : Colors.black12,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
