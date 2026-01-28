# Firebase App Check Setup for MomRise

## Why App Check?
Protects your backend services (OpenAI API, Firestore) from abuse by ensuring requests come from your legitimate app, not bots or unauthorized clients.

## Setup Steps

### 1. Enable App Check in Firebase Console

1. Go to https://console.firebase.google.com/project/parenting-plus-7szrif
2. Click **"App Check"** in the left sidebar
3. Click **"Get Started"**

### 2. Register iOS App

1. Click your iOS app (com.momrise.app)
2. Choose **"App Attest"** provider (recommended for production)
3. Click **"Save"**

### 3. Register Android App (if needed)

1. Click your Android app (com.momrise.app)
2. Choose **"Play Integrity"** provider
3. Click **"Save"**

### 4. Enforce for Services

**Important: Start with "Unenforced" mode for testing!**

1. Go to **"APIs"** tab in App Check
2. For each service, click the 3-dot menu:
   - **Cloud Firestore** → Set to "Unenforced" (logs violations, doesn't block)
   - **Cloud Functions** → Set to "Unenforced"
   - **Cloud Storage** → Set to "Unenforced"

3. **After testing with real users**, switch to "Enforced" mode

### 5. Add App Check to Flutter Code

**You've likely already done this if FlutterFlow has App Check enabled.**

Check `lib/main.dart` for:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.appAttest,
);
```

### 6. Testing

1. Deploy your TestFlight build
2. Check Firebase Console → App Check → Metrics
3. Verify requests are passing App Check
4. After confirming it works, switch to "Enforced" mode

## Notes

- **Unenforced mode** = logs violations but allows all requests (good for testing)
- **Enforced mode** = blocks requests without valid App Check token (production)
- App Attest is iOS 14+ only (older devices will fail if enforced)
- Play Integrity requires Google Play Services on Android

## When to Enforce

Wait until:
- ✅ TestFlight build deployed
- ✅ Testers confirm app works
- ✅ No App Check errors in Firebase logs
- ✅ Ready for production

Then switch from "Unenforced" to "Enforced" for each service.
