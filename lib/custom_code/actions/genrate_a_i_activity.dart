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

Future<List<ActivityModelStruct>> genrateAIActivity(
  DocumentReference? selectedChild,
  String? activityLocation, // Indoor / Outdoor
  String? noiseLevel, // Quiet / Not Quiet
) async {
  if (selectedChild == null || activityLocation == null || noiseLevel == null) {
    throw Exception("Missing required parameters");
  }

  // Get OpenAI key from Firebase Remote Config (secure)
  final openAiKey = FFAppState().openAiKey;

  final prompt = """
You are an expert in child development and creative learning.
Generate 4 **practical, age-appropriate, and useful activities** for a child.

Each activity must help the child develop **real-life skills** such as:
- fine motor skills (cutting, drawing, building, sorting)
- creativity and problem-solving
- communication and social interaction
- emotional awareness and self-regulation
- curiosity and learning through play

Constraints:
- Location: $activityLocation (e.g., Indoor at home or Outdoor outside)
- Noise Level: $noiseLevel (e.g., Quiet or Not Quiet)
- Ensure the activity fits the environment naturally (e.g., no noisy games indoors).

Each activity must include:
1. "title" — short, clear name for the activity.
2. "description" — clear, step-by-step guide for what the child will do.
3. "activityNeeds" — list of simple items required (only things typically found at home or outdoors).
4. "activitySafetyConcerns" — one short sentence with real safety advice.
5. "activity_time" — valid ISO 8601 DateTime string in UTC+3 timezone, 
   e.g. "2025-09-19T09:30:00+03:00". 
   Use realistic times: Morning (08:00–11:00), Lunch (12:00–14:00), Evening (17:00–20:00).

Rules:
- All activities must have a **clear educational or developmental benefit**.
- Avoid digital screens or apps.
- Make them doable with minimal preparation.
- Avoid repetitive or boring activities.
- Return **ONLY a pure JSON array** with 4 objects, no extra text or markdown.
Example format:
[
  {
    "title": "Counting Fun",
    "description": "Use 10 toys to practice counting. Count each toy one by one, then group them.",
    "activityNeeds": ["10 small toys", "a flat surface"],
    "activitySafetyConcerns": "Ensure toys are not small enough to be swallowed.",
    "activity_time": "2025-09-19T09:30:00+03:00"
  }
]
""";

  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $openAiKey",
    },
    body: jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 700,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("OpenAI API error: ${response.body}");
  }

  final data = jsonDecode(response.body);
  String content = data['choices'][0]['message']['content'];

  // ✅ Clean JSON (strip markdown if needed)
  content = content.trim();
  if (content.startsWith("```")) {
    final regex = RegExp(r"```(?:json)?([\s\S]*?)```");
    final match = regex.firstMatch(content);
    if (match != null) {
      content = match.group(1)!.trim();
    }
  }
  if (!content.startsWith("[")) {
    final start = content.indexOf("[");
    final end = content.lastIndexOf("]");
    if (start != -1 && end != -1) {
      content = content.substring(start, end + 1);
    }
  }

  late List<dynamic> activitiesJson;
  try {
    activitiesJson = jsonDecode(content);
  } catch (e) {
    throw Exception("Failed to parse AI response: $content");
  }

  // ✅ Convert to ActivityModelStruct list
  final activities = activitiesJson.map((a) {
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(a["activity_time"]);
    } catch (_) {
      // fallback → now in UTC+3
      parsedTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    }

    return ActivityModelStruct(
      title: a["title"] ?? "",
      locationTyp: activityLocation,
      activityTyp: noiseLevel, // 🔄 used as noiseLevel
      description: a["description"] ?? "",
      activityNeeds: List<String>.from(a["activityNeeds"] ?? []),
      activitySafetyConcerns: a["activitySafetyConcerns"] ?? "",
      activityTime: parsedTime, // ✅ real DateTime
      childFireBaseRef: selectedChild,
    );
  }).toList();

  return activities;
}
