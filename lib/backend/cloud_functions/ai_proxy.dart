import 'package:cloud_functions/cloud_functions.dart';

/// Calls the `aiGenerate` Cloud Function (functions/ai_proxy.js), which
/// runs the model call server-side with keys from Secret Manager. The app
/// no longer holds an OpenAI key.
///
/// [task] must be one of the server's tasks: appLearningPath,
/// appSkillCurriculum, appActivityIdeas, appIngredientMatch, appChat.
/// Model, temperature, max tokens and system prompt are fixed per task on
/// the server; the client sends only the user prompt (or chat messages /
/// task-specific fields via [extra]).
///
/// Returns the model's text — the same string the app used to read from
/// `choices[0].message.content`. Throws an [Exception] with a user-facing
/// message on failure (signed out, rate-limited, provider down).
Future<String> callAiProxy(
  String task, {
  String? prompt,
  List<Map<String, String>>? messages,
  Map<String, dynamic>? extra,
  Duration timeout = const Duration(seconds: 120),
}) async {
  final payload = <String, dynamic>{'task': task};
  if (prompt != null) payload['prompt'] = prompt;
  if (messages != null) payload['messages'] = messages;
  if (extra != null) payload.addAll(extra);

  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable(
          'aiGenerate',
          options: HttpsCallableOptions(timeout: timeout),
        )
        .call(payload);
    final data = result.data;
    if (data is Map && data['content'] is String) {
      return data['content'] as String;
    }
    throw Exception('The AI service returned an unexpected response.');
  } on FirebaseFunctionsException catch (e) {
    throw Exception(e.message ?? 'AI service error (${e.code})');
  }
}
