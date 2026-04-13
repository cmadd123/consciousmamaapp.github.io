import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// Service for managing creator codes and theming.
///
/// Handles:
/// - Validating and activating creator codes
/// - Loading creator theme data
/// - Managing the global/creator visual toggle
/// - Loading creator content for the active code

/// Validate a creator code and return the creator record if valid.
/// Returns null if code is invalid or inactive.
Future<CreatorsRecord?> validateCreatorCode(String code) async {
  try {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) return null;

    final results = await queryCreatorsRecordOnce(
      queryBuilder: (q) => q
          .where('code', isEqualTo: normalizedCode)
          .where('is_active', isEqualTo: true),
      singleRecord: true,
    );

    return results.isNotEmpty ? results.first : null;
  } catch (e) {
    debugPrint('Error validating creator code: $e');
    return null;
  }
}

/// Activate a creator code for the current user.
/// Stores the code and creator ref on the user document.
/// Increments the creator's follower count.
Future<bool> activateCreatorCode(CreatorsRecord creator) async {
  try {
    if (currentUserReference == null) return false;

    // Get current user's active code to check if switching
    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final previousCode = userData?['active_creator_code'] as String?;
    final previousCreatorRef = userData?['active_creator_ref'] as DocumentReference?;

    // Decrement old creator's follower count if switching
    if (previousCreatorRef != null && previousCode != creator.code) {
      await previousCreatorRef.update({
        'follower_count': FieldValue.increment(-1),
      });
    }

    // Update user document
    await currentUserReference!.update({
      'active_creator_code': creator.code,
      'active_creator_ref': creator.reference,
      'creator_code_activated_at': FieldValue.serverTimestamp(),
    });

    // Increment new creator's follower count (only if different from previous)
    if (previousCode != creator.code) {
      await creator.reference.update({
        'follower_count': FieldValue.increment(1),
      });
    }

    debugPrint('✓ Activated creator code: ${creator.code} (${creator.name})');
    return true;
  } catch (e) {
    debugPrint('Error activating creator code: $e');
    return false;
  }
}

/// Deactivate the current creator code for the user.
/// Decrements the creator's follower count.
Future<bool> deactivateCreatorCode() async {
  try {
    if (currentUserReference == null) return false;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final previousCreatorRef = userData?['active_creator_ref'] as DocumentReference?;

    // Decrement old creator's follower count
    if (previousCreatorRef != null) {
      await previousCreatorRef.update({
        'follower_count': FieldValue.increment(-1),
      });
    }

    // Clear user's active creator
    await currentUserReference!.update({
      'active_creator_code': FieldValue.delete(),
      'active_creator_ref': FieldValue.delete(),
      'creator_code_activated_at': FieldValue.delete(),
    });

    debugPrint('✓ Deactivated creator code');
    return true;
  } catch (e) {
    debugPrint('Error deactivating creator code: $e');
    return false;
  }
}

/// Get the active creator record for the current user.
/// Returns null if no creator code is active.
Future<CreatorsRecord?> getActiveCreator() async {
  try {
    if (currentUserReference == null) return null;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final creatorRef = userData?['active_creator_ref'] as DocumentReference?;

    if (creatorRef == null) return null;

    return await CreatorsRecord.getDocumentOnce(creatorRef);
  } catch (e) {
    debugPrint('Error getting active creator: $e');
    return null;
  }
}

/// Get the latest published meal plan from a creator.
Future<CreatorContentRecord?> getCreatorWeeklyMealPlan(String creatorCode) async {
  try {
    final results = await queryCreatorContentRecordOnce(
      queryBuilder: (q) => q
          .where('creator_code', isEqualTo: creatorCode)
          .where('type', isEqualTo: 'meal_plan')
          .where('is_active', isEqualTo: true)
          .orderBy('published_at', descending: true),
      singleRecord: true,
    );

    return results.isNotEmpty ? results.first : null;
  } catch (e) {
    debugPrint('Error getting creator meal plan: $e');
    return null;
  }
}

/// Get all active content from a creator.
Future<List<CreatorContentRecord>> getCreatorContent(String creatorCode) async {
  try {
    return await queryCreatorContentRecordOnce(
      queryBuilder: (q) => q
          .where('creator_code', isEqualTo: creatorCode)
          .where('is_active', isEqualTo: true)
          .orderBy('published_at', descending: true),
    );
  } catch (e) {
    debugPrint('Error getting creator content: $e');
    return [];
  }
}

/// Parse a hex color string to a Color object.
/// Returns null if invalid.
Color? parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    final cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    } else if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// Check if the current user has an active creator code.
Future<bool> hasActiveCreatorCode() async {
  try {
    if (currentUserReference == null) return false;

    final userDoc = await currentUserReference!.get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['active_creator_code'] != null;
  } catch (e) {
    return false;
  }
}
