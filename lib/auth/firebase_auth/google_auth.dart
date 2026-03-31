import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['profile', 'email'],
);

Future<UserCredential?> googleSignInFunc() async {
  try {
    print('🔵 Google Sign-In: Starting...');

    if (kIsWeb) {
      print('🔵 Google Sign-In: Web platform detected');
      return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    }

    print('🔵 Google Sign-In: Mobile platform detected');
    print('🔵 Google Sign-In: Signing out existing session...');
    await signOutWithGoogle().catchError((e) {
      print('⚠️ Google Sign-In: Sign out error (ignorable): $e');
      return null;
    });

    print('🔵 Google Sign-In: Initiating sign in...');
    final googleUser = await _googleSignIn.signIn();
    print('🔵 Google Sign-In: User selected: ${googleUser?.email ?? "null"}');

    if (googleUser == null) {
      print('❌ Google Sign-In: User cancelled or sign in returned null');
      return null;
    }

    print('🔵 Google Sign-In: Getting authentication...');
    final auth = await googleUser.authentication;

    if (auth.idToken == null || auth.accessToken == null) {
      print('❌ Google Sign-In: Missing tokens - idToken: ${auth.idToken != null}, accessToken: ${auth.accessToken != null}');
      return null;
    }

    print('🔵 Google Sign-In: Creating Firebase credential...');
    final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken, accessToken: auth.accessToken);

    print('🔵 Google Sign-In: Signing in with Firebase...');
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    print('✅ Google Sign-In: Success! User: ${userCredential.user?.email}');
    return userCredential;
  } catch (e, stackTrace) {
    print('❌ Google Sign-In: FATAL ERROR: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow; // Re-throw to see the error in the UI
  }
}

Future signOutWithGoogle() => _googleSignIn.signOut();
