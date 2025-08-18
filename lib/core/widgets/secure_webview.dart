import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/secure_logger.dart';

/// WebView seguro que previene ataques XSS y controla la ejecución de JavaScript
class SecureWebView extends StatefulWidget {
  final String url;
  final Map<String, void Function()>? actionHandlers;
  final List<String>? allowedDomains;
  final bool enableJavaScript;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;
  final Function(String)? onNavigationRequest;

  const SecureWebView({
    super.key,
    required this.url,
    this.actionHandlers,
    this.allowedDomains,
    this.enableJavaScript = false, // Por defecto DESHABILITADO por seguridad
    this.onPageStarted,
    this.onPageFinished,
    this.onNavigationRequest,
  });

  @override
  State<SecureWebView> createState() => _SecureWebViewState();
}

class _SecureWebViewState extends State<SecureWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  // Dominios permitidos por defecto (solo MiR Online)
  static const List<String> _defaultAllowedDomains = [
    'api.mironline.io',
    'mironline.io',
    'www.mironline.io',
  ];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    try {
      _controller = WebViewController()
        // ✅ SEGURIDAD: JavaScript controlado
        ..setJavaScriptMode(widget.enableJavaScript 
            ? JavaScriptMode.unrestricted 
            : JavaScriptMode.disabled)
        
        // ✅ SEGURIDAD: Validar navegación
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final allowed = _isUrlAllowed(request.url);
            
            if (!allowed) {
              SecureLogger.warning('Blocked navigation to unauthorized URL: ${request.url}');
              setState(() {
                _error = 'Navigation to ${request.url} is not allowed for security reasons.';
              });
              return NavigationDecision.prevent;
            }
            
            widget.onNavigationRequest?.call(request.url);
            return NavigationDecision.navigate;
          },
          
          onPageStarted: (String url) {
            SecureLogger.network('WebView page started: $url');
            setState(() {
              _isLoading = true;
              _error = null;
            });
            widget.onPageStarted?.call(url);
          },
          
          onPageFinished: (String url) {
            SecureLogger.network('WebView page finished: $url');
            setState(() {
              _isLoading = false;
            });
            
            // ✅ SEGURIDAD: Solo inyectar JavaScript si está habilitado
            if (widget.enableJavaScript && widget.actionHandlers != null) {
              _injectSecureJavaScript();
            }
            
            widget.onPageFinished?.call(url);
          },
          
          onWebResourceError: (WebResourceError error) {
            SecureLogger.error('WebView resource error: ${error.description}');
            setState(() {
              _isLoading = false;
              _error = 'Failed to load content: ${error.description}';
            });
          },
        ));

      // ✅ SEGURIDAD: Solo agregar canal JavaScript si está habilitado
      if (widget.enableJavaScript && widget.actionHandlers != null) {
        _setupSecureJavaScriptChannel();
      }

      // Cargar la URL inicial
      if (_isUrlAllowed(widget.url)) {
        _controller.loadRequest(Uri.parse(widget.url));
      } else {
        setState(() {
          _error = 'URL ${widget.url} is not allowed for security reasons.';
        });
      }
      
    } catch (e) {
      SecureLogger.error('Failed to initialize WebView controller', error: e);
      setState(() {
        _error = 'Failed to initialize WebView';
      });
    }
  }

  /// Verifica si una URL está permitida
  bool _isUrlAllowed(String url) {
    try {
      final uri = Uri.parse(url);
      final allowedDomains = widget.allowedDomains ?? _defaultAllowedDomains;
      
      return allowedDomains.any((domain) => 
        uri.host == domain || uri.host.endsWith('.$domain'));
    } catch (e) {
      SecureLogger.warning('Invalid URL format: $url');
      return false;
    }
  }

  /// Configura el canal JavaScript de forma segura
  void _setupSecureJavaScriptChannel() {
    _controller.addJavaScriptChannel(
      'SecureFlutterApp', // Nombre específico para evitar conflictos
      onMessageReceived: (JavaScriptMessage message) {
        _handleSecureJavaScriptMessage(message.message);
      },
    );
  }

  /// Maneja mensajes JavaScript de forma segura
  void _handleSecureJavaScriptMessage(String message) {
    try {
      SecureLogger.network('WebView JavaScript message received');
      
      // ✅ SEGURIDAD: Validar y sanitizar el mensaje
      final sanitizedMessage = _sanitizeJavaScriptMessage(message);
      if (sanitizedMessage == null) {
        SecureLogger.warning('Invalid JavaScript message blocked');
        return;
      }

      final Map<String, dynamic> messageData = jsonDecode(sanitizedMessage);
      final String? action = messageData['action'];

      if (action != null && widget.actionHandlers?.containsKey(action) == true) {
        SecureLogger.network('Executing WebView action: $action');
        widget.actionHandlers![action]!();
      } else {
        SecureLogger.warning('Unknown or unauthorized WebView action: $action');
      }
      
    } catch (e) {
      SecureLogger.error('Failed to parse JavaScript message', error: e);
    }
  }

  /// Sanitiza mensajes JavaScript para prevenir ataques
  String? _sanitizeJavaScriptMessage(String message) {
    if (message.isEmpty || message.length > 1000) {
      return null; // Mensaje muy largo o vacío
    }
    
    // Verificar que sea JSON válido
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      
      // Validar estructura esperada
      if (!decoded.containsKey('action')) {
        return null;
      }
      
      return message;
    } catch (e) {
      return null;
    }
  }

  /// Inyecta JavaScript de forma segura
  void _injectSecureJavaScript() {
    final secureScript = '''
      (function() {
        // ✅ SEGURIDAD: Script controlado y limitado
        function sendSecureMessage(action, data) {
          try {
            const message = {
              action: action,
              timestamp: new Date().getTime(),
              data: data || {}
            };
            
            if (window.SecureFlutterApp) {
              window.SecureFlutterApp.postMessage(JSON.stringify(message));
            }
          } catch (e) {
            console.error('Failed to send secure message:', e);
          }
        }
        
        // Verificar estado de actividad (si existe)
        if (typeof window.checkStatus === 'function') {
          setTimeout(function() {
            try {
              const status = window.checkStatus();
              if (status === 'closeApp') {
                sendSecureMessage('finishButtonClick');
              }
            } catch (e) {
              console.error('Status check failed:', e);
            }
          }, 500);
        }
        
        // Exponer función segura globalmente
        window.sendToFlutter = sendSecureMessage;
      })();
    ''';

    _controller.runJavaScript(secureScript);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Security Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}