// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/backend/cloud_functions/cloud_functions.dart';

/// Server-side dedup pass for a grocery list.
///
/// Calls the `dedupGroceryList` cloud function, which uses an LLM to:
///   - collapse synonyms (flour + all-purpose flour -> one row)
///   - convert compatible units and sum quantities
///   - pick the most shopper-specific canonical name
///   - flag items needing human review (needs_review + review_reason)
///
/// Fail-open: if the call errors or returns nothing, the original list is
/// returned unchanged. Never blocks the user from continuing to checkout.
///
/// Preserves checked state and originalText from the input items by matching
/// the LLM's merged_from indices back to the originals. Items the LLM
/// produced get isChecked=false (since the merge changed them) unless EVERY
/// merged-from row was checked.
Future<List<GroceryItemStruct>> dedupGroceryList(
  List<GroceryItemStruct> items,
) async {
  if (items.isEmpty) return items;

  try {
    final payload = items
        .map((it) => {
              'name': it.name,
              'quantity': it.quantity,
              'unit': it.unit,
            })
        .toList();

    final result =
        await makeCloudCall('dedupGroceryList', {'items': payload});

    final raw = result['items'];
    if (raw is! List || raw.isEmpty) {
      return items;
    }

    final cleaned = <GroceryItemStruct>[];
    for (final row in raw) {
      if (row is! Map) continue;
      final mergedFrom = (row['merged_from'] as List?)?.cast<dynamic>() ?? [];

      // Preserve "checked" only when every source row was checked. A merge
      // of a checked + unchecked item produces an unchecked row so the
      // user can re-check it intentionally.
      bool inheritedChecked = mergedFrom.isNotEmpty;
      String? inheritedOriginal;
      for (final idxRaw in mergedFrom) {
        final idx = idxRaw is int ? idxRaw : int.tryParse('$idxRaw');
        if (idx == null || idx < 0 || idx >= items.length) {
          inheritedChecked = false;
          continue;
        }
        final src = items[idx];
        if (!src.isChecked) inheritedChecked = false;
        // Use the first source row's originalText as a hint; later we may
        // want to concatenate, but for now one is enough for the diff UX.
        inheritedOriginal ??= src.originalText;
      }

      final newItem = GroceryItemStruct(
        name: (row['name'] as String?)?.trim() ?? '',
        quantity: (row['quantity'] is num)
            ? (row['quantity'] as num).toDouble()
            : 0.0,
        unit: (row['unit'] as String?)?.trim() ?? '',
        originalText: inheritedOriginal,
        isChecked: inheritedChecked,
      );

      // Mirror the review flags onto the struct via the dynamic-but-typed
      // setter helpers added to GroceryItemStruct.
      if (row['needs_review'] == true) {
        newItem.needsReview = true;
        newItem.reviewReason =
            (row['review_reason'] as String?)?.trim() ?? '';
      }

      if (newItem.name.isEmpty) continue;
      cleaned.add(newItem);
    }

    if (cleaned.isEmpty) return items;
    debugPrint('🧹 dedupGroceryList: ${items.length} -> ${cleaned.length} rows '
        '(${cleaned.where((c) => c.needsReview).length} flagged for review)');
    return cleaned;
  } catch (e, st) {
    debugPrint('dedupGroceryList failed (fail-open): $e\n$st');
    return items;
  }
}
