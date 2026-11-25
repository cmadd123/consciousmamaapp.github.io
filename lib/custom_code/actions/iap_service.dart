// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

/// Store In-App Purchase service for MomRise — Apple StoreKit on iOS,
/// Google Play Billing on Android (both via the in_app_purchase plugin).
///
/// Minimum-viable integration for App Store Guideline 3.1.1 and Google
/// Play's payments policy (digital subscriptions must use Play Billing):
///   - Two subscription products with the SAME product IDs in App Store
///     Connect and Play Console: `momrise_month` ($6.99/mo) and
///     `momrise_year` ($69.99/yr). Both auto-renewable, both with a
///     7-day free-trial offer for new subscribers.
///   - On purchase success the app sends the store's verification data to
///     the `verifyStorePurchase` Cloud Function, which verifies it with
///     Apple / Google and then writes subscription_status etc. on the
///     user's doc (functions/entitlements.js). The app can NOT write those
///     fields itself — firestore.rules makes them server-write-only — so
///     existing entitlement checks (hasActiveSubscription) keep working
///     off server-verified data.

const String kMonthlyProductId = 'momrise_month';
const String kAnnualProductId = 'momrise_year';

bool get _isMobileStore => Platform.isIOS || Platform.isAndroid;

/// Initialize the IAP listener once at app startup.
/// Streams purchase events for the lifetime of the app.
Future<void> initializeIap() async {
  if (!_isMobileStore) return;

  final available = await InAppPurchase.instance.isAvailable();
  if (!available) {
    debugPrint('[IAP] store not available on this device');
    return;
  }

  // Listen for purchase updates — fires for new purchases, restores, and
  // any pending state changes. Each PurchaseDetails has a status flag.
  InAppPurchase.instance.purchaseStream.listen(
    _handlePurchaseUpdates,
    onDone: () => debugPrint('[IAP] purchase stream closed'),
    onError: (e) => debugPrint('[IAP] purchase stream error: $e'),
  );
}

/// Trigger a purchase flow for the monthly subscription.
Future<String> buyMonthlySubscription() async {
  return _buyByProductId(kMonthlyProductId);
}

/// Trigger a purchase flow for the annual subscription.
Future<String> buyAnnualSubscription() async {
  return _buyByProductId(kAnnualProductId);
}

/// Shared purchase flow. Looks up the product in App Store Connect, kicks
/// off the buyNonConsumable flow, and surfaces a status string the caller
/// can render. The actual entitlement update happens asynchronously in
/// the purchase stream listener — callers should treat the return value
/// as "kicked off" not "completed."
///
/// Returns 'success' / 'pending' / 'cancelled' / 'error: <msg>'.
Future<String> _buyByProductId(String productId) async {
  if (!_isMobileStore) return 'error: mobile stores only';

  final available = await InAppPurchase.instance.isAvailable();
  if (!available) return 'error: store not available';

  // Look up the product. If not found in the store, this returns an
  // empty list — usually means the product isn't approved/active yet,
  // or the app's application ID doesn't match the store record.
  final response = await InAppPurchase.instance
      .queryProductDetails({productId}.toSet());
  if (response.notFoundIDs.isNotEmpty) {
    return 'error: product ${response.notFoundIDs.first} not found in the store';
  }
  if (response.productDetails.isEmpty) {
    return 'error: no product details returned';
  }

  // Resolve the appAccountToken — a UUID that travels with the
  // transaction. On iOS it surfaces in App Store Server Notifications
  // as `appAccountToken`; on Android the plugin passes it as Google's
  // obfuscatedAccountId. Either way it lets server-side webhooks map a
  // store transaction back to a Firebase user (and from there, to the
  // user's active_creator_code for revenue-share crediting).
  //
  // Stored once per user in users/{uid}.apple_app_account_token so
  // re-subs and renewals reuse the same token (field name is historic;
  // the same token is reused for Google on purpose).
  final appAccountToken = await _ensureAppAccountToken();

  final product = response.productDetails.first;
  final purchaseParam = PurchaseParam(
    productDetails: product,
    applicationUserName: appAccountToken,
  );

  try {
    final ok = await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
    return ok ? 'pending' : 'cancelled';
  } catch (e) {
    return 'error: ${e.toString()}';
  }
}

/// Resolve the user's appAccountToken UUID. Creates one if missing.
/// Apple requires this to be a valid UUID string; non-UUID values are
/// silently stripped from receipts, breaking server-side attribution.
Future<String?> _ensureAppAccountToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await docRef.get();
  final existing = snap.data()?['apple_app_account_token'] as String?;
  if (existing != null && existing.isNotEmpty) return existing;

  final token = const Uuid().v4();
  await docRef.set(
    {'apple_app_account_token': token},
    SetOptions(merge: true),
  );
  return token;
}

/// Restore previously-purchased subscriptions. Surfaces results via the
/// purchase stream — the listener marks Firestore subscribed if a valid
/// store receipt is found. (Name is historic — works on both stores;
/// kept because FlutterFlow action bindings reference it.)
Future<void> restoreApplePurchases() async {
  if (!_isMobileStore) return;
  await InAppPurchase.instance.restorePurchases();
}

/// Handle purchase events streamed from the store.
Future<void> _handlePurchaseUpdates(
  List<PurchaseDetails> purchases,
) async {
  for (final p in purchases) {
    debugPrint(
      '[IAP] event: status=${p.status} product=${p.productID} '
      'pendingComplete=${p.pendingCompletePurchase}',
    );

    if (p.status == PurchaseStatus.purchased ||
        p.status == PurchaseStatus.restored) {
      await _markSubscribed(p);
    } else if (p.status == PurchaseStatus.error) {
      debugPrint('[IAP] error: ${p.error?.message ?? "unknown"}');
    }

    // Always finalize so StoreKit doesn't keep redelivering the event.
    if (p.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(p);
    }
  }
}

/// Ask the server to verify a store purchase and grant the entitlement.
/// The `verifyStorePurchase` Cloud Function checks the purchase with
/// Apple (signed StoreKit 2 transaction, or the app receipt on StoreKit 1)
/// or Google Play (Android Publisher API) and only then writes
/// subscription_status / plan / store ids on users/{uid}.
///
/// Errors are logged, not thrown: the caller still completes the purchase
/// with the store (Google refunds unacknowledged purchases after 3 days),
/// and the user can retry via Restore Purchases, which replays the
/// purchase through this same path.
Future<void> _markSubscribed(PurchaseDetails p) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('[IAP] purchase received but no signed-in user — cannot verify');
    return;
  }

  final verificationData = p.verificationData.serverVerificationData;
  if (verificationData.isEmpty) {
    debugPrint('[IAP] purchase has no serverVerificationData — cannot verify');
    return;
  }

  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable(
          'verifyStorePurchase',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
        )
        .call(<String, dynamic>{
      'platform': Platform.isIOS ? 'ios' : 'android',
      'productId': p.productID,
      'purchaseId': p.purchaseID ?? '',
      'verificationData': verificationData,
    });
    final data = result.data is Map
        ? Map<String, dynamic>.from(result.data as Map)
        : <String, dynamic>{};
    debugPrint(
      '[IAP] server verification for ${user.uid}: '
      'active=${data['active']} plan=${data['plan']}',
    );
  } on FirebaseFunctionsException catch (e) {
    debugPrint('[IAP] server verification failed: ${e.code} ${e.message}');
  } catch (e) {
    debugPrint('[IAP] server verification error: $e');
  }
}
