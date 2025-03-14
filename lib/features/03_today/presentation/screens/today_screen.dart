import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../02_auth/presentation/screens/auth_screen.dart';
import '../../../web_view_activity/presentation/screens/webview_activity_screen_refactor.dart';
import '../widgets/bg_image_container.dart';
import '../widgets/today_app_bar.dart';

final studentTodayProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    final dio = ref.read(dioProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      debugPrint("No auth token found");
      return null;
    }

    String fullUrl = "${ApiEndpoints.baseURL}${ApiEndpoints.studentsProfile}";

    Response response = await dio.get(fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }));
    return response.data['data'];
  } catch (e) {
    debugPrint("Error fetching student today: $e");
    return null;
  }
});

class StudentTodayScreen extends ConsumerWidget {
  const StudentTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentTodayProvider);

    return profileAsync.when(
      data: (profileData) {
        if (profileData == null) {
          return const Scaffold(
              body: SafeArea(
                  child: Center(child: Text("No profile data found"))));
        } else {
          final alumno = profileData['alumno'];
          final egp = profileData['actividades_siguientes']['egp'];
          final String activityBgImgUrl = egp['cover_actividad'];
          return Scaffold(
              appBar: TodayAppBar(
                  mircoins: alumno['mircoins'] ?? 0,
                  userName: '${alumno['fullname']}'),
              body: SafeArea(
                  child: SingleChildScrollView(
                      primary: true,
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          spacing: 30,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/egp-levels');
                                },
                                child: BgImageContainer(
                                  heightMultiplier: 0.18,
                                  imageUrl:
                                      "https://mironline.io/assets/img/today/bg_thumbnail.jpg",
                                  content: EGPTitle(),
                                )),
                            DateDetails(),
                            GestureDetector(
                                onTap: () {
                                  final String activityQuery =
                                      '/${egp['nivel_tag']}/u${egp['int_unidad']}/${egp['int_actividad']}';
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WebViewActivity(
                                            activityQuery: activityQuery),
                                      ));
                                },
                                child: BgImageContainer(
                                  imageUrl: activityBgImgUrl,
                                  content: LastActivityDetails(egp: egp),
                                ))
                          ]))));
        }
      },
      loading: () => Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(child: Center(child: Text(error.toString()))),
      ),
    );
  }
}

class LastActivityDetails extends StatelessWidget {
  final Map<String, dynamic> egp;
  const LastActivityDetails({
    super.key,
    required this.egp,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45.0),
            child: ListView(primary: false, shrinkWrap: true, children: [
              Text(
                'Continue with ${egp['titulo']}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                'on ${egp['nivel']} - Unit ${egp['int_unidad']}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )
            ])));
  }
}

class DateDetails extends StatelessWidget {
  const DateDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final formatter = DateFormat('EEEE, LLLL d, yyyy');
    String formattedDate = formatter.format(now);
    return Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const Text(
            'Today for you:',
            style: TextStyle(
                fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold),
          )
        ]));
  }
}

class EGPTitle extends StatelessWidget {
  const EGPTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('General English levels',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            )));
  }
}
