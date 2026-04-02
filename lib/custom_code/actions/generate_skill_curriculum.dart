// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Generates a personalized skill path curriculum using OpenAI and expert RAG context
///
/// This action:
/// 1. Loads the expert template for RAG context
/// 2. Collects all user preferences from the creation flow
/// 3. Calls OpenAI API with a structured prompt
/// 4. Parses the generated curriculum JSON
/// 5. Creates a SkillPathRecord in Firestore with all milestones and sub-steps
///
/// Parameters:
/// - skillKey: The skill identifier (e.g., 'woodworking', 'cooking')
/// - userChoices: Map of user selections from the creation flow
/// - expertTemplate: The loaded expert template JSON (RAG context)
///
/// Returns: The document reference of the created skill path
Future<DocumentReference?> generateSkillCurriculum(
  String skillKey,
  Map<String, dynamic> userChoices,
  Map<String, dynamic> expertTemplate,
) async {
  try {
    // Get OpenAI API key from Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final apiKey = remoteConfig.getString('openai_api_key');

    if (apiKey.isEmpty) {
      debugPrint('❌ OpenAI API key not configured in Remote Config');
      return null;
    }

    // Build the prompt for OpenAI
    final prompt = _buildPrompt(skillKey, userChoices, expertTemplate);

    debugPrint('🔵 Generating skill curriculum for: $skillKey');
    debugPrint('🔵 User choices: ${jsonEncode(userChoices)}');

    // Call OpenAI API
    final response = await http
        .post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4-turbo-preview',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an expert curriculum designer creating personalized skill learning paths. You reference real expert methodologies and create high-quality, detailed instructional content.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 4000, // Enough for 15 milestones x 3 steps
        'response_format': {'type': 'json_object'},
      }),
    )
        .timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('OpenAI API request timed out after 60 seconds');
      },
    );

    if (response.statusCode != 200) {
      debugPrint('❌ OpenAI API error: ${response.statusCode}');
      debugPrint('❌ Response: ${response.body}');
      return null;
    }

    final responseData = jsonDecode(response.body);
    final content = responseData['choices'][0]['message']['content'] as String;
    final generatedCurriculum = jsonDecode(content) as Map<String, dynamic>;

    debugPrint('✅ Successfully generated curriculum');

    // Create the SkillPathRecord in Firestore
    final skillPathRef = await _createSkillPath(
      skillKey,
      userChoices,
      generatedCurriculum,
    );

    debugPrint('✅ Created skill path in Firestore: ${skillPathRef?.id}');
    return skillPathRef;
  } catch (e, stackTrace) {
    debugPrint('❌ Error generating skill curriculum: $e');
    debugPrint('❌ Stack trace: $stackTrace');
    return null;
  }
}

/// Builds the OpenAI prompt with RAG context and user preferences
String _buildPrompt(
  String skillKey,
  Map<String, dynamic> userChoices,
  Map<String, dynamic> expertTemplate,
) {
  // Extract user preferences
  final step1Choice = userChoices['step_1_full'] as Map<String, dynamic>?;
  final step2Choice = userChoices['step_2'];
  final step4Choice = userChoices['step_4_full'] as Map<String, dynamic>?;

  final focusArea = step1Choice?['label'] ?? 'General';
  final expertApproach = step4Choice?['label'] ?? 'Balanced Approach';
  final expertContext = step4Choice?['expert_context'] ?? '';
  final ragWeight = step4Choice?['rag_weight'] ?? 'balanced';

  // Extract step 3 combo field data (session_duration, current_level, etc.)
  final step3Data = <String, dynamic>{};
  userChoices.forEach((key, value) {
    if (key.startsWith('step_3_')) {
      final fieldName = key.replaceFirst('step_3_', '');
      step3Data[fieldName] = value;
    }
  });

  // Extract sample milestones from expert template for RAG
  final expertMilestones = expertTemplate['milestones'] as List? ?? [];
  final sampleMilestones = expertMilestones.take(3).map((m) {
    final milestone = m as Map<String, dynamic>;
    return {
      'title': milestone['title'],
      'description': milestone['description'],
      'sub_steps': (milestone['sub_steps'] as List).take(1).toList(),
    };
  }).toList();

  return '''
You are creating a personalized $skillKey skill path curriculum for a learner.

EXPERT CONTEXT (RAG - use as reference):
Template Description: ${expertTemplate['description']}

Sample Expert Milestones (for style and quality reference):
${jsonEncode(sampleMilestones)}

USER PREFERENCES:
- Focus Area: $focusArea
- Teaching Approach: $expertApproach
- Expert Context: $expertContext
- Step 2 Choices: $step2Choice
- Step 3 Details: ${jsonEncode(step3Data)}
- RAG Weight: $ragWeight (${ragWeight == 'primary' ? 'heavily reference this expert' : 'blend from multiple experts'})

TASK:
Generate a complete $skillKey curriculum with:
- Exactly 15 milestones
- Each milestone has 3 sub-steps
- Total: 45 learning steps

REQUIREMENTS:
1. Match the expert template's quality and style
2. Reference real experts in step content (like the template does)
3. Adapt to user's focus area and preferences
4. Use specific tools, measurements, and techniques
5. Include professional-level detail
6. Create a progressive learning path (beginner → advanced)
7. If RAG weight is "primary", emphasize that expert's methodology throughout

OUTPUT FORMAT (JSON):
{
  "skill_name": "$skillKey",
  "skill_icon": "${expertTemplate['skill_icon']}",
  "total_milestones": 15,
  "milestones": [
    {
      "milestone_number": 1,
      "title": "Milestone Title",
      "description": "Brief description of what this milestone covers",
      "sub_steps": [
        {
          "step_number": 1,
          "title": "Step Title",
          "content": "Detailed instructional content with expert references, specific techniques, and clear guidance"
        },
        // ... 2 more sub-steps
      ]
    },
    // ... 14 more milestones
  ]
}

Generate the curriculum now. Output ONLY valid JSON, no other text.
''';
}

/// Creates a SkillPathRecord in Firestore with the generated curriculum
Future<DocumentReference?> _createSkillPath(
  String skillKey,
  Map<String, dynamic> userChoices,
  Map<String, dynamic> generatedCurriculum,
) async {
  try {
    final currentUser = currentUserReference;
    if (currentUser == null) {
      debugPrint('❌ No current user');
      return null;
    }

    final skillName = generatedCurriculum['skill_name'] as String? ?? skillKey;
    final skillIcon = generatedCurriculum['skill_icon'] as String? ?? '📚';
    final totalMilestones = generatedCurriculum['total_milestones'] as int? ?? 15;
    final rawMilestones = generatedCurriculum['milestones'] as List? ?? [];

    // Transform AI-generated milestones to match Firestore schema
    final milestones = rawMilestones.map((m) {
      final milestone = m as Map<String, dynamic>;
      final rawSubSteps = milestone['sub_steps'] as List? ?? [];

      return {
        'number': milestone['milestone_number'] ?? milestone['number'] ?? 0,
        'title': milestone['title'] ?? '',
        'completed': false,
        'completed_date': null,
        'sub_milestones': rawSubSteps.map((s) {
          final subStep = s as Map<String, dynamic>;
          return {
            'title': subStep['title'] ?? subStep['content'] ?? '',
            'video_search': '', // Will be auto-generated later if needed
            'completed': false,
            'completed_date': null,
          };
        }).toList(),
      };
    }).toList();

    // Calculate total sub-milestones
    final totalSubMilestones = milestones.fold<int>(
      0,
      (sum, m) => sum + ((m['sub_milestones'] as List).length),
    );

    // Create the skill path document
    final skillPathData = {
      'skill_name': skillName,
      'skill_icon': skillIcon,
      'user_ref': currentUser,
      'total_milestones': totalMilestones,
      'total_sub_milestones': totalSubMilestones,
      'completed_milestones': 0,
      'completed_sub_milestones': 0,
      'progress_percentage': 0.0,
      'milestones': milestones,
      'user_preferences': userChoices, // Store for reference
      'created_at': FieldValue.serverTimestamp(),
      'last_updated': FieldValue.serverTimestamp(),
    };

    final docRef = await FirebaseFirestore.instance
        .collection('skill_path')
        .add(skillPathData);

    return docRef;
  } catch (e) {
    debugPrint('❌ Error creating skill path: $e');
    return null;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
