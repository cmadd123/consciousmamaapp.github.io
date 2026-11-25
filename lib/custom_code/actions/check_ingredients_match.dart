// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/backend/cloud_functions/ai_proxy.dart';

/// Use AI to check if two ingredient names refer to the same ingredient
/// Returns true if they match, false otherwise
///
/// Runs server-side via the `aiGenerate` Cloud Function (task
/// appIngredientMatch). The server holds the prompt, the model settings
/// (gpt-4o-mini, max_tokens 10, temperature 0.1) and caches answers.
Future<bool> checkIngredientsMatch(
  String ingredient1,
  String ingredient2,
) async {
  // If they're already identical, no need for AI
  if (ingredient1.toLowerCase().trim() == ingredient2.toLowerCase().trim()) {
    return true;
  }

  try {
    final answer = (await callAiProxy(
      'appIngredientMatch',
      extra: {
        'ingredient1': ingredient1,
        'ingredient2': ingredient2,
      },
      timeout: const Duration(seconds: 30),
    ))
        .toLowerCase()
        .trim();

    print('🤖 AI ingredient match: "$ingredient1" vs "$ingredient2" → $answer');

    return answer.contains('yes');
  } catch (e) {
    // Fail safe - don't match if the AI call fails
    debugPrint('❌ Error checking ingredient match: $e');
    return false;
  }
}
