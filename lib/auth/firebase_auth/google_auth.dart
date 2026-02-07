import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _googleSignIn = GoogleSignIn(
  scopes: ['profile', 'email'],
  // Web client ID from Firebase Console (required for Android)
  serverClientId: '67449654316-nj10g9vm0vsv3to58gfountgep6cool4.apps.googleusercontent.com',
);

Future<UserCredential?> googleSignInFunc() async {
  if (kIsWeb) {
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
  }

  await signOutWithGoogle().catchError((_) => null);
  final auth = await (await _googleSignIn.signIn())?.authentication;
  if (auth == null) {
    return null;
  }
  final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken, accessToken: auth.accessToken);
  return FirebaseAuth.instance.signInWithCredential(credential);
}

Future signOutWithGoogle() => _googleSignIn.signOut();
