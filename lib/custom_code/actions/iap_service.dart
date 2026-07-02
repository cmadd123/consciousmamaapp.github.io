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
///   - On purchase success, the user's Firestore doc is marked subscribed
///     using the same fields the web flow writes (subscription_status,
///     free_trial_start) so the rest of the app doesn't need to know
///     which path the user came in on. The plan ('monthly' / 'annual')
///     is recorded too in case future logic needs to differentiate.
///
/// Architecture is intentionally minimal — no RevenueCat, no server-side
/// receipt validation. The stores handle trial/cancel/renew. We just
/// listen to purchase events and mirror the active state into Firestore
/// so existing entitlement checks (hasActiveSubscription) keep working.
/// The Google purchase token is persisted so server-side verification /
/// RTDN can be added later without asking users to re-buy.

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

/// Mirror an active store subscription into the user's Firestore doc.
/// Uses the same fields the web Stripe flow writes so the rest of the
/// app doesn't have to know which payment path the user took. Records
/// 'monthly' or 'annual' based on which product the user bought.
Future<void> _markSubscribed(PurchaseDetails p) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('[IAP] purchase received but no signed-in user — cannot mirror');
    return;
  }

  final plan = p.productID == kAnnualProductId ? 'annual' : 'monthly';

  final storeFields = Platform.isIOS
      ? {
          'subscription_source': 'apple_iap',
          'apple_product_id': p.productID,
          'apple_transaction_id': p.purchaseID,
        }
      : {
          'subscription_source': 'google_play',
          'google_product_id': p.productID,
          'google_order_id': p.purchaseID,
          // The purchase token is Google's durable handle on this
          // subscription — persist it so server-side verification and
          // Real-Time Developer Notifications can be added later.
          'google_purchase_token': p.verificationData.serverVerificationData,
        };

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await docRef.set({
    'subscription_status': 'active',
    'subscription_plan': plan,
    'subscription_updated_at': FieldValue.serverTimestamp(),
    // The store handles the trial natively. If we don't have a trial
    // start already (existing flow uses this), record one so gating works.
    'free_trial_start': FieldValue.serverTimestamp(),
    ...storeFields,
  }, SetOptions(merge: true));

  debugPrint('[IAP] Firestore marked subscribed ($plan) for ${user.uid}');
}
