import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mironline/features/06_unit_activities/presentation/widgets/export_unit_activities_widgets.dart';
import 'package:mironline/services/providers.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../02_auth/presentation/screens/auth_screen.dart';
import '../../../05_egp_units/presentation/screens/levels_s_units_screen.dart';
import '../../../web_view_activity/presentation/screens/webview_activity_screen.dart';

final studentUnitsActivities = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, queryParam) async {
  try {
    final apiClient = ref.read(apiClientProvider);
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
    // debugPrint("Error fetching student EGP levels's units [activities]: $e");
    return null;
  }
});

class UnitActivitiesScreen extends ConsumerWidget {
  const UnitActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryParam = ref.watch(unitParamProvider);
    if (queryParam == null) {
      return const Center(child: Text('No queryParam found!'));
    }
    final asyncActivities = ref.watch(studentUnitsActivities(queryParam));

    return asyncActivities.when(
        data: (activitiesData) {
          if (activitiesData == null) {
            return const Scaffold(
              body: SafeArea(child: Center(child: Text('No units found'))),
            );
          } else {
            final primaryColor = hexToColor(activitiesData['color_primario']);
            final secondaryColor =
                hexToColor(activitiesData['color_secundario']);
            final String currentLevel = '/${activitiesData['nivel_tag']}';
            final String currentUnit = '/u${activitiesData['int_unidad']}';
            final List activities = activitiesData['actividades'];
            return Scaffold(
                backgroundColor: Colors.grey[200],
                body: SafeArea(
                    child: CustomScrollView(slivers: [
                  SliverAppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: primaryColor,
                      expandedHeight: 200.0,
                      pinned: true,
                      floating: false,
                      flexibleSpace: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final bool isCollapsed = constraints.maxHeight <=
                            kToolbarHeight + MediaQuery.of(context).padding.top;
                        return FlexibleSpaceBar(
                          centerTitle: false, // Always align title to the left
                          titlePadding: isCollapsed
                              ? const EdgeInsets.only(
                                  left: 45.0, right: 16.0, bottom: 16.0)
                              // Added top padding
                              : const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 16.0,
                                  right: 16.0,
                                  top: 48.0),
                          title: isCollapsed
                              ? CollapsedAppbar(
                                  data: activitiesData,
                                  secondaryColor: secondaryColor)
                              : ExpandedAppbar(
                                  data: activitiesData,
                                  secondaryColor: secondaryColor),
                          background: Container(color: primaryColor),
                        );
                      })),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final currentActivity = activities[index];
                      final bool isActivityUnlocked =
                          currentActivity['desbloqueada'];

                      final String activityQuery =
                          '$currentLevel$currentUnit/${currentActivity['int_actividad']}';
                      final int currentScore = (currentActivity['estadisticas']
                              ?['estrellas'] as int?) ??
                          0;
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 18),
                          child: Column(children: [
                            Stack(children: [
                              ActivityCard(
                                currentActivity: currentActivity,
                                activityUrl: activityQuery,
                              ),
                              isActivityUnlocked
                                  ? const SizedBox()
                                  : Positioned.fill(
                                      child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                          child: const Icon(Icons.lock,
                                              size: 90, color: Colors.white)))
                            ]),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 27.0, bottom: 0.0),
                                child: DisplayActivityScore(
                                  currentScore: currentScore,
                                  starColor: secondaryColor,
                                ))
                          ]));
                    },
                    childCount: activities.length,
                  ))
                ])));
          }
        },
        loading: () => const Scaffold(
              body: SafeArea(child: Center(child: CircularProgressIndicator())),
            ),
        error: (error, stackTrace) => Scaffold(
              body: SafeArea(child: Center(child: Text(error.toString()))),
            ));
  }
}

class ActivityCard extends StatelessWidget {
  final dynamic currentActivity;
  final String activityUrl;
  const ActivityCard({
    super.key,
    required this.currentActivity,
    required this.activityUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WebViewActivity(activityQuery: activityUrl)));
        },
        child: Stack(children: [
          // Shadow effect container
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color
                      blurRadius: 6, // Spread of the shadow
                      spreadRadius: 1, // Extends the shadow
                      offset: Offset(0, 3), // Slight bottom shadow
                    )
                  ]),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    currentActivity['cover_actividad'],
                    fit: BoxFit.cover, // Ensures the image fills and zooms in
                    width: double.infinity,
                    height: 200,
                  ))),
          ActivityDetails(currentActivity: currentActivity),
        ]));
  }
}

class ExpandedAppbar extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color secondaryColor;

  const ExpandedAppbar(
      {super.key, required this.data, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('UNIT ${data['int_unidad']}:'.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          Text(data['unidad'].toString().toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 18),
          Align(
              alignment: Alignment.centerLeft,
              child: ActivitiesProgressIndicator(
                secundaryColor: secondaryColor,
                isCollapsed: false,
                completedActivities: data['progreso_actividades'],
              )),
          const SizedBox(height: 15),
        ]);
  }
}

class CollapsedAppbar extends StatelessWidget {
  const CollapsedAppbar({
    super.key,
    required this.data,
    required this.secondaryColor,
  });

  final Map<String, dynamic> data;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      // Increased flex to 6 to allow more space for text
      Flexible(
          flex: 5,
          child: Text(
            'UNIT ${data['int_unidad']}: ${data['unidad']}'.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
            softWrap: true, // Ensures wrapping if needed
          )),
      Flexible(
          flex: 6, // Adjusted to fit alongside text
          child: ActivitiesProgressIndicator(
            secundaryColor: secondaryColor,
            isCollapsed: true,
            completedActivities: data['progreso_actividades'],
          ))
    ]);
  }
}

class ActivitiesProgressIndicator extends StatelessWidget {
  const ActivitiesProgressIndicator({
    super.key,
    required this.secundaryColor,
    required this.isCollapsed,
    required this.completedActivities,
  });

  final int totalActivities = 10;
  final Color secundaryColor;
  final bool isCollapsed;
  final int completedActivities;

  @override
  Widget build(BuildContext context) {
    // Adjusted widths to prevent overflow
    final double availableWidth = isCollapsed
        ? MediaQuery.of(context).size.width * 0.45 // Reduced from 50% to 45%
        : MediaQuery.of(context).size.width * 0.60; // Reduced from 85% to 80%

    // Calculate each block width, accounting for borders
    final double blockWidth = (availableWidth - (totalActivities * .01)) /
        totalActivities; // Subtract total border width

    return Container(
        width: availableWidth,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
            children: List.generate(totalActivities, (index) {
          return Container(
              height: 15,
              width: blockWidth,
              decoration: BoxDecoration(
                color:
                    index < completedActivities ? secundaryColor : Colors.white,
                borderRadius: BorderRadius.horizontal(
                  left: index == 0 ? const Radius.circular(15) : Radius.zero,
                  right: index == totalActivities - 1
                      ? const Radius.circular(15)
                      : Radius.zero,
                ),
                border: Border.all(color: Colors.white, width: 0.5),
              ));
        })));
  }
}

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({
    super.key,
    required this.currentActivity,
  });

  final dynamic currentActivity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 16, // Align text to the left
        top: 0,
        bottom: 0, // Centers vertically
        child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers text vertically
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligns text to the left
            children: [
              TextActivityTitle(currentActivity: currentActivity),
              TextActivityType(currentActivity: currentActivity),
            ]));
  }
}

Color hexToColor(String hexString) {
  hexString = hexString.replaceAll("#", ""); // Remove #
  if (hexString.length == 6) {
    hexString = "FF$hexString"; // Add alpha (fully opaque)
  }
  return Color(int.parse(hexString, radix: 16));
}
