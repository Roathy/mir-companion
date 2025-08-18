import '../config/app_config.dart';

/// ✅ SEGURO: Genera hash MD5 usando configuración segura
/// Reemplaza la función anterior que tenía secret hardcodeado
String createMD5Hash() {
  return AppConfig.createSecureHash();
}

/// Función deprecada - Usar createMD5Hash() en su lugar
@Deprecated('Use createMD5Hash() instead. This function had hardcoded secrets.')
String createMD5HashOld() {
  throw Exception('This function is deprecated due to security vulnerabilities. Use createMD5Hash() instead.');
}
