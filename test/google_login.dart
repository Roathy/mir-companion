// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:async';
// import 'dart:convert';

// import 'package:mironline/features/02_auth/presentation/screens/auth_screen.dart';
// import 'package:mironline/network/api_client.dart';

// // Configuración de Google Sign-In con los scopes básicos
// const List<String> scopes = <String>[
//   'email',
//   'profile',
//   'openid', // Necesario para obtener idToken
// ];

// // Función helper para crear el hash MD5
// String createMD5Hash() {
//   // Reemplaza con tu llave privada de la aplicación
//   String privateKey = "tu_llave_privada_aqui";
//   var bytes = utf8.encode(privateKey);
//   var digest = md5.convert(bytes);
//   return digest.toString();
// }

// // Clase para manejar el estado de Google Sign-In
// class GoogleSignInService {
//   static GoogleSignInService? _instance;
//   static GoogleSignInService get instance =>
//       _instance ??= GoogleSignInService._();

//   GoogleSignInService._();

//   GoogleSignInAccount? _currentUser;
//   bool _isInitialized = false;
//   final Completer<void> _initCompleter = Completer<void>();

//   GoogleSignInAccount? get currentUser => _currentUser;
//   bool get isSignedIn => _currentUser != null;

//   // Inicializar Google Sign-In con los parámetros correctos
//   Future<void> initialize({
//     String? clientId,
//     String? serverClientId,
//   }) async {
//     if (_isInitialized) return _initCompleter.future;

//     try {
//       final GoogleSignIn signIn = GoogleSignIn.instance;

//       await signIn.initialize(
//         clientId: clientId,
//         serverClientId: serverClientId,
//       );

//       // Escuchar eventos de autenticación
//       signIn.authenticationEvents
//           .listen(_handleAuthenticationEvent)
//           .onError(_handleAuthenticationError);

//       // Intentar autenticación ligera (silenciosa)
//       unawaited(signIn.attemptLightweightAuthentication());

//       _isInitialized = true;
//       _initCompleter.complete();
//     } catch (e) {
//       _initCompleter.completeError(e);
//       rethrow;
//     }

//     return _initCompleter.future;
//   }

//   Future<void> _handleAuthenticationEvent(
//       GoogleSignInAuthenticationEvent event) async {
//     _currentUser = switch (event) {
//       GoogleSignInAuthenticationEventSignIn() => event.user,
//       GoogleSignInAuthenticationEventSignOut() => null,
//     };
//   }

//   Future<void> _handleAuthenticationError(Object e) async {
//     _currentUser = null;
//     print('Google Sign-In Authentication Error: $e');
//   }

//   // Método para obtener el idToken del usuario actual
//   Future<String?> getIdToken() async {
//     if (_currentUser == null) return null;

//     try {
//       final GoogleSignInAuthentication authentication =
//           _currentUser!.authentication;
//       return authentication.idToken;
//     } catch (e) {
//       print('Error getting idToken: $e');
//       return null;
//     }
//   }

//   // Método para obtener el serverAuthCode (para backend)
//   Future<String?> getServerAuthCode() async {
//     if (_currentUser == null) return null;

//     try {
//       // Autorizar scopes para obtener serverAuthCode
//       final GoogleSignInServerAuthorization? authorization =
//           await _currentUser!.authorizationClient.authorizeServer(scopes);
//       return authorization?.serverAuthCode;
//     } catch (e) {
//       print('Error getting serverAuthCode: $e');
//       return null;
//     }
//   }

//   // Método para hacer sign out
//   Future<void> signOut() async {
//     try {
//       await GoogleSignIn.instance.signOut();
//       _currentUser = null;
//     } catch (e) {
//       print('Error during sign out: $e');
//     }
//   }

//   // Método para desconectar completamente
//   Future<void> disconnect() async {
//     try {
//       await GoogleSignIn.instance.disconnect();
//       _currentUser = null;
//     } catch (e) {
//       print('Error during disconnect: $e');
//     }
//   }
// }

// // Función principal de login con Google
// Future<LoginResult> googleLogin(WidgetRef ref) async {
//   try {
//     // 1. Asegurar que Google Sign-In esté inicializado
//     await GoogleSignInService.instance.initialize(
//         // Opcionalmente puedes pasar clientId y serverClientId aquí
//         // clientId: "tu_client_id.apps.googleusercontent.com",
//         // serverClientId: "tu_server_client_id.apps.googleusercontent.com",
//         );

//     // 2. Verificar si el usuario ya está autenticado
//     if (!GoogleSignInService.instance.isSignedIn) {
//       // 3. Realizar autenticación interactiva si es necesario
//       if (GoogleSignIn.instance.supportsAuthenticate()) {
//         await GoogleSignIn.instance.authenticate();
//       } else {
//         return LoginResult(
//             status: LoginStatus.failure,
//             message: "Esta plataforma no soporta autenticación con Google");
//       }
//     }

//     // 4. Verificar que el usuario esté autenticado después del proceso
//     if (!GoogleSignInService.instance.isSignedIn) {
//       return LoginResult(
//           status: LoginStatus.failure,
//           message: "No se pudo completar la autenticación con Google");
//     }

//     // 5. Obtener el idToken
//     final String? idToken = await GoogleSignInService.instance.getIdToken();

//     if (idToken == null) {
//       return LoginResult(
//           status: LoginStatus.failure,
//           message: "No se pudo obtener el token de Google");
//     }

//     // 6. Realizar petición POST al endpoint personalizado
//     final dio = ref.read(dioProvider);
//     String fullUrl = "https://api.mironline.io/api/v1/students/login";

//     Response response = await dio.post(
//       fullUrl,
//       data: {
//         "google_token": idToken,
//       },
//       options: Options(headers: {
//         "X-Requested-With": "XMLHttpRequest",
//         "X-App-MirHorizon": createMD5Hash(),
//       }),
//     );

//     // 7. Procesar la respuesta del servidor
//     if (response.data["success"] == true) {
//       String? token = response.data['data']['token'];

//       if (token != null && token.isNotEmpty) {
//         // 8. Guardar el token en storage seguro
//         final storage = FlutterSecureStorage();
//         await storage.write(key: 'auth_token', value: token);

//         // 9. Actualizar el provider de auth token
//         ref.read(authTokenProvider.notifier).state = token;

//         return LoginResult(status: LoginStatus.success);
//       } else {
//         return LoginResult(
//             status: LoginStatus.failure,
//             message: "Token no válido recibido del servidor");
//       }
//     } else {
//       String errorMessage = response.data['error']?['message'] ??
//           'Error desconocido del servidor';
//       return LoginResult(status: LoginStatus.failure, message: errorMessage);
//     }
//   } on DioException catch (e) {
//     // Manejo de errores HTTP
//     String errorMessage;

//     if (e.response != null) {
//       errorMessage = e.response!.data['error']?['message'] ??
//           'Error del servidor: ${e.response!.statusCode}';
//     } else {
//       errorMessage = 'Error de conexión: ${e.message}';
//     }

//     return LoginResult(status: LoginStatus.failure, message: errorMessage);
//   } on GoogleSignInException catch (e) {
//     // Manejo específico de errores de Google Sign-In
//     String errorMessage = switch (e.code) {
//       GoogleSignInExceptionCode.canceled => 'Inicio de sesión cancelado',
//       GoogleSignInExceptionCode.interrupted =>
//         'Error de red. Verifica tu conexión',
//       _ => 'Error de Google Sign-In: ${e.description}',
//     };

//     return LoginResult(status: LoginStatus.failure, message: errorMessage);
//   } catch (e) {
//     // Manejo de otros errores
//     return LoginResult(
//         status: LoginStatus.failure,
//         message: 'Error inesperado: ${e.toString()}');
//   }
// }

// // Función para sign out completo
// Future<void> googleSignOut(WidgetRef ref) async {
//   try {
//     // Sign out de Google
//     await GoogleSignInService.instance.signOut();

//     // Limpiar el storage local
//     final storage = FlutterSecureStorage();
//     await storage.delete(key: 'auth_token');

//     // Limpiar el provider
//     ref.read(authTokenProvider.notifier).state = '';
//   } catch (e) {
//     print('Error durante sign out: $e');
//   }
// }
