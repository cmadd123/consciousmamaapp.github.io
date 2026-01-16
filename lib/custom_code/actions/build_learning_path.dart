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
import 'package:cloud_firestore/cloud_firestore.dart';
import '/app_state.dart';

Future buildLearningPath(
  String? challengeDescription,
  DateTime? childBirthDate,
  String? currentDate,
  DocumentReference? userRef,
  DocumentReference? childId,
  String? frequency,
  String? preferredTime,
  [String? puzzleTheme]
) async {
  if (challengeDescription == null ||
      childBirthDate == null ||
      currentDate == null ||
      userRef == null ||
      childId == null ||
      frequency == null ||
      preferredTime == null) {
    throw Exception("Missing required parameters");
  }

  // Default puzzle theme if not provided
  final selectedPuzzleTheme = puzzleTheme ?? 'dinosaurs';

  final db = FirebaseFirestore.instance;

  // Calculate child's age for age-appropriate content
  final now = DateTime.now();
  final ageInMonths = (now.year - childBirthDate.year) * 12 +
                      (now.month - childBirthDate.month);
  final ageYears = ageInMonths ~/ 12;
  final ageMonthsRemainder = ageInMonths % 12;
  // For display: "4 years and 2 months"
  final ageStringDisplay = ageYears > 0
      ? "$ageYears year${ageYears > 1 ? 's' : ''}${ageMonthsRemainder > 0 ? ' and $ageMonthsRemainder month${ageMonthsRemainder > 1 ? 's' : ''}' : ''}"
      : "$ageMonthsRemainder month${ageMonthsRemainder > 1 ? 's' : ''}";
  // For grammar in sentences: "4-year-old" (hyphenated adjective form)
  final ageString = ageYears > 0
      ? "$ageYears-year-old"
      : "$ageMonthsRemainder-month-old";

  // 🧠 Step 1 — AI Prompt (Enhanced with examples)
  final prompt = """
You are an expert in early childhood development and parenting. You help parents teach their children important life skills through structured, repetitive practice.

CHILD INFORMATION:
- Age: $ageStringDisplay old
- Challenge/Goal: $challengeDescription

PROGRAM SETTINGS:
- Frequency: $frequency
- Preferred time: $preferredTime

YOUR TASK:
Create a realistic learning program. Consider:
1. The child's developmental stage based on their age
2. Start simple and gradually increase difficulty
3. Include variety to keep the child engaged
4. Be specific enough that a tired parent can follow the instructions

For each task, provide ALL of these fields:
- "title": Short, friendly name (e.g., "Potty Time Practice" not "Task 1")
- "description": Clear instructions for the PARENT including:
  * What to do step by step
  * What to say to the child (use quotes for exact phrases)
  * How to make it fun/engaging
- "duration": Realistic time in minutes (usually 5-20 min for young children)
- "parent_tip": A helpful, encouraging tip for this specific task (see examples below)
- "success_signs": What progress looks like (so parent knows it's working)
- "if_resistant": Specific strategies if the child refuses or struggles (see examples below)

GUIDELINES:
- For a $ageString old, tasks should be age-appropriate
- Younger children (under 2): Very short, sensory, repetition-focused
- Toddlers (2-3): Simple steps, lots of praise, make it a game
- Preschool (3-5): Can follow 2-3 step instructions, likes to help
- School age (5+): Can understand explanations, likes earning rewards

Create 5-14 tasks depending on the complexity of the skill. Potty training might need 10-14 days, learning colors might need 5-7.

EXAMPLES OF GOOD parent_tip VALUES:
- "Your calm energy matters more than perfection. Children pick up on stress, so take a deep breath before starting."
- "Celebrate small wins! A high-five or happy dance reinforces good behavior better than treats."
- "Consistency is key - try to do this at the same time each day so it becomes routine."
- "Don't compare to other children. Every child develops at their own pace."
- "If you're feeling frustrated, it's okay to pause and try again later."
- "Take a photo or video to track progress - it helps you see how far you've come!"

EXAMPLES OF GOOD if_resistant VALUES:
- "If they say 'no', acknowledge their feelings: 'I hear you don't want to right now. That's okay.' Try again in 30 minutes with a playful approach like making a toy demonstrate first."
- "If they're scared, don't force it. Sit nearby and let them observe without pressure. Try using a favorite stuffed animal to 'go first'."
- "If they get distracted, that's normal! Gently redirect with: 'Let's finish this one thing, then we can play.' Keep sessions short."
- "If they cry or tantrum, stay calm and say: 'I understand this is hard. Let's take a break and try tomorrow.' Pushing through tears creates negative associations."
- "If they want to do it differently, let them! As long as they're engaging, flexibility helps them feel in control."
- "If they refuse to start, try changing the environment - move to a different room, go outside, or try during bath time."

Return ONLY a valid JSON array. No markdown, no explanation, just the JSON.

Example format:
[
  {
    "title": "Getting Familiar",
    "description": "Sit with your child near the potty chair. Let them touch it and explore. Say: 'This is your special potty! Big kids use the potty.' Read a potty-themed book together if you have one.",
    "duration": 10,
    "parent_tip": "Keep the tone positive and pressure-free. This is just about familiarity. Your calm energy helps them feel safe exploring something new.",
    "success_signs": "Child shows curiosity about the potty, willing to sit near it, asks questions about it",
    "if_resistant": "If they won't go near it, don't force it. Place the potty in a corner of the bathroom and let them get used to seeing it over a few days. Try reading potty books at bedtime to build interest naturally."
  },
  {
    "title": "Practice Sitting",
    "description": "After a meal or nap (times when children often need to go), invite your child to sit on the potty with clothes ON. Say: 'Want to try sitting on your potty like a big kid?' Let them sit for just 1-2 minutes. Sing a short song together.",
    "duration": 5,
    "parent_tip": "Starting with clothes on removes pressure and fear. Make it a fun 'practice' rather than expecting results.",
    "success_signs": "Willingly sits on the potty, doesn't cry or resist, might ask to sit again",
    "if_resistant": "If they refuse to sit, try having a favorite toy 'sit' on the potty first. Say: 'Look, teddy is sitting! Do you want to try?' If still resistant, let them stand near it while you read a short book."
  }
]
""";

  // 🧠 Step 2 — OpenAI API Call
  // Use centralized API key from app state (fetched from Firebase Remote Config)
  final openAiKey = FFAppState().openAiKey.trim();
  if (openAiKey.isEmpty) {
    throw Exception("OpenAI API key not configured. Please add 'openai_api_key' to Firebase Remote Config.");
  }

  print('DEBUG: OpenAI key length: ${openAiKey.length}, starts with: ${openAiKey.substring(0, openAiKey.length > 10 ? 10 : openAiKey.length)}...');
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
          "content": "You are an expert early childhood development specialist who creates practical, parent-friendly learning programs. You understand child psychology and create tasks that are age-appropriate, engaging, and achievable. Always respond with valid JSON only."
        },
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 3000,
      "temperature": 0.7
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("OpenAI API error: ${response.body}");
  }

  final data = jsonDecode(response.body);
  String content = data['choices'][0]['message']['content'];

  // 🧩 Step 3 — Clean and Fix JSON if needed
  List<dynamic> tasks = [];
  try {
    String cleanResponse = content
        .replaceAll(RegExp(r'```json', caseSensitive: false), '')
        .replaceAll('```', '')
        .replaceAll('\n', ' ')
        .trim();

    if (!cleanResponse.trim().endsWith(']')) {
      cleanResponse = cleanResponse.trim();
      if (cleanResponse.endsWith(',')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 1);
      }
      cleanResponse = "$cleanResponse]";
    }

    cleanResponse = cleanResponse.replaceAll(RegExp(r',\s*]'), ']');
    cleanResponse = cleanResponse.replaceAll(RegExp(r',\s*}'), '}');

    final decoded = jsonDecode(cleanResponse);
    if (decoded is! List || decoded.isEmpty) {
      throw Exception("AI did not return a valid non-empty task list.");
    }
    tasks = decoded;
  } catch (e) {
    throw Exception(
        "❌ Failed to parse AI response: $e\n\nRaw content:\n$content");
  }

  // 🧮 Step 4 — Frequency spacing
  int daysStep = 1;
  switch (frequency.toLowerCase()) {
    case "every day":
      daysStep = 1;
      break;
    case "every 2 days":
      daysStep = 2;
      break;
    case "every 3 days":
      daysStep = 3;
      break;
    case "every 4 days":
      daysStep = 4;
      break;
    case "every 5 days":
      daysStep = 5;
      break;
    case "every 6 days":
      daysStep = 6;
      break;
    case "every 7 days":
      daysStep = 7;
      break;
    default:
      daysStep = 1;
  }

  // 🕓 Step 5 — Base date and time
  final startDate = DateTime.parse(currentDate);
  final timeParts = preferredTime.split(":");
  final baseHour = int.tryParse(timeParts[0]) ?? 18;
  final baseMinute = int.tryParse(timeParts[1]) ?? 0;

  final firstTaskDate = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
    baseHour,
    baseMinute,
  );

  // 🧱 Step 6 — Create learning path with better title
  // Extract a cleaner title from the challenge description
  String pathTitle = challengeDescription;
  if (pathTitle.toLowerCase().startsWith("my child needs help with ")) {
    pathTitle = pathTitle.substring(25);
  } else if (pathTitle.toLowerCase().startsWith("my child ")) {
    pathTitle = pathTitle.substring(9);
  }
  // Capitalize first letter
  pathTitle = pathTitle[0].toUpperCase() + pathTitle.substring(1);

  final programRef = await db.collection("learning_path").add({
    "title": pathTitle,
    "description": "A ${tasks.length}-day program to help your $ageString with ${pathTitle.toLowerCase()}. Practice $frequency at $preferredTime.",
    "challenge": challengeDescription,
    "child_age": ageStringDisplay,
    "created_at": Timestamp.now(),
    "user_ref": userRef,
    "child_ref": childId,
    "tasks_count": tasks.length,
    "start_date": Timestamp.fromDate(firstTaskDate),
    "end_date": Timestamp.fromDate(
      firstTaskDate.add(Duration(days: daysStep * (tasks.length - 1))),
    ),
    "is_completed": false,
    "frequency": frequency,
    "preferred_time": preferredTime,
    "puzzle_theme": selectedPuzzleTheme,
  });

  // ✅ Step 7 — Save each task (FORCE all tasks to use preferredTime)
  for (int i = 0; i < tasks.length; i++) {
    final task = tasks[i];

    final scheduledDate = DateTime(
      firstTaskDate.year,
      firstTaskDate.month,
      firstTaskDate.day + (i * daysStep),
      baseHour,
      baseMinute,
    );

    await db.collection("learning_path_tasks").add({
      "title": task["title"] ?? "Task ${i + 1}",
      "description": task["description"] ?? "",
      "duration": task["duration"] ?? 10,
      "parent_tip": task["parent_tip"] ?? "",
      "success_signs": task["success_signs"] ?? "",
      "if_resistant": task["if_resistant"] ?? "",
      "task_time": Timestamp.fromDate(scheduledDate),
      "program_ref": programRef,
      "child_ref": childId,
      "user_ref": userRef,
      "created_at": Timestamp.now(),
      "is_completed": false,
      "was_skipped": false,
      "task_order": i + 1,
    });
  }
}
