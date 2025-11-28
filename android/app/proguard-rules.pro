# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# JsonSerializable (if used with dart:mirrors, though typically not needed for generated code, safer to keep models)
-keep class * implements androidx.annotation.Keep
-keep @androidx.annotation.Keep class *

# Rive
-keep class app.rive.rive.** { *; }

# Dio
-keep class dio.dio.** { *; }

# Models (Adjust package name to match your project's model structure if needed)
-keep class io.mironline.mir_companion_app.data.models.** { *; }
-keep class io.mironline.mir_companion_app.** { *; }

# Prevent warnings
-dontwarn io.flutter.**
-dontwarn javax.annotation.**
