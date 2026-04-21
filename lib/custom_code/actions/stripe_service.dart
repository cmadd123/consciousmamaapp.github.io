// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Stripe Service for MomRise Subscription Management
///
/// Handles:
/// - Initialize Stripe with publishable key
/// - Create subscription (card-required 7-day free trial)
/// - Present payment sheet
/// - Check subscription status
/// - Cancel subscription
/// - Update payment method
///
/// Pricing: $6.99/month OR $69.99/year (17% savings)
/// Trial: 7 days free, card required upfront
///
/// API Flow:
/// 1. Flutter calls Cloud Function to create PaymentIntent + Subscription
/// 2. Cloud Function returns client_secret + ephemeralKey
/// 3. Flutter presents Stripe PaymentSheet
/// 4. User enters card info
/// 5. Stripe charges card after 7 days (or immediately for yearly)
/// 6. Webhook updates Firestore subscription_status
///
/// Firestore Fields (users collection):
/// - stripe_customer_id: Stripe customer ID
/// - subscription_id: Stripe subscription ID
/// - subscription_status: 'trialing' | 'active' | 'past_due' | 'canceled' | 'incomplete'
/// - subscription_plan: 'monthly' | 'yearly'
/// - trial_end: Timestamp when trial ends
/// - current_period_end: Timestamp when current billing period ends

/// Initialize Stripe with publishable key from Firebase Remote Config
Future<void> initializeStripe() async {
  try {
    final publishableKey = FFAppState().stripePublishableKey;

    if (publishableKey.isEmpty) {
      debugPrint('Stripe: No publishable key configured in Firebase Remote Config');
      return;
    }

    Stripe.publishableKey = publishableKey;
    debugPrint('Stripe: Initialized with publishable key');
  } catch (e) {
    debugPrint('Stripe: Error initializing: $e');
  }
}

/// Create subscription and present payment sheet
///
/// Flow:
/// 1. Call Cloud Function to create subscription
/// 2. Present Stripe payment sheet
/// 3. User enters card info
/// 4. Return success/failure message
Future<String> createSubscription({
  required String planType, // 'monthly' or 'yearly'
}) async {
  try {
    debugPrint('Stripe: Creating $planType subscription');

    // Step 1: Call Cloud Function to create subscription
    final functions = FirebaseFunctions.instance;
    final createSubscription = functions.httpsCallable('createSubscription');

    final result = await createSubscription.call({
      'planType': planType,
    });

    final data = result.data as Map<String, dynamic>;

    if (!data.containsKey('clientSecret') || !data.containsKey('ephemeralKey')) {
      debugPrint('Stripe: Invalid response from Cloud Function: $data');
      return 'Error: Could not create subscription. Please try again.';
    }

    final clientSecret = data['clientSecret'] as String;
    final ephemeralKey = data['ephemeralKey'] as String;
    final customerId = data['customerId'] as String;

    debugPrint('Stripe: Got client secret, presenting payment sheet');

    // Step 2: Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        customerEphemeralKeySecret: ephemeralKey,
        customerId: customerId,
        merchantDisplayName: 'MomRise',
        style: ThemeMode.system,
        appearance: const PaymentSheetAppearance(
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: Color(0xFF2DD4BF), // MomRise primary color
                text: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    // Step 3: Present payment sheet
    debugPrint('Stripe: About to present payment sheet');
    await Stripe.instance.presentPaymentSheet();

    debugPrint('Stripe: Payment sheet completed successfully');
    debugPrint('Stripe: Returning success');
    return 'success';

  } on StripeException catch (e) {
    debugPrint('Stripe: StripeException: ${e.error.localizedMessage}');

    if (e.error.code == FailureCode.Canceled) {
      return 'Payment canceled';
    }

    return 'Error: ${e.error.localizedMessage ?? 'Unknown error'}';
  } catch (e) {
    debugPrint('Stripe: Error creating subscription: $e');
    // Return detailed error for debugging
    return 'Error: $e';
  }
}

/// Check if user has active subscription
///
/// Returns true if user has 'trialing' or 'active' subscription
Future<bool> hasActiveSubscription() async {
  try {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (!userSnapshot.exists) return false;

    final userData = userSnapshot.data();
    if (userData == null) return false;

    final subscriptionStatus = userData['subscription_status'] as String?;

    return subscriptionStatus == 'trialing' || subscriptionStatus == 'active';
  } catch (e) {
    debugPrint('Stripe: Error checking subscription: $e');
    return false;
  }
}

/// Cancel subscription
///
/// Cancels at end of current billing period (doesn't charge for next month)
Future<String> cancelSubscription() async {
  try {
    final functions = FirebaseFunctions.instance;
    final cancel = functions.httpsCallable('cancelSubscription');

    final result = await cancel.call();
    final success = result.data['success'] as bool;

    if (success) {
      debugPrint('Stripe: Subscription canceled successfully');
      return 'Subscription canceled. You can continue using MomRise until the end of your billing period.';
    } else {
      return 'Error: Could not cancel subscription. Please try again.';
    }
  } catch (e) {
    debugPrint('Stripe: Error canceling subscription: $e');
    return 'Error: Could not cancel subscription. Please try again.';
  }
}

/// Restore purchases (for users who reinstall app or switch devices)
///
/// Fetches subscription status from Stripe and updates Firestore
Future<String> restorePurchases() async {
  try {
    final functions = FirebaseFunctions.instance;
    final restore = functions.httpsCallable('restorePurchases');

    final result = await restore.call();
    final data = result.data as Map<String, dynamic>;

    final hasSubscription = data['hasSubscription'] as bool;

    if (hasSubscription) {
      debugPrint('Stripe: Restored active subscription');
      return 'Subscription restored!';
    } else {
      debugPrint('Stripe: No active subscription found');
      return 'No active subscription found.';
    }
  } catch (e) {
    debugPrint('Stripe: Error restoring purchases: $e');
    return 'Error: Could not restore purchases. Please try again.';
  }
}
