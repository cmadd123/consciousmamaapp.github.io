import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBucTVaWpYhDYScTpQ4JH9XdJgCBFmbHWk",
            authDomain: "parenting-plus-7szrif.firebaseapp.com",
            projectId: "parenting-plus-7szrif",
            storageBucket: "parenting-plus-7szrif.appspot.com",
            messagingSenderId: "67449654316",
            appId: "1:67449654316:web:88be5e06e598d56dd55589"));
  } else {
    await Firebase.initializeApp();
  }
}
