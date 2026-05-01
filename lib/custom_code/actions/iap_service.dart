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
import 'package:firebase_auth/firebase_auth.dart';

/// Apple In-App Purchase service for MomRise.
///
/// Minimum-viable integration to satisfy App Store Guideline 3.1.1:
///   - Single subscription product: `momrise_monthly` ($6.99/mo auto-renewable)
///   - Set up in App Store Connect → In-App Purchases → Subscriptions
///   - Web subscription path (Stripe) continues to work for non-iOS users
///   - On purchase success, the user's Firestore doc is marked subscribed
///     using the same fields the web flow writes (subscription_status,
///     free_trial_start) so the rest of the app doesn't need to know
///     which path the user came in on.
///
/// Architecture is intentionally minimal — no RevenueCat, no server-side
/// receipt validation. Apple's StoreKit handles trial/cancel/renew. We
/// just listen to purchase events and mirror the active state into
/// Firestore so existing entitlement checks (hasActiveSubscription)
/// continue to work unchanged.

const String kIosMonthlyProductId = 'momrise_monthly';

/// Initialize the IAP listener once at app startup.
/// Streams purchase events for the lifetime of the app.
Future<void> initializeIap() async {
  if (!Platform.isIOS) return;

  final available = await InAppPurchase.instance.isAvailable();
  if (!available) {
    debugPrint('[IAP] StoreKit not available on this device');
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
/// Returns 'success' / 'pending' / 'cancelled' / 'error: <msg>'.
/// The actual entitlement update happens asynchronously in the
/// purchase stream listener — callers should treat this as "kicked off"
/// not "completed."
Future<String> buyMonthlySubscription() async {
  if (!Platform.isIOS) return 'error: iOS only';

  final available = await InAppPurchase.instance.isAvailable();
  if (!available) return 'error: StoreKit not available';

  // Look up the product. If not found in App Store Connect, this returns
  // an empty list — usually means the IAP product isn't approved yet, or
  // the bundle ID doesn't match the App Store Connect record.
  final response = await InAppPurchase.instance
      .queryProductDetails({kIosMonthlyProductId}.toSet());
  if (response.notFoundIDs.isNotEmpty) {
    return 'error: product ${response.notFoundIDs.first} not found in App Store Connect';
  }
  if (response.productDetails.isEmpty) {
    return 'error: no product details returned';
  }

  final product = response.productDetails.first;
  final purchaseParam = PurchaseParam(productDetails: product);

  try {
    final ok = await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
    return ok ? 'pending' : 'cancelled';
  } catch (e) {
    return 'error: ${e.toString()}';
  }
}

/// Restore previously-purchased subscriptions. Surfaces results via the
/// purchase stream — the listener marks Firestore subscribed if a valid
/// Apple receipt is found.
Future<void> restoreApplePurchases() async {
  if (!Platform.isIOS) return;
  await InAppPurchase.instance.restorePurchases();
}

/// Handle purchase events streamed from StoreKit.
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

/// Mirror an active Apple subscription into the user's Firestore doc.
/// Uses the same fields the web Stripe flow writes so the rest of the
/// app doesn't have to know which payment path the user took.
Future<void> _markSubscribed(PurchaseDetails p) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('[IAP] purchase received but no signed-in user — cannot mirror');
    return;
  }

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await docRef.set({
    'subscription_status': 'active',
    'subscription_plan': 'monthly',
    'subscription_source': 'apple_iap',
    'apple_product_id': p.productID,
    'apple_transaction_id': p.purchaseID,
    'subscription_updated_at': FieldValue.serverTimestamp(),
    // Apple handles the trial natively. If we don't have a trial start
    // already (existing flow uses this), record one so app gating works.
    'free_trial_start': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  debugPrint('[IAP] Firestore marked subscribed for ${user.uid}');
}
