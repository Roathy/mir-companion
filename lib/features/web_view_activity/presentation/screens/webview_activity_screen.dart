import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mir_companion_app/features/06_unit_activities/presentation/screens/unit_activities_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/utils/utils.dart';
import '../../../../network/api_endpoints.dart';
import '../../../02_auth/presentation/screens/auth_screen.dart';

final unitActivityProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, activityQuery) async {
  Response<dynamic>? response;

  try {
    final dio = ref.read(dioProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      debugPrint("No auth token found");
      return {
        "error": {"code": 401, "message": "Unauthorized"}
      };
    }

    String fullUrl =
        "${ApiEndpoints.baseURL}${ApiEndpoints.studentsEgp}$activityQuery";

    response = await dio.get(fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }));

    // if (response.data == null) {
    //   debugPrint("Invalid response structure");
    //   return {"error": {"code": 500, "message": "Server returned no data"}};
    // }

    return response.data;
  } catch (e) {
    debugPrint('Error fetching Unit\'s activity: $e');

    // If response exists, return its error data
    if (response != null && response.data != null) {
      return response.data;
    }

    // Otherwise, return a generic error message
    return {
      "error": {"code": 500, "message": "Unexpected error occurred"}
    };
  }
});

class WebViewActivity extends ConsumerWidget {
  final String activityQuery;
  const WebViewActivity({super.key, required this.activityQuery});

  static const Map<String, String> specialCases = {
    'out-of-tries': 'Use 30 mircoins to purchase an extra attempt',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivity = ref.watch(unitActivityProvider(activityQuery));

    // Define the action handlers map
    final Map<String, void Function()> actionHandlers = {
      'finishButtonClick': () {
        inspect(extractMiddleSegments(activityQuery));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return UnitActivitiesScreen(
              queryParam: extractMiddleSegments(activityQuery));
        }));
      }
    };

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return; // If already popped, do nothing

          // Show a confirmation dialog when the back button is pressed
          final bool shouldExit = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Do you want to exit the Activity?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false), // Cancel
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(true), // Confirm
                          child: const Text('Yes'),
                        )
                      ]));

          // If the user confirms, pop the route
          if (shouldExit) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
            body: SafeArea(
                child: asyncActivity.when(
          data: (activityData) {
            if (activityData == null) {
              inspect(activityData);
              return Center(child: Text('Oops! This activity is empty!'));
            }
            // Check if an error is present
            if (activityData.containsKey("error")) {
              // final errorCode = activityData["error"]["code"];
              // final errorMessage = activityData["error"]["message"];

              return NoActivityAttempts(canBuy: false);
            }
            if (activityData['message'] == specialCases['out-of-tries']) {
              return Center(
                  child: NoActivityAttempts(
                canBuy: true,
              ));
            } else {
              inspect(activityData);
              final activityUrl = Uri.decodeFull(
                  activityData['data']['actividad']['_links']['self']['href']);

              // Create the controller first
              final controller = WebViewController();

              // Configure the controller
              controller.setJavaScriptMode(JavaScriptMode.unrestricted);

              // Add JavaScript channel for communication
              controller.addJavaScriptChannel('FlutterApp',
                  onMessageReceived: (JavaScriptMessage message) {
                // Log the message received from the WebView
                debugPrint('Message from WebView: ${message.message}');

                // Parse the JSON message (if applicable)
                try {
                  final Map<String, dynamic> messageData =
                      jsonDecode(message.message);
                  final String action = messageData['action'];

                  // Execute the handler for the given action
                  if (actionHandlers.containsKey(action)) {
                    actionHandlers[action]!(); // Call the handler function
                  } else {
                    debugPrint('Unknown action: $action');
                  }
                } catch (e) {
                  debugPrint('Failed to parse message: $e');
                }
              });

              // Set up navigation delegate to log page load events
              controller.setNavigationDelegate(
                  NavigationDelegate(onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
              }, onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');

                // Inject JavaScript to log page content
                controller.runJavaScript('''
                        setTimeout(function(){
                          var status = window['checkStatus']();
                          if(status == 'closeApp'){
                            FlutterApp.postMessage(JSON.stringify({
                              'action': 'finishButtonClick',
                              'timestamp': new Date().getTime()
                            }));
                          }
                        }, 500);
                      ''');
              }));

              // Load the URL
              controller.loadRequest(Uri.parse(activityUrl));

              // Return the WebView widget
              return WebViewWidget(controller: controller);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ))));
  }
}

class NoActivityAttempts extends StatelessWidget {
  final bool canBuy;
  const NoActivityAttempts({
    super.key,
    required this.canBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(color: Colors.blue),
      child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Whoa There! Important Notice',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'You have reached the maximum number of attempts for the exercise. 😢',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'Please return to the main menu and continue with the enxt activity.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: FilledButton(
                  style: ButtonStyle(
                      alignment: Alignment.center,
                      backgroundColor: WidgetStateProperty.all(Colors.orange)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.navigate_before,
                          color: Colors.white,
                          size: 30,
                        ),
                        Text(
                          'Exit to the menu',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                      ])),
            ),
            canBuy
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: FilledButton(
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green)),
                        onPressed: () {},
                        child: Row(
                            spacing: 6,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                              ),
                              Text(
                                'Usar 99 mircoins',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ])),
                  )
                : SizedBox.shrink(),
          ]),
    );
  }
}
