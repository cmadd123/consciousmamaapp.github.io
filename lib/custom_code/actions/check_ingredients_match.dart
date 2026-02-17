// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/app_state.dart';

/// Use AI to check if two ingredient names refer to the same ingredient
/// Returns true if they match, false otherwise
Future<bool> checkIngredientsMatch(
  String ingredient1,
  String ingredient2,
) async {
  // If they're already identical, no need for AI
  if (ingredient1.toLowerCase().trim() == ingredient2.toLowerCase().trim()) {
    return true;
  }

  // Get OpenAI key from app state
  final openAiKey = FFAppState().openAiKey.trim();
  if (openAiKey.isEmpty) {
    print('⚠️ OpenAI key not available for ingredient matching');
    return false; // Fail safe - don't match if no key
  }

  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are a grocery assistant. Determine if two ingredient names refer to the same ingredient, ignoring quantity, preparation, or descriptive differences. Answer ONLY 'yes' or 'no'."
          },
          {
            "role": "user",
            "content": "Are these the same ingredient?\n1. $ingredient1\n2. $ingredient2\n\nAnswer only 'yes' or 'no':"
          }
        ],
        "max_tokens": 10,
        "temperature": 0.1
      }),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print('⏱️ Ingredient match API timeout');
        return http.Response('{"choices": [{"message": {"content": "no"}}]}', 408);
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final answer = data['choices'][0]['message']['content'].toLowerCase().trim();

      print('🤖 AI ingredient match: "$ingredient1" vs "$ingredient2" → $answer');

      return answer.contains('yes');
    } else {
      debugPrint('OpenAI API error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Error checking ingredient match: $e');
    return false;
  }
}
