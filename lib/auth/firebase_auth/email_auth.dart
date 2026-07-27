import 'package:firebase_auth/firebase_auth.dart';

/// Normalize an email before it reaches Firebase Auth. Firebase rejects
/// anything with stray characters as `invalid-email` ("badly formatted"),
/// which real users hit constantly via mobile autocorrect / autofill:
/// a leading/trailing space, an internal space, a smart-quote, or a
/// trailing period. We strip ALL whitespace (emails can't contain any) and
/// lowercase it (Firebase treats emails case-insensitively anyway), so a
/// slightly-mistyped address still creates the account instead of erroring.
String _sanitizeEmail(String email) =>
    email.replaceAll(RegExp(r'\s+'), '').toLowerCase();

Future<UserCredential?> emailSignInFunc(
  String email,
  String password,
) =>
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _sanitizeEmail(email),
      password: password,
    );

Future<UserCredential?> emailCreateAccountFunc(
  String email,
  String password,
) =>
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _sanitizeEmail(email),
      password: password,
    );
