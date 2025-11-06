import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../services/user_data_provider.dart';
import '../../../../services/providers.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../02_auth/presentation/screens/auth_screen.dart';
import '../../../06_unit_activities/presentation/screens/unit_activities_screen.dart';

final studentLevelUnits = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, queryParam) async {
  try {
    final apiClient = ref.watch(apiClientProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      // TODO: Add proper error handling
      // debugPrint("No auth token found");
      return null;
    }

    String fullUrl =
        "${ApiEndpoints.baseURL}${ApiEndpoints.studentsEgp}/$queryParam";

    Response response = await apiClient.dio.get(fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }));
    return response.data['data'];
  } catch (e) {
    // TODO: Add proper error handling
    // debugPrint("Error fetching student EGP levels's [units]: $e");
    return null;
  }
});

final unitParamProvider = StateProvider<String?>((ref) => null);

class LevelsSUnitsScreen extends ConsumerWidget {
  final String queryParam;
  const LevelsSUnitsScreen({required this.queryParam, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelsAsync = ref.watch(studentLevelUnits(queryParam));
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        return levelsAsync.when(
            data: (unitsData) {
              debugPrint('unitsData: $unitsData');
              if (unitsData == null) {
                return const Scaffold(
                  body: SafeArea(child: Center(child: Text('No units found'))),
                );
              } else {
                final String title = unitsData['nivel'];
                final List units = unitsData['unidades'];

                return Scaffold(
                    appBar: UnitsAppBar(title: title, mircoins: userData.mircoins),
                    body: SafeArea(
                        child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 21.0, vertical: 45),
                                child: Column(
                                    spacing: 30,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: List.generate(units.length, (index) {
                                      final bool isUnitActive =
                                          units[index]['desbloqueada'];
                                      return Stack(
                                        children: [
                                          GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                final String queryParam =
                                                    '${unitsData['nivel_tag']}/u${units[index]['int_unidad']}';
                                                ref
                                                    .read(
                                                        unitParamProvider.notifier)
                                                    .state = queryParam;
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UnitActivitiesScreen()));
                                              },
                                              child: Material(
                                                  elevation: 1,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  shadowColor: Colors.black
                                                      .withValues(alpha: 0.3),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                16),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Color.fromRGBO(
                                                                  0,
                                                                  0,
                                                                  0,
                                                                  0.2), // 0.3 represents 30% opacity
                                                              blurRadius: 3,
                                                              spreadRadius: 3,
                                                              offset: Offset(0, 0))
                                                        ]),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: UnitHeader(
                                                        currentUnit: units[index]),
                                                  ))),
                                          isUnitActive
                                              ? const SizedBox()
                                              : Positioned.fill(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  16),
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: 0.7)),
                                                      child: const Icon(Icons.lock,
                                                          size: 90,
                                                          color: Colors.white)))
                                        ],
                                      );
                                    }))))));
              }
            },
            loading: () => const Scaffold(
                  body: SafeArea(child: Center(child: CircularProgressIndicator())),
                ),
            error: (error, stackTrace) => Scaffold(
                  body: SafeArea(child: Center(child: Text(error.toString()))),
                ));
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

class UnitHeader extends StatelessWidget {
  final Map<String, dynamic> currentUnit;

  const UnitHeader({
    super.key,
    required this.currentUnit,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = hexToColor(currentUnit['color_primario']);
    final Color secundaryColor = hexToColor(currentUnit['color_secundario']);
    return Container(
        height: 240,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 1,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('UNIT ${currentUnit['int_unidad']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 4),
                Text(currentUnit['unidad'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ))
              ]),
              const SizedBox(height: 45),
              // Progress indicator
              ActivitiesProgressIndicator(
                currentUnit: currentUnit,
                secundaryColor: secundaryColor,
              )
            ]));
  }
}

class ActivitiesProgressIndicator extends StatelessWidget {
  const ActivitiesProgressIndicator({
    super.key,
    required this.currentUnit,
    required this.secundaryColor,
  });

  final int totalActivities = 10;
  final Map<String, dynamic> currentUnit;
  final Color secundaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(
            totalActivities,
            (index) => Expanded(
                child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: index < currentUnit['progreso_actividades']
                          ? secundaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        left: index == 0
                            ? const Radius.circular(15)
                            : Radius.zero,
                        right: index == totalActivities - 1
                            ? const Radius.circular(15)
                            : Radius.zero,
                      ),
                      border: Border.all(color: Colors.white, width: 1),
                    )))));
  }
}

Color hexToColor(String hexString) {
  hexString = hexString.replaceAll("#", ""); // Remove #
  if (hexString.length == 6) {
    hexString = "FF$hexString"; // Add alpha (fully opaque)
  }
  return Color(int.parse(hexString, radix: 16));
}

class UnitsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UnitsAppBar({super.key, required this.title, required this.mircoins});
  final String title;
  final int mircoins;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Column(children: [
            Text(
              'Exp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(mircoins.toString(),
                style: TextStyle(fontWeight: FontWeight.bold))
          ]),
          SizedBox(
            width: 15.0,
          )
        ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
