import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/utils/format_buy_msg.dart';
import '../../../06_unit_activities/presentation/screens/unit_activities_screen.dart';
import '../../domain/providers.dart';

// PASO 1: Convertido a ConsumerStatefulWidget
class WebViewActivity extends ConsumerStatefulWidget {
  final String activityQuery;
  const WebViewActivity({super.key, required this.activityQuery});

  @override
  ConsumerState<WebViewActivity> createState() => _WebViewActivityState();
}

// PASO 2: Toda la lógica ahora vive en la clase State
class _WebViewActivityState extends ConsumerState<WebViewActivity> {
  static const Map<String, String> specialCases = {
    'out-of-tries-30': 'Use 30 mircoins to purchase an extra attempt',
    'out-of-tries-50': 'Use 50 mircoins to purchase an extra attempt',
  };

  // PASO 3: El controller se declara aquí y se inicializa en initState
  late final WebViewController _webViewCtrl;

  @override
  void initState() {
    super.initState();
    // Se inicializa una SOLA VEZ
    _webViewCtrl = WebViewController();
  }

  // PASO 4: Centralizamos la lógica de salida
  void _exitActivity() {
    debugPrint("--- _exitActivity FUE LLAMADA ---");

    // 1. Invalida el estado como antes. Esta acción es síncrona y rápida.
    ref.invalidate(studentUnitsActivities);

    // 2. Programa la navegación para que ocurra después de que el frame actual se complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 3. La comprobación 'mounted' es extra importante aquí,
      // ya que esto se ejecuta un poco más tarde.
      if (mounted) {
        debugPrint("--- Ejecutando Navigator.pop DESPUÉS del frame ---");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos widget.activityQuery para acceder a los parámetros del widget
    final asyncActivity = ref.watch(unitActivityProvider(widget.activityQuery));

    final Map<String, void Function(WidgetRef)> actionHandlers = {
      // Ahora llaman a la función centralizada
      'finishButtonClick': (_) => _exitActivity(),
      // 2. 'retryButtonClick' ahora tiene su propia lógica específica.
      'retryButtonClick': (ref) {
        debugPrint(
            'Acción de reintento: invalidando el provider de la actividad...');
        // Invalida el provider para forzar una nueva llamada a la API y recargar los datos.
        // La UI se reconstruirá automáticamente gracias a ref.watch().
        ref.invalidate(unitActivityProvider(widget.activityQuery));
      },
    };

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) {
          _exitActivity();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: asyncActivity.when(
            data: (activityData) =>
                _buildActivityUI(activityData, actionHandlers),
            loading: () => const Center(child: CircularProgressIndicator()),
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityUI(
    Map<String, dynamic>? activityData,
    Map<String, void Function(WidgetRef)> actionHandlers,
  ) {
    if (activityData == null) {
      return Center(child: Text('Oops! This activity is empty!'));
    }
    if (activityData.containsKey("error")) {
      return NoActivityAttemptsNotice(canBuy: false);
    }
    // MEJORA: Verificación más limpia y escalable.
    if (specialCases.values.contains(activityData['message'])) {
      final activityId = activityData['data']['id_actividad'];
      return NoActivityAttemptsNotice(
        activityId: activityId,
        canBuy: true,
        message: activityData['message'],
      );
    } else {
      // necesita pasar actionHandlers
      return _buildWebView(activityData, actionHandlers);
    }
  }

  Widget _buildWebView(
    Map<String, dynamic> activityData,
    Map<String, void Function(WidgetRef)> actionHandlers,
  ) {
    final activityUrl = Uri.decodeFull(
        activityData['data']['actividad']['_links']['self']['href']);

    // El controller ya solo lo configuramos.
    _webViewCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MironlineChannel',
        onMessageReceived: (javaScriptMsg) {
          // Ahora 'ref' está disponible en todo el State, por lo que la llamada es válida.
          _handleJavaScriptMsg(javaScriptMsg, actionHandlers);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => debugPrint('Page started loading: $url'),
        onPageFinished: (url) {
          // Usamos el controller de la clase State
          _injectJavaScript(_webViewCtrl);
        },
      ))
      ..loadRequest(Uri.parse(activityUrl));

    return WebViewWidget(controller: _webViewCtrl);
  }

  // Ahora no necesita 'ref' como parámetro, porque ya es parte del State.
  void _handleJavaScriptMsg(
    JavaScriptMessage javaScriptMsg,
    Map<String, void Function(WidgetRef)> actionHandlers,
  ) {
    try {
      final Map<String, dynamic> messageData =
          jsonDecode(javaScriptMsg.message);
      final String action = messageData['action'];
      if (actionHandlers.containsKey(action)) {
        // Le pasamos el 'ref' del State.
        actionHandlers[action]!(ref);
      } else {
        debugPrint('Unknown action: $action');
      }
    } catch (e) {
      debugPrint('Error al procesar el mensaje de WebView: $e');
    }
  }

// Dentro de tu clase _WebViewActivityState

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
    // --- Lógica para el botón FINISH
    // Buscamos el botón de reintentar por su ID 'finish'.
    const finishButton = document.getElementById('finish');
    
    // Si el botón existe, le añadimos un "escuchador" para el evento 'click'.
    if (finishButton) {
      finishButton.addEventListener('click', function() {
        // Cuando se hace clic, enviamos el mensaje para salir.
        MironlineChannel.postMessage(JSON.stringify({
          'action': 'finishButtonClick',
          'details': 'El usuario hizo clic en el botón de finish.'
        }));
      });
    }

    // --- Lógica para el botón REINTENTAR (la nueva implementación) ---
    // Buscamos el botón de reintentar por su ID 'retry'.
    const retryButton = document.getElementById('retry');
    
    // Si el botón existe, le añadimos un "escuchador" para el evento 'click'.
    if (retryButton) {
      retryButton.addEventListener('click', function() {
        // Cuando se hace clic, enviamos el mensaje para reintentar.
        MironlineChannel.postMessage(JSON.stringify({
          'action': 'retryButtonClick',
          'details': 'El usuario hizo clic en el botón de reintentar.'
        }));
      });
    }
  ''');
  }
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

    ref.listen(buyAttemptNotifierProvider, (previous, next) {
      if (!context.mounted) return;

      if (previous?.value != BuyAttemptState.success &&
          next.hasValue &&
          next.value == BuyAttemptState.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("✅ Extra attempt purchased successfully!"),
            backgroundColor: Colors.green));
      } else if (previous?.error != next.error && next.hasError) {
        final error = next.error;
        final errorMessage = (error is Exception)
            ? error.toString().replaceFirst('Exception: ', '')
            : "❌ Failed to purchase attempt!";

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
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
                          onPressed: buyAttemptState.isLoading
                              ? null
                              : () async {
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
                          style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green),
                          ),
                          child: buyAttemptState.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
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
                                    ]))))
          ])
        ]));
  }
}
