import 'dart:developer';

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mironline/core/utils/crypto.dart';
import 'package:mironline/features/02_auth/presentation/screens/auth_screen.dart';
import 'package:mironline/features/05_egp_units/presentation/screens/levels_s_units_screen.dart';
import 'package:mironline/features/web_view_activity/presentation/screens/webview_activity_screen.dart';
import 'package:mironline/network/api_endpoints.dart';
import 'package:mironline/services/providers.dart';
import 'package:mironline/services/refresh_provider.dart';
import 'package:mironline/services/user_data_provider.dart';

import '../../../06_unit_activities/presentation/screens/unit_activities_screen.dart';
import '../widgets/bg_image_container.dart';
import '../widgets/no_profile_data.dart';
import '../widgets/today_app_bar.dart';

final studentTodayProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  ref.watch(activitiesRefreshProvider);
  try {
    final apiClient = ref.watch(apiClientProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      return null;
    }

    String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsProfile}";

    Response response = await apiClient.dio.get(
      fullUrl,
      options: Options(headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-App-MirHorizon": createMD5Hash(),
        "Authorization": "Bearer $authToken",
      }),
    );
    log('Student today data: ${response.data}');
    return response.data['data'];
  } catch (e, stackTrace) {
    log('Error fetching student today data: $e');
    log('Stack trace: $stackTrace');
    return null;
  }
});

class StudentTodayScreen extends ConsumerStatefulWidget {
  const StudentTodayScreen({super.key});

  @override
  ConsumerState<StudentTodayScreen> createState() => _StudentTodayScreenState();
}

class _StudentTodayScreenState extends ConsumerState<StudentTodayScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(studentTodayProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(studentTodayProvider);
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        return profileAsync.when(
            data: (profileData) {
              if (profileData == null) {
                return const NoProfileData();
              } else {
                final egp = profileData['actividades_siguientes']['egp'];
                debugPrint('egp: $egp');
                final String activityBgImgUrl = egp['cover_actividad'];

                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) async {
                    final result = await showAdaptiveDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return Dialog(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0),
                                  child: Text(
                                    'Exit application?',
                                    style: TextStyle(fontSize: 27),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 30.0, bottom: 21.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: Text(
                                                'NO',
                                                style: TextStyle(fontSize: 18),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: Text(
                                                'YES',
                                                style: TextStyle(fontSize: 18),
                                              )),
                                        ]))
                              ]));
                        });
                    if (result == true) {
                      SystemNavigator.pop(animated: true);
                    }
                  },
                  child: Scaffold(
                      appBar: TodayAppBar(
                        mircoins: userData.mircoins,
                        userName: userData.fullname,
                      ),
                      body: SafeArea(
                          child: SingleChildScrollView(
                              primary: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                  spacing: 30,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/egp-levels');
                                      },
                                      child: const BgImageContainer(
                                        heightMultiplier: 0.18,
                                        imageUrl:
                                            "https://mironline.io/assets/img/today/bg_thumbnail.jpg",
                                        content: EGPTitle(),
                                      ),
                                    ),
                                    const DateDetails(),
                                    GestureDetector(
                                        onTap: () async {
                                          final lastActivityStats =
                                              egp['ultima_estadistica'];
                                          if (lastActivityStats == null ||
                                              lastActivityStats == false) {
                                            final String activityQuery =
                                                '/${egp['nivel_tag']}/u${egp['int_unidad']}/${egp['int_actividad']}';
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    WebViewActivity(
                                                        activityQuery:
                                                            activityQuery),
                                              ),
                                            );
                                            ref.invalidate(
                                                studentTodayProvider);
                                          } else {
                                            final currentActivityId =
                                                egp['id_actividad'];
                                            final lastActivityId =
                                                lastActivityStats[
                                                    'id_actividad'];
                                            debugPrint(
                                                'currentActivityId: $currentActivityId');
                                            debugPrint(
                                                'lastActivityId: $lastActivityId');
                                            if (currentActivityId >
                                                lastActivityId) {
                                              final String activityQuery =
                                                  '/${egp['nivel_tag']}/u${egp['int_unidad']}/${egp['int_actividad']}';
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WebViewActivity(
                                                          activityQuery:
                                                              activityQuery),
                                                ),
                                              );
                                              ref.invalidate(
                                                  studentTodayProvider);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'You\'ve already made this activity!'),
                                                  content: const Text(
                                                      'You can try and get a higher score or navigate to the next activity.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        final String
                                                            activityQuery =
                                                            '/${egp['nivel_tag']}/u${egp['int_unidad']}/${egp['int_actividad']}';
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                WebViewActivity(
                                                                    activityQuery:
                                                                        activityQuery),
                                                          ),
                                                        );
                                                        ref.invalidate(
                                                            studentTodayProvider);
                                                      },
                                                      child:
                                                          const Text('Retry'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        final String
                                                            queryParam =
                                                            '${egp['nivel_tag']}/u${egp['int_unidad']}';
                                                        debugPrint(
                                                            'queryParam: $queryParam');
                                                        ref
                                                            .read(
                                                                unitParamProvider
                                                                    .notifier)
                                                            .state = queryParam;
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                UnitActivitiesScreen(),
                                                          ),
                                                        );
                                                        ref.invalidate(
                                                            studentTodayProvider);
                                                      },
                                                      child: const Text(
                                                          'Find next activity'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: BgImageContainer(
                                          imageUrl: activityBgImgUrl,
                                          content:
                                              LastActivityDetails(egp: egp),
                                        ))
                                  ])))),
                );
              }
            },
            loading: () => const Scaffold(
                body: SafeArea(
                    child: Center(child: CircularProgressIndicator()))),
            error: (error, stackTrace) => Scaffold(
                body: SafeArea(child: Center(child: Text(error.toString())))));
      },
      loading: () => const Scaffold(
          body: SafeArea(child: Center(child: CircularProgressIndicator()))),
      error: (error, stackTrace) => Scaffold(
          body: SafeArea(child: Center(child: Text(error.toString())))),
    );
  }
}

class LastActivityDetails extends StatelessWidget {
  final Map<String, dynamic> egp;
  const LastActivityDetails({super.key, required this.egp});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45.0),
            child: ListView(primary: false, shrinkWrap: true, children: [
              Text(
                'Continue with ${egp['titulo']}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 1.0, // Qué tan difuminada será la sombra
                      color:
                          Colors.black.withValues(alpha: 1), // Color y opacidad
                      offset: Offset(1.5, 1.5), // Desplazamiento en X y Y
                    ),
                  ],
                ),
              ),
              Text(
                'on ${egp['nivel']} - Unit ${egp['int_unidad']}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0, // Qué tan difuminada será la sombra
                        color: Colors.black
                            .withValues(alpha: 1), // Color y opacidad
                        offset: Offset(1.5, 1.5), // Desplazamiento en X y Y
                      ),
                    ],
                    fontWeight: FontWeight.bold),
              )
            ])));
  }
}

class DateDetails extends StatelessWidget {
  const DateDetails({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final formatter = DateFormat('EEEE, LLLL d, yyyy');
    String formattedDate = formatter.format(now);
    return Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(formattedDate,
              style: const TextStyle(fontSize: 15, color: Colors.black54)),
          const Text('Today for you:',
              style: TextStyle(
                  fontSize: 21,
                  color: Colors.black,
                  fontWeight: FontWeight.bold))
        ]));
  }
}

class EGPTitle extends StatelessWidget {
  const EGPTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('General English levels',
            style: TextStyle(fontSize: 30, color: Colors.white)));
  }
}
