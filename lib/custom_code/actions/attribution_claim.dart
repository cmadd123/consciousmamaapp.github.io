import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Try to claim a pending creator-code attribution from the server.
///
/// Called from main.dart's user-stream listener after sign-in. Server-
/// side IP-matches the device against pending_attributions rows seeded
/// from web visits to momrise.app/c/{code} within the last 24h.
///
/// Guards:
///   - Only fires when user has no active_creator_code (server enforces
///     this too — never overwrites an existing attribution).
///   - Marked attempted on the user doc (attribution_claim_attempted) so
///     we don't hit the callable on every cold-start.
///   - Fire-and-forget — never blocks the UI thread.
Future<void> tryClaimDeferredAttribution() async {
  if (!Platform.isIOS) return; // Android claim path will land with the Play launch

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await docRef.get();
  final data = snap.data() ?? {};

  // Skip if user already has an attribution (entered manually via
  // welcome sheet, Settings, or paywall).
  if ((data['active_creator_code'] as String?)?.isNotEmpty ?? false) return;

  // Skip if we've already tried — repeat misses just burn cloud-function
  // invocations. The server-side guard handles the race anyway.
  if (data['attribution_claim_attempted'] == true) return;

  await docRef.set(
    {'attribution_claim_attempted': true},
    SetOptions(merge: true),
  );

  try {
    final dpr = PlatformDispatcher.instance.implicitView?.devicePixelRatio ??
        WidgetsBinding
                .instance.platformDispatcher.views.first.devicePixelRatio ??
        1.0;
    final size = PlatformDispatcher.instance.implicitView?.physicalSize ??
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    final w = size != null ? (size.width / dpr).round() : 0;
    final h = size != null ? (size.height / dpr).round() : 0;
    final screen = w > 0 && h > 0 ? '${w}x$h' : '';

    final callable =
        FirebaseFunctions.instance.httpsCallable('claimAttribution');
    final response = await callable.call({
      'user_agent': 'MomRise iOS',
      'screen': screen,
      'language':
          PlatformDispatcher.instance.locale.toLanguageTag(),
      'timezone_offset_minutes':
          -DateTime.now().timeZoneOffset.inMinutes,
    });
    final result = Map<String, dynamic>.from(response.data as Map);
    debugPrint('[attribution] claim result: $result');
  } catch (e) {
    debugPrint('[attribution] claim error: $e');
    // Silently swallow — manual entry paths still work.
  }
}
