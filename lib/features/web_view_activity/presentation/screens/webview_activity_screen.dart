import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/utils/format_buy_msg.dart';
import '../../../06_unit_activities/presentation/screens/unit_activities_screen.dart';
import '../../domain/providers.dart';

class WebViewActivity extends ConsumerWidget {
  final String activityQuery;
  const WebViewActivity({super.key, required this.activityQuery});

  static const Map<String, String> specialCases = {
    'out-of-tries-30': 'Use 30 mircoins to purchase an extra attempt',
    'out-of-tries-50': 'Use 50 mircoins to purchase an extra attempt',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivity = ref.watch(unitActivityProvider(activityQuery));

    // Define action handlers for JavaScript communication
    final Map<String, void Function()> actionHandlers = {
      'finishButtonClick': () {
        ref.invalidate(studentUnitsActivities);
        Navigator.pop(context);
      },
    };

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;
          final bool shouldExit = await _showExitConfirmationDialog(context);
          if (!context.mounted) return;
          if (shouldExit) {
            ref.invalidate(studentUnitsActivities);
            Navigator.pop(context);
          }
        },
        child: Scaffold(
            body: SafeArea(
                child: asyncActivity.when(
                    data: (activityData) =>
                        _buildActivityUI(ref, activityData, actionHandlers),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) {
                      debugPrint("Error loading activity: $error");

                      String errorMessage =
                          "Something went wrong. Please try again later.";

                      if (error is Exception) {
                        final extractedMessage = (error as dynamic).message;
                        if (extractedMessage is Map<String, dynamic> &&
                            extractedMessage.containsKey('message')) {
                          errorMessage = extractedMessage['message'];
                        }
                      }

                      return NoActivityAttemptsNotice(
                        canBuy: false,
                        message: errorMessage,
                      );
                    }))));
  }

  Widget _buildActivityUI(
    WidgetRef ref,
    Map<String, dynamic>? activityData,
    Map<String, void Function()> actionHandlers,
  ) {
    if (activityData == null) {
      return Center(child: Text('Oops! This activity is empty!'));
    }
    if (activityData.containsKey("error")) {
      return NoActivityAttemptsNotice(canBuy: false);
    }
    if (activityData['message'] == specialCases['out-of-tries-30'] ||
        activityData['message'] == specialCases['out-of-tries-50']) {
      final activityId = activityData['data']['id_actividad'];
      return NoActivityAttemptsNotice(
        activityId: activityId,
        canBuy: true,
        message: activityData['message'],
      );
    } else {
      return _buildWebView(activityData, actionHandlers);
    }
  }

  Widget _buildWebView(
    Map<String, dynamic> activityData,
    Map<String, void Function()> actionHandlers,
  ) {
    final activityUrl = Uri.decodeFull(
        activityData['data']['actividad']['_links']['self']['href']);

    // Initialize the controller first
    final controller = WebViewController();

    // Configure the controller
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('FlutterApp', onMessageReceived: (message) {
        _handleJavaScriptMessage(message, actionHandlers);
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => debugPrint('Page started loading: $url'),
        onPageFinished: (url) {
          _injectJavaScript(controller);
        },
      ))
      ..loadRequest(Uri.parse(activityUrl));

    return WebViewWidget(controller: controller);
  }

  void _handleJavaScriptMessage(
    JavaScriptMessage message,
    Map<String, void Function()> actionHandlers,
  ) {
    debugPrint('Message from WebView: ${message.message}');
    try {
      final Map<String, dynamic> messageData = jsonDecode(message.message);
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
  }

  void _injectJavaScript(WebViewController controller) {
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
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?', textAlign: TextAlign.center),
            content: const Text('Do you want to exit the Activity?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes')),
            ],
          ),
        ) ??
        false;
  }
}

class NoActivityAttemptsNotice extends ConsumerWidget {
  final bool canBuy;
  final int? activityId;
  final String? message;

  const NoActivityAttemptsNotice({
    super.key,
    required this.canBuy,
    this.activityId,
    this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buyAttemptState = ref.watch(buyAttemptNotifierProvider);
    final notifier = ref.read(buyAttemptNotifierProvider.notifier);

    // Watch the unitActivityProvider to trigger a reload when invalidated
    ref.watch(unitActivityProvider('your_activity_query_here'));

    ref.listen(buyAttemptNotifierProvider, (previous, next) {
      if (!context.mounted) return;

      switch (next) {
        case AsyncData(:final value):
          if (value == BuyAttemptState.success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("✅ Extra attempt purchased successfully!"),
                backgroundColor: Colors.green));
          }
        case AsyncError(:final error):
          final errorMessage = (error is Exception)
              ? error.toString().replaceFirst('Exception: ', '')
              : "❌ Failed to purchase attempt!";
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
        default:
          break;
      }
    });

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(color: Colors.blue),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Whoa There! Important Notice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'You have reached the maximum number of attempts for the exercise. 😢',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Please return to the main menu and continue with the next activity.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Column(children: [
            SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FilledButton(
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor:
                              WidgetStateProperty.all(Colors.orange),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.navigate_before,
                                  color: Colors.white, size: 30),
                              SizedBox(width: 8),
                              Text('Exit to the menu',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18))
                            ])))),
            if (canBuy)
              SizedBox(
                  width: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                          onPressed: buyAttemptState.maybeWhen(
                              loading: () => null,
                              orElse: () => () async {
                                  if (activityId == null || activityId! <= 0) {
                                    debugPrint(
                                        "Invalid activity ID: $activityId");
                                    return;
                                  }
                                  try {
                                    debugPrint(
                                        "Buy attempt button pressed for activity ID: $activityId");
                                    await notifier.buyAttempt(activityId!);
                                  } catch (e) {
                                    debugPrint(
                                        "Error in buy attempt button: $e");
                                  }
                                },
                            ),
                          style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green),
                          ),
                          child: buyAttemptState.maybeWhen(
                              loading: () => CircularProgressIndicator(color: Colors.white),
                              orElse: () => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.star,
                                          color: Colors.white, size: 30),
                                      SizedBox(width: 8),
                                      Text(truncateAtMircoins(message!),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18))
                                    ])))))
          ])
        ]));
  }
}
