import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Web OAuth client ID (google-services.json client_type 3 / Firebase "Web
// client (auto created by Google Service)"). Credential Manager
// (google_sign_in 7.x) needs this as the serverClientId to mint an idToken
// whose audience Firebase accepts. The same value works for Android and iOS.
// Not secret — it ships embedded in every client build.
const String _serverClientId =
    '67449654316-nj10g9vm0vsv3to58gfountgep6cool4.apps.googleusercontent.com';

// google_sign_in 7.x requires initialize() to run exactly once before any
// other call. Memoize the Future so rapid double-taps share a single init.
Future<void>? _initFuture;
Future<void> _ensureInitialized() =>
    _initFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );

/// Sign in with Google on Android, iOS, and web, then exchange the Google
/// idToken for a Firebase credential. Returns null if the user cancels the
/// picker; rethrows real failures so the UI can surface them.
Future<UserCredential?> googleSignInFunc() async {
  try {
    // Web keeps the popup flow — authenticate() isn't supported there.
    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    }

    await _ensureInitialized();

    // Clear any cached session so the account chooser always appears.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    if (!(await GoogleSignIn.instance.supportsAuthenticate())) {
      throw StateError(
          'Interactive Google sign-in is not supported on this platform.');
    }

    final account = await GoogleSignIn.instance.authenticate(
      scopeHint: const ['email', 'profile'],
    );

    // In 7.x `authentication` is a synchronous getter exposing only the
    // idToken — which is all Firebase needs. accessToken is no longer
    // returned here and isn't required for signInWithCredential.
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      debugPrint('❌ Google Sign-In: no idToken returned');
      return null;
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on GoogleSignInException catch (e) {
    // Cancellation is a normal no-op, not an error worth surfacing.
    if (e.code == GoogleSignInExceptionCode.canceled) {
      debugPrint('🔵 Google Sign-In: cancelled by user');
      return null;
    }
    debugPrint('❌ Google Sign-In: ${e.code.name} — ${e.description}');
    rethrow;
  } catch (e, st) {
    debugPrint('❌ Google Sign-In: FATAL: $e\n$st');
    rethrow;
  }
}

Future<void> signOutWithGoogle() => GoogleSignIn.instance.signOut();
