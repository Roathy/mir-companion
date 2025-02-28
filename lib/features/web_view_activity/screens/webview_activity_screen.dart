import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mir_companion_app/features/06_unit_activities/view/pages/unit_activities_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../network/api_endpoints.dart';
import '../../02_auth/presentation/auth_screen.dart';

String extractMiddleSegments(String input) {
  // Split the string by '/'
  final segments = input.split('/');

  // Ensure there are at least 3 segments (e.g., "egp/a11/u1/any_integer")
  if (segments.length >= 3) {
    // Return the second and third segments joined by '/'
    return '${segments[1]}/${segments[2]}';
  }

  // If there are fewer than 3 segments, return the original string
  return input;
}

final unitActivityProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, queryParam) async {
  try {
    final dio = ref.read(dioProvider);
    final authToken = ref.read(authTokenProvider);

    if (authToken.isEmpty) {
      debugPrint("No auth token found");
      return null;
    }
    String fullUrl = "${ApiEndpoints.baseURL}students/$queryParam";
    Response response = await dio.get(fullUrl,
        options: Options(headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-App-MirHorizon": createMD5Hash(),
          "Authorization": "Bearer $authToken",
        }));

    if (!response.data.containsKey('data')) {
      throw Exception('API response is missing "data" key');
    }

    return response.data['data'];
  } catch (e) {
    debugPrint("Error fetching Unit's [activity]: $e");
    return null;
  }
});

class WebViewActivity extends ConsumerWidget {
  final String queryParam;

  const WebViewActivity({super.key, required this.queryParam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivity = ref.watch(unitActivityProvider(queryParam));

    // Define the action handlers map
    final Map<String, void Function()> actionHandlers = {
      'finishButtonClick': () {
        inspect(extractMiddleSegments(queryParam));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return UnitActivitiesScreen(
              queryParam: extractMiddleSegments(queryParam));
        }));
      }
    };

    return PopScope(
        canPop: false, // Disable default back button behavior
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
          data: (data) {
            if (data == null) {
              return const Center(child: Text('No activity found'));
            } else {
              final url = '${data['actividad']?['_links']?['self']?['href']}';

              // Create the controller first
              final controller = WebViewController();

              // Configure the controller
              controller.setJavaScriptMode(JavaScriptMode.unrestricted);

              // Add JavaScript channel for communication
              controller.addJavaScriptChannel(
                'FlutterApp',
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
                },
              );

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
              controller.loadRequest(Uri.parse(url));

              // Return the WebView widget
              return WebViewWidget(controller: controller);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        ))));
  }
}
