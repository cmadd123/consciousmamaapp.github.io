import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Helper function to get OpenAI authorization header from Remote Config
String _getOpenAiAuthHeader() {
  return 'Bearer ${FFAppState().openAiKey}';
}

/// Start OpenAi custom Group Code

class OpenAiCustomGroup {
  static String getBaseUrl() => 'https://api.openai.com/v1';
  static Map<String, String> get headers => {
    'Authorization': _getOpenAiAuthHeader(),
    'Content-Type': 'application/json',
  };
  static CreateThreadNCall createThreadNCall = CreateThreadNCall();
  static AddMessageToThreidCall addMessageToThreidCall =
      AddMessageToThreidCall();
  static CreateRunnCall createRunnCall = CreateRunnCall();
  static GetMessagesCall getMessagesCall = GetMessagesCall();
  static ChatCompletionCall chatCompletionCall = ChatCompletionCall();
  static CreateProgrammesCall createProgrammesCall = CreateProgrammesCall();
  static GetRunNCall getRunNCall = GetRunNCall();
}

class CreateThreadNCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'createThreadN',
      apiUrl: '$baseUrl/threads',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? threadID(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.id''',
      ));
}

class AddMessageToThreidCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? message = '',
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "role": "user",
  "content": "${escapeStringForJson(message)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Add message to threid',
      apiUrl: '$baseUrl/threads/$threadId/messages',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateRunnCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? assistantId = '',
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "assistant_id":"${escapeStringForJson(assistantId)}" 
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'create runn',
      apiUrl: '$baseUrl/threads/$threadId/runs',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: true,
      alwaysAllowBody: false,
    );
  }
}

class GetMessagesCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'get messages',
      apiUrl: '$baseUrl/threads/$threadId/messages',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v2',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ChatCompletionCall {
  Future<ApiCallResponse> call({
    dynamic messagesJson,
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    final messages = _serializeJson(messagesJson, true);
    final ffApiRequestBody = '''
{
  "model": "gpt-4o-mini",
  "messages": $messages,
  "stream": true
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Chat completion ',
      apiUrl: '$baseUrl/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: true,
      alwaysAllowBody: false,
    );
  }
}

class CreateProgrammesCall {
  Future<ApiCallResponse> call({
    String? challengeDescription = '',
    String? childBirthDate = '',
    int? frequency,
    String? preferedTime = '',
    String? currentDate = '',
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": "You are an AI assistant that generates a structured list of activities (tasks), minimum 10 tasks, for parents to do with their children to overcome a specific challenge. You will return a JSON array of tasks following a predefined schema.\\n\\n### Input Data:\\n- **Challenge Description:** ${escapeStringForJson(challengeDescription)}\\n- **Child's Birthdate:** ${escapeStringForJson(childBirthDate)} (format: YYYY-MM-DD)\\n- **Child's Age:** Calculate the child's age based on the birthdate and today's date (${escapeStringForJson(currentDate)}).\\n\\n### Task Schema (Use this format for the response):\\nEach task in the response should follow this structure:\\n\\n\`\`\`json\\n[\\n  {\\n    \\"title\\": \\"Task title\\",\\n    \\"description\\": \\"Detailed explanation of the activity\\",\\n \\"duration\\": ideal duration of the task in hour,\\n   }\\n]\\n\`\`\`\\n\\n### Additional Guidelines:\\n- The **duration** should be reasonable for a child of the given birthdate and age.\\n- **Ensure the activities are age-appropriate** based on the child's calculated age.\\n- Tasks should be engaging, educational, and suited to the challenge described.\\n\\n### Response Format:\\nReturn only the JSON array with tasks, **without extra text or explanations**."
    }
  ],
  "response_format": {
    "type": "json_object"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Programmes',
      apiUrl: '$baseUrl/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? content(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.choices[:].message.content''',
      ));
}

class GetRunNCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? runId = '',
  }) async {
    final baseUrl = OpenAiCustomGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'get run n',
      apiUrl: '$baseUrl/threads/$threadId/runs/$runId',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': _getOpenAiAuthHeader(),
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End OpenAi custom Group Code

class FireBaseEndPointCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'fireBaseEndPoint',
      apiUrl:
          'https://firestore.googleapis.com/v1/projects/parenting-plus-7szrif/databases/(default)/documents/Tasks',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.name''',
      ));
  static String? createTime(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.createTime''',
      ));
  static String? updateTime(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.updateTime''',
      ));
}

// MealNewCall - stub class to prevent compilation errors in legacy v1 code
// This API is no longer used - the v2 meal planner doesn't use Spoonacular
class MealNewCall {
  static Future<ApiCallResponse> call({
    String? query = '',
    String? intolerances = '',
    bool? addRecipeInformation,
    String? includeIngredients = '',
    bool? addRecipeInstructions,
    bool? fillIngredients,
    String? diet = '',
    int? ranking,
    String? type = '',
    String? excludeIngredients = '',
    int? maxReadyTime,
  }) async {
    // Return empty/failed response - this feature is deprecated
    return const ApiCallResponse(null, {}, 501);
  }

  static List? result(dynamic response) => [];
}

class OpneAiCloudFunctionCall {
  static Future<ApiCallResponse> call({
    String? message = '',
    String? threadId = '',
    String? instructions = '',
  }) async {
    final ffApiRequestBody = '''
{
  "text_message": "${escapeStringForJson(message)}",
  "thread_id": "${escapeStringForJson(threadId)}",
"instructions": 
"${escapeStringForJson(instructions)}" }''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpneAi cloud function',
      apiUrl:
          'https://my-streaming-service-1036869417898.us-central1.run.app/streamOpenAIResponse',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: true,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
