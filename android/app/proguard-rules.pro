# Reglas ProGuard para mironline companion app
# Configuración específica para Flutter y dependencias del proyecto

# =============================================================================
# FLUTTER CORE - Reglas esenciales para el framework
# =============================================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Flutter engine JNI
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# =============================================================================
# GOOGLE SERVICES - Google Sign-In y Firebase
# =============================================================================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign-In específico
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# =============================================================================
# RIVERPOD - State Management con reflection
# =============================================================================
-keep class **$$ExternalSyntheticLambda** { *; }
-keep class * extends com.riverpod.** { *; }
-keepclassmembers class * {
    @riverpod_annotation.* *;
}

# Riverpod generated code
-keep class **$Provider { *; }
-keep class **$Family { *; }

# =============================================================================
# JSON Y SERIALIZACIÓN - Preservar para API calls
# =============================================================================
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.** { *; }

# JSON annotation support
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
  @json_annotation.JsonKey <fields>;
  @json_annotation.JsonSerializable <methods>;
}

# JSON reflection
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Freezed generated classes (common with JSON)
-keep class **$_** { *; }

# =============================================================================
# WEBVIEW - Para contenido web embebido
# =============================================================================
-keep class * extends android.webkit.WebViewClient { *; }
-keep class * extends android.webkit.WebView { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}

# WebView JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# =============================================================================
# STORAGE - SharedPreferences y Secure Storage
# =============================================================================
-keep class * extends android.security.keystore.** { *; }
-keep class androidx.preference.** { *; }
-keep class androidx.security.crypto.** { *; }

# Flutter Secure Storage
-keep class androidx.biometric.** { *; }

# =============================================================================
# CRYPTO Y SEGURIDAD - Para MD5 operations en crypto.dart
# =============================================================================
-keep class java.security.** { *; }
-keep class javax.crypto.** { *; }
-keep class java.security.MessageDigest { *; }

# Mantener algoritmos de hash
-keep class java.security.NoSuchAlgorithmException { *; }

# =============================================================================
# ANIMACIONES RIVE - Para assets animados
# =============================================================================
-keep class app.rive.** { *; }
-dontwarn app.rive.**
-keep class app.rive.runtime.** { *; }

# =============================================================================
# DIO HTTP CLIENT - Para API calls
# =============================================================================
-keep class dio.** { *; }
-keep class * extends dio.** { *; }

# Interceptors
-keep class * extends dio.Interceptor { *; }

# =============================================================================
# APP ESPECÍFICO - Código del proyecto mironline
# =============================================================================
-keep class io.mironline.mir_companion_app.** { *; }
-keep class mironline.** { *; }

# MainActivity y clases principales
-keep class io.mironline.mir_companion_app.MainActivity { *; }

# =============================================================================
# DEBUGGING Y CRASH REPORTS - Información para producción
# =============================================================================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Mantener excepciones para crash reports
-keep class * extends java.lang.Exception { *; }
-keep class * extends java.lang.RuntimeException { *; }
-keep class * extends java.lang.Error { *; }

# Stack traces
-keepattributes LineNumberTable,SourceFile

# =============================================================================
# KOTLIN - Soporte para Kotlin stdlib
# =============================================================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# =============================================================================
# GOOGLE FONTS - Para fuentes personalizadas
# =============================================================================
-keep class com.google.fonts.** { *; }
-dontwarn com.google.fonts.**

# =============================================================================
# INTL - Para internacionalización
# =============================================================================
-keep class java.text.** { *; }
-keep class java.util.Locale { *; }

# =============================================================================
# OPTIMIZACIONES - Performance sin romper funcionalidad
# =============================================================================
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# No optimizar demasiado agresivamente
-dontoptimize

# =============================================================================
# CONFIGURACIONES ADICIONALES
# =============================================================================
# Evitar warnings innecesarios
-dontwarn org.slf4j.**
-dontwarn org.apache.**
-dontwarn okio.**
-dontwarn okhttp3.**

# Mantener enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}