// import 'dart:convert';
// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mir_companion_app/features/06_unit_activities/presentation/screens/unit_activities_screen.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import '../../../../core/utils/utils.dart';
// import '../../../../network/api_endpoints.dart';
// import '../../../02_auth/presentation/screens/auth_screen.dart';

// final unitActivityProvider = FutureProvider.autoDispose
//     .family<Map<String, dynamic>?, String>((ref, activityQuery) async {
//   Response<dynamic>? response;

//   try {
//     final dio = ref.read(dioProvider);
//     final authToken = ref.read(authTokenProvider);

//     if (authToken.isEmpty) {
//       debugPrint("No auth token found");
//       return {
//         "error": {"code": 401, "message": "Unauthorized"}
//       };
//     }

//     String fullUrl =
//         "${ApiEndpoints.baseURL}${ApiEndpoints.studentsEgp}$activityQuery";

//     response = await dio.get(fullUrl,
//         options: Options(headers: {
//           "X-Requested-With": "XMLHttpRequest",
//           "X-App-MirHorizon": createMD5Hash(),
//           "Authorization": "Bearer $authToken",
//         }));
//     return response.data;
//   } catch (e) {
//     debugPrint('Error fetching Unit\'s activity: $e');
//     // If response exists, return its error data
//     if (response != null && response.data != null) {
//       return response.data;
//     }
//     return {
//       "error": {"code": 500, "message": "Unexpected error occurred"}
//     };
//   }
// });

// // buyAttempt
// Future<void> buyAttempt(WidgetRef ref, int idActividad) async {
//   if (idActividad <= 0) return;

//   final stateNotifier = ref.read(buyAttemptStateProvider.notifier);
//   stateNotifier.state = BuyAttemptState.loading;

//   final authToken = ref.read(authTokenProvider);
//   if (authToken.isEmpty) {
//     debugPrint("No auth token found");
//   }

//   try {
//     final dio = ref.read(dioProvider);
//     String fullUrl =
//         "https://api.mironline.io/api/v1/students/egp/extra-attempt";

//     final requestData = {"id_actividad": idActividad};

//     Response response = await dio.post(fullUrl,
//         data: requestData,
//         options: Options(headers: {
//           "X-Requested-With": "XMLHttpRequest",
//           "X-App-MirHorizon": createMD5Hash(),
//           "Authorization": "Bearer $authToken"
//         }));

//     debugPrint("Response received: ${response.data}");

//     if (response.data["success"] == true) {
//       stateNotifier.state = BuyAttemptState.success;
//       debugPrint("Extra attempt purchased successfully");
//     } else {
//       stateNotifier.state = BuyAttemptState.error; // 🛑 Update state on failure
//       debugPrint("Buy attempt failed: ${response.data}");
//     }
//   } catch (e) {
//     if (e is DioException) {
//       debugPrint("Buy attempt error: ${e.response?.statusCode}");
//       debugPrint("Error message: ${e.response?.data}");
//       debugPrint("Request data: ${e.requestOptions.data}");
//       debugPrint("Request headers: ${e.requestOptions.headers}");
//     }

//     stateNotifier.state = BuyAttemptState.error; // 🛑 Update state on failure
//     debugPrint("Unhandled error: $e");
//   }
// }

// enum BuyAttemptState { initial, loading, success, error }

// final buyAttemptStateProvider = StateProvider.autoDispose<BuyAttemptState>(
//     (ref) => BuyAttemptState.initial);

// class WebViewActivityBefore extends ConsumerWidget {
//   final String activityQuery;
//   const WebViewActivityBefore({super.key, required this.activityQuery});

//   static const Map<String, String> specialCases = {
//     'out-of-tries-30': 'Use 30 mircoins to purchase an extra attempt',
//     'out-of-tries-50': 'Use 50 mircoins to purchase an extra attempt',
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final asyncActivity = ref.watch(unitActivityProvider(activityQuery));
//     final Map<String, void Function()> actionHandlers = {
//       'finishButtonClick': () {
//         ref.invalidate(studentUnitsActivities);
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) {
//           return UnitActivitiesScreen(
//               key: ValueKey(DateTime.now().millisecondsSinceEpoch),
//               queryParam: extractMiddleSegments(activityQuery));
//         }));
//       }
//     };

//     return PopScope(
//         canPop: false,
//         onPopInvoked: (bool didPop) async {
//           if (didPop) return;

//           // Show a confirmation dialog when the back button is pressed
//           final bool shouldExit = await showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                       title: const Text(
//                         'Are you sure?',
//                         textAlign: TextAlign.center,
//                       ),
//                       content: const Text('Do you want to exit the Activity?'),
//                       actions: [
//                         TextButton(
//                             onPressed: () => Navigator.of(context).pop(false),
//                             child: const Text('No')),
//                         TextButton(
//                             onPressed: () => Navigator.of(context).pop(true),
//                             child: const Text('Yes'))
//                       ]));

//           if (shouldExit) {
//             Navigator.of(context).pop();
//           }
//         },
//         child: Scaffold(
//             body: SafeArea(
//                 child: asyncActivity.when(
//           data: (activityData) {
//             if (activityData == null) {
//               inspect(activityData);
//               return Center(child: Text('Oops! This activity is empty!'));
//             }
//             inspect(activityData);
//             // Check if an error is present
//             if (activityData.containsKey("error")) {
//               return NoActivityAttemptsNotice(canBuy: false);
//             }
//             if (activityData['message'] == specialCases['out-of-tries-30'] ||
//                 activityData['message'] == specialCases['out-of-tries-50']) {
//               final activityId = activityData['data']['id_actividad'];
//               return Center(
//                   child: NoActivityAttemptsNotice(
//                       activityId: activityId,
//                       canBuy: true,
//                       message: activityData['message']));
//             } else {
//               final activityUrl = Uri.decodeFull(
//                   activityData['data']['actividad']['_links']['self']['href']);

//               // Create the controller first &  Configure it
//               final controller = WebViewController()
//                 ..setJavaScriptMode(JavaScriptMode.unrestricted);

//               // Add JavaScript channel for communication
//               controller.addJavaScriptChannel('FlutterApp',
//                   onMessageReceived: (JavaScriptMessage message) {
//                 // Log the message received from the WebView
//                 debugPrint('Message from WebView: ${message.message}');

//                 // Parse the JSON message (if applicable)
//                 try {
//                   final Map<String, dynamic> messageData =
//                       jsonDecode(message.message);
//                   final String action = messageData['action'];

//                   // Execute the handler for the given action
//                   if (actionHandlers.containsKey(action)) {
//                     actionHandlers[action]!(); // Call the handler function
//                   } else {
//                     debugPrint('Unknown action: $action');
//                   }
//                 } catch (e) {
//                   debugPrint('Failed to parse message: $e');
//                 }
//               });

//               // Set up navigation delegate to log page load events
//               controller.setNavigationDelegate(
//                   NavigationDelegate(onPageStarted: (String url) {
//                 debugPrint('Page started loading: $url');
//               }, onPageFinished: (String url) {
//                 debugPrint('Page finished loading: $url');

//                 // Inject JavaScript to log page content
//                 controller.runJavaScript('''
//                         setTimeout(function(){
//                           var status = window['checkStatus']();
//                           if(status == 'closeApp'){
//                             FlutterApp.postMessage(JSON.stringify({
//                               'action': 'finishButtonClick',
//                               'timestamp': new Date().getTime()
//                             }));
//                           }
//                         }, 500);
//                       ''');
//               }));

//               // Load the URL
//               controller.loadRequest(Uri.parse(activityUrl));

//               // Return the WebView widget
//               return WebViewWidget(controller: controller);
//             }
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, stackTrace) => Center(child: Text(error.toString())),
//         ))));
//   }
// }

// class NoActivityAttemptsNotice extends StatelessWidget {
//   final bool canBuy;
//   final int? activityId;
//   final String? message;

//   const NoActivityAttemptsNotice(
//       {super.key, required this.canBuy, this.activityId, this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.symmetric(horizontal: 30),
//         decoration: BoxDecoration(color: Colors.blue),
//         child: Column(
//             spacing: 12,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Whoa There! Important Notice',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600),
//               ),
//               Text(
//                 'You have reached the maximum number of attempts for the exercise. 😢',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//               Text(
//                 'Please return to the main menu and continue with the next activity.',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//               ),
//               Column(children: [
//                 SizedBox(
//                     width: double.infinity,
//                     child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16.0), // Adjust padding as needed
//                         child: FilledButton(
//                             style: ButtonStyle(
//                               alignment: Alignment.center,
//                               backgroundColor:
//                                   WidgetStateProperty.all(Colors.orange),
//                             ),
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.center, // Centers content
//                                 children: [
//                                   Icon(
//                                     Icons.navigate_before,
//                                     color: Colors.white,
//                                     size: 30,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Exit to the menu',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 18),
//                                   )
//                                 ])))),
//                 if (canBuy)
//                   SizedBox(
//                       width: double.infinity,
//                       child: Consumer(
//                         builder: (context, ref, child) {
//                           final buyAttemptState =
//                               ref.watch(buyAttemptStateProvider);
//                           // Show success or error messages
//                           WidgetsBinding.instance.addPostFrameCallback((_) {
//                             if (buyAttemptState == BuyAttemptState.success) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content: Text(
//                                         "✅ Extra attempt purchased successfully!"),
//                                     backgroundColor: Colors.green),
//                               );
//                             } else if (buyAttemptState ==
//                                 BuyAttemptState.error) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                     content:
//                                         Text("❌ Failed to purchase attempt!"),
//                                     backgroundColor: Colors.red),
//                               );
//                             }
//                           });

//                           return ElevatedButton(
//                               onPressed:
//                                   buyAttemptState == BuyAttemptState.loading
//                                       ? null
//                                       : () async {
//                                           await buyAttempt(ref, activityId!);
//                                         },
//                               style: ButtonStyle(
//                                   alignment: Alignment.center,
//                                   backgroundColor:
//                                       WidgetStateProperty.all(Colors.green)),
//                               child: buyAttemptState == BuyAttemptState.loading
//                                   ? CircularProgressIndicator(
//                                       color: Colors.white)
//                                   : Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                           Icon(Icons.star,
//                                               color: Colors.white, size: 30),
//                                           SizedBox(width: 8),
//                                           Text(message!,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.w700,
//                                                   fontSize: 18))
//                                         ]));
//                         },
//                       ))
//               ])
//             ]));
//   }
// }
