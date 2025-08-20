# Play Store Security Hardening Guide (Step-by-step, one change at a time)

This guide explains the key security vulnerabilities and Play Store compliance gaps detected in this Flutter project and shows how to fix them safely. Each item is an independent, incremental change you can apply, test, and roll back if needed.

Project paths referenced below are relative to the repository root: /home/user/webapp

Important: Don’t mix too many changes at once. Apply in order, validate, then continue.


Checklist overview
- [ ] 1. Disable cleartext HTTP and add a strict Network Security Config
- [ ] 2. Remove client-secret from the app (.env) and move the trust mechanism server-side
- [ ] 3. Harden WebView usage (domain allowlist, JS channel safety, Safe Browsing)
- [ ] 4. Enforce TLS and add API certificate pinning for Dio/http
- [ ] 5. Stop logging sensitive data and gate logs to debug only
- [ ] 6. Strengthen token storage and lifecycle
- [ ] 7. Obfuscate Dart code and harden release builds (R8/ProGuard + split debug info)
- [ ] 8. Secure signing and Play Integrity (optional but recommended)
- [ ] 9. Minimize permissions and review queries
- [ ] 10. Dependency hygiene (pin & update security-critical libs)
- [ ] 11. Privacy policy and Data safety form mapping (Play Console)


1) Disable cleartext HTTP and add a strict Network Security Config
Why
- AndroidManifest has android:usesCleartextTraffic="true" (android/app/src/main/AndroidManifest.xml:5). Even if you currently use HTTPS, this setting allows HTTP and can trigger Play warnings or weaken security.

Change
- Set usesCleartextTraffic to false and explicitly deny cleartext via Network Security Config.

Steps
1. Edit android/app/src/main/AndroidManifest.xml
   BEFORE:
   <application
       android:hardwareAccelerated="true"
       android:usesCleartextTraffic="true"
       ...>

   AFTER:
   <application
       android:hardwareAccelerated="true"
       android:usesCleartextTraffic="false"
       android:networkSecurityConfig="@xml/network_security_config"
       ...>

2. Create file: android/app/src/main/res/xml/network_security_config.xml
   Content:
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
     <base-config cleartextTrafficPermitted="false">
       <trust-anchors>
         <certificates src="system" />
       </trust-anchors>
     </base-config>
   </network-security-config>

3. Optional (debug-only): Allow cleartext in debug by creating android/app/src/debug/res/xml/network_security_config.xml with cleartextTrafficPermitted="true". Do not ship that in release.

Verification
- Run: adb shell dumpsys netstats (optional) and manual test: try loading an http:// URL from app (should fail). Ensure all your API endpoints are https://.
- Play Console pre-launch reports should no longer flag cleartext.

Rollback
- Remove android:networkSecurityConfig and set usesCleartextTraffic back to true (not recommended).


2) Remove client-secret from the app (.env) and move the trust mechanism server-side
Why
- The app computes a header X-App-MirHorizon using SECRET_KEY from .env (lib/core/utils/crypto.dart and lib/services/auth_service.dart). pubspec.yaml currently ships .env as an asset:
  flutter:
    assets:
      - .env
- Any secret inside the APK/IPA is recoverable. This is a critical vulnerability and violates the principle of not embedding secrets in clients.

Change
- Stop shipping .env, remove SECRET_KEY from the app, and move the trust/signature creation to your server. The server should generate any required time-based signature and validate it. The client must not contain the secret.

Steps
1. Remove .env from pubspec.yaml assets to prevent bundling:
   BEFORE:
     assets:
       - .env
       - assets/...
   AFTER:
     assets:
       - assets/...

2. Replace createMD5Hash() usage with a server-provided header or token.
   - Server approach A (recommended): On login, server returns a short-lived signed token (e.g., JWT or opaque token) for X-App-MirHorizon. Client just forwards it on each request.
   - Server approach B: Server computes the required header itself; client stops sending X-App-MirHorizon entirely.

3. Temporarily, to keep builds passing while backend changes are rolled out, gate the header to a non-secret value in debug only and omit it in release:
   - Wrap header injection in kDebugMode and remove from release.

4. Update lib/core/utils/crypto.dart (example replacement):
   // Remove dotenv and SECRET_KEY dependency entirely
   String createMD5Hash() {
     // Deprecated: moved to server. Return a constant in debug only if needed.
     return 'deprecated';
   }

5. Update all API call sites to stop relying on client-side SECRET_KEY derived header. Files involved:
   - lib/services/auth_service.dart (headers: X-App-MirHorizon)
   - lib/features/web_view_activity/... if applicable

Verification
- App still authenticates and API calls succeed using the new server-generated mechanism. Confirm with backend logs.

Rollback
- Not recommended. Re-adding secrets to the client reintroduces the vulnerability.


3) Harden WebView usage (domain allowlist, JS channel safety, Safe Browsing)
Why
- WebViewActivity sets JavaScriptMode.unrestricted and registers a JavaScriptChannel ('FlutterApp'). Without navigation filtering, any redirected content could message the channel. You must restrict which URLs can load and communicate.

Change
- Allowlist domains, deny external schemes, and keep JS-mode only where strictly necessary.

Steps
1. In lib/features/web_view_activity/presentation/screens/webview_activity_screen_refactor.dart update controller setup:
   controller
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..setNavigationDelegate(
       NavigationDelegate(
         onNavigationRequest: (request) {
           final uri = Uri.parse(request.url);
           const allowedHosts = {
             'api.mironline.io',
             'www.mironline.io',
           };
           // Allow only https and known hosts
           if (uri.scheme != 'https' || !allowedHosts.contains(uri.host)) {
             return NavigationDecision.prevent;
           }
           return NavigationDecision.navigate;
         },
         // Keep your onPageStarted/onPageFinished as-is
       ),
     );

2. If possible, scope JS to specific pages only. Where feasible, set JavaScriptMode.disabled on screens that don’t need JS.

3. Enable Safe Browsing explicitly on Android (default is on, but you can be explicit):
   In android/app/src/main/AndroidManifest.xml inside <application>:
   <meta-data android:name="android.webkit.WebView.EnableSafeBrowsing" android:value="true" />

4. Never inject secrets or tokens into JS. If you must communicate, send opaque, short-lived IDs.

Verification
- Attempt to navigate to http://example.com or market:// URLs in the WebView (should be blocked).
- Confirm pages on your allowed hosts load and the JS channel still works.

Rollback
- Remove the onNavigationRequest check (not recommended).


4) Enforce TLS and add API certificate pinning for Dio/http
Why
- Even with HTTPS, compromised networks and rogue CAs can enable MITM. Certificate pinning significantly raises the bar by binding your client to the backend’s certificate or public key.

Change
- Add pinning for api.mironline.io in your HTTP stack (Dio and http).

Steps (Dio example)
1. Add a pin validator to Dio’s HttpClientAdapter. Example (pin leaf cert SHA-256):

   import 'dart:io';
   import 'package:dio/dio.dart';
   import 'package:dio/io.dart';

   Dio buildPinnedDio(Set<String> allowedFingerprints) {
     final dio = Dio(BaseOptions(
       baseUrl: 'https://api.mironline.io',
       connectTimeout: const Duration(seconds: 10),
       receiveTimeout: const Duration(seconds: 10),
     ));

     (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
       client.badCertificateCallback = (X509Certificate cert, String host, int port) {
         if (host != 'api.mironline.io') return false;
         final der = cert.der;
         final digest = sha256.convert(der).toString();
         return allowedFingerprints.contains(digest);
       };
       return client;
     };

     return dio;
   }

- Compute your current certificate’s SHA-256 fingerprint (scripted or from browser/devops) and add it to allowedFingerprints. Plan for rotation by pinning 2–3 keys (current + next).

Steps (http package example)
- Use IOClient with a custom HttpClient and the same badCertificateCallback check.

Verification
- Successful calls to api.mironline.io.
- Calls to a MITM endpoint with a different cert should fail.

Rollback
- Remove the onHttpClientCreate pinning block.


5) Stop logging sensitive data and gate logs to debug only
Why
- auth_service.dart logs full responses (inspect(response)), which may contain tokens or PII. Logs can leak via logcat, crash reports, or 3rd-party SDKs.

Change
- Remove or redact sensitive logs; gate with kDebugMode; never log tokens, credentials, or full bodies.

Steps
1. Replace inspect(response) with minimal, redacted logging:
   if (kDebugMode) {
     debugPrint('Login response status: ${response.statusCode}');
   }

2. Never log headers containing Authorization. If you need to log, mask: Bearer ****abcd.

Verification
- Scan the code for debugPrint/print/log/inspect and ensure no PII/token is logged. Test a login flow and review logcat output.

Rollback
- Do not reintroduce sensitive logs.


6) Strengthen token storage and lifecycle
Why
- You already use flutter_secure_storage (good). Harden platform options and enforce rotation/expiry.

Change
- Use strict platform options, handle expiry, and clear on logout and token invalidation.

Steps
1. When creating FlutterSecureStorage, pass platform-specific options:
   final storage = const FlutterSecureStorage(
     aOptions: AndroidOptions(
       encryptedSharedPreferences: true,
       resetOnError: true,
     ),
     iOptions: IOSOptions(
       accessibility: KeychainAccessibility.first_unlock_this_device,
     ),
   );

2. Track token expiry server-side and respond with 401/419; on these codes, purge token and force re-auth.

3. Avoid putting tokens into WebView URLs or query params.

Verification
- Confirm tokens are not accessible after logout and that re-login is required when expired.

Rollback
- Use default options (less secure).


7) Obfuscate Dart code and harden release builds
Why
- Your Android build already enables minifyEnabled/shrinkResources for release, which protects native/Kotlin code. Dart code remains readable unless obfuscated.

Change
- Build with Dart obfuscation and split debug info. Keep mapping files out of the APK.

Steps
1. Build command:
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/YYYY-MM-DD

2. Store the split-debug-info directory securely (not in the repo). Never upload to Play.

3. Ensure ProGuard rules exist in android/app/proguard-rules.pro. If your project currently has a proguard-rules.pro under test/, move/duplicate it to android/app/.
   Example baseline rules:
   -keep class io.flutter.plugin.** { *; }
   -keep class io.flutter.embedding.** { *; }
   -keep class io.flutter.app.** { *; }
   -keep class io.flutter.plugins.** { *; }
   -keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
   -keep class io.flutter.plugins.webviewflutter.** { *; }

Verification
- Confirm AAB installs and runs. Stack traces should be symbolicated only with your split-debug-info files, not by default.

Rollback
- Build without --obfuscate and remove split-debug-info.


8) Secure signing and Play Integrity (recommended)
Why
- Protect against tampered installs and automated abuse.

Change
- Enable Play App Signing and verify on backend with Play Integrity API or reCAPTCHA v3 Android.

Steps
1. Opt into Play App Signing in Play Console.
2. Integrate Play Integrity API client-side and verify on backend before serving sensitive actions. Cache verdicts briefly and re-check periodically.

Verification
- Backend rejects requests from devices failing integrity.

Rollback
- Disable backend enforcement (not recommended).


9) Minimize permissions and review queries
Why
- Principle of least privilege. Your Manifest currently requests only INTERNET (good). Keep it that way unless a feature needs more. You also declare a queries block for PROCESS_TEXT used by Flutter text plugin (fine).

Change
- Avoid adding storage, contacts, location, phone state, or SMS permissions unless absolutely required. If you must, follow Google’s Sensitive Permissions policy and in-app disclosure UX.

Verification
- Play Console pre-launch report should list only INTERNET. Data safety should reflect actual collection.

Rollback
- Remove newly added permissions if not strictly necessary.


10) Dependency hygiene (pin & update security-critical libs)
Why
- Old SDKs can introduce known CVEs.

Change
- Update and pin critical dependencies:
  - dio: use latest 5.x
  - webview_flutter: latest 4.x
  - flutter_secure_storage: keep latest 9.x
  - google_sign_in, riverpod, freezed, json_serializable: update within compatibility
- On Android:
  - Kotlin: consider 1.9.24+ (match Flutter toolchain support)
  - Target SDK 34 already set; keep up to date when new requirements roll out

Steps
1. Update versions in pubspec.yaml conservatively and run flutter pub upgrade --major-versions in a branch.
2. Run your test suite and manual smoke tests.

Verification
- Build succeeds, no runtime regressions, no deprecation warnings you can’t address.

Rollback
- Revert pubspec.yaml changes and lockfile.


11) Privacy policy and Data safety form mapping (Play Console)
Why
- Play Store requires accurate disclosure of data collection, sharing, and security practices.

Change
- Document what data you collect (emails, auth tokens, usage), how it’s used, and retention. Provide a publicly accessible privacy policy URL. Complete the Data safety form truthfully.

Steps
1. Inventory data flows:
   - Login: email/password sent to api.mironline.io
   - Token stored in device secure storage
   - WebView loads activities from your domain
2. Document: purpose, processing, retention, user rights, contact email.
3. Ensure you provide account deletion or data deletion process if required by region.

Verification
- Play Console checks pass; no policy violations raised.

Rollback
- Keep the policy up-to-date as features change.


Appendix A: Suggested code snippets for quick reference
A1) WebView allowlist snippet (Dart)
NavigationDelegate(
  onNavigationRequest: (request) {
    final uri = Uri.parse(request.url);
    const allowedHosts = {'api.mironline.io', 'www.mironline.io'};
    if (uri.scheme != 'https' || !allowedHosts.contains(uri.host)) {
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  },
)

A2) Redacted logging helper (Dart)
String redactToken(String? v) {
  if (v == null || v.length < 8) return '***';
  return '${v.substring(0, 2)}****${v.substring(v.length - 2)}';
}

A3) Secure storage options (Dart)
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true, resetOnError: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
);

A4) Flutter build with obfuscation
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols/$(date +%F)


Notes specific to this repo
- android/app/src/main/AndroidManifest.xml contains usesCleartextTraffic="true" — fix per section 1.
- pubspec.yaml bundles .env (assets) — remove and migrate per section 2.
- lib/services/auth_service.dart uses createMD5Hash() from a secret — migrate per section 2 and remove sensitive logging per section 5.
- WebViewActivity uses JavaScript channel — harden per section 3.
- Ensure proguard-rules.pro is present under android/app/ (your repo has a test/proguard-rules.pro; copy/adjust as needed) and build releases with Dart obfuscation per section 7.

If you want, I can apply any one of these changes in a dedicated branch so you can test the impact incrementally.