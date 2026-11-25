import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start OpenAi custom Group Code
///
/// SECURITY: these used to call api.openai.com directly with a key shipped
/// to the app via Remote Config. That key path is gone. The only live
/// caller (legacy v1 AI chat, ai_chat_completion_widget.dart) now uses the
/// `aiGenerate` Cloud Function via lib/backend/cloud_functions/ai_proxy.dart.
/// The classes below are kept as inert stubs (HTTP 410, no network) so the
/// unrouted legacy assistant widget still compiles.

class OpenAiCustomGroup {
  static CreateThreadNCall createThreadNCall = CreateThreadNCall();
  static AddMessageToThreidCall addMessageToThreidCall =
      AddMessageToThreidCall();
  static CreateRunnCall createRunnCall = CreateRunnCall();
  static GetMessagesCall getMessagesCall = GetMessagesCall();
  static ChatCompletionCall chatCompletionCall = ChatCompletionCall();
  static CreateProgrammesCall createProgrammesCall = CreateProgrammesCall();
  static GetRunNCall getRunNCall = GetRunNCall();
}

const ApiCallResponse _kOpenAiRemoved = ApiCallResponse(null, {}, 410);

class CreateThreadNCall {
  Future<ApiCallResponse> call() async => _kOpenAiRemoved;

  String? threadID(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.id''',
      ));
}

class AddMessageToThreidCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? message = '',
  }) async =>
      _kOpenAiRemoved;
}

class CreateRunnCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? assistantId = '',
  }) async =>
      _kOpenAiRemoved;
}

class GetMessagesCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
  }) async =>
      _kOpenAiRemoved;
}

class ChatCompletionCall {
  Future<ApiCallResponse> call({
    dynamic messagesJson,
  }) async =>
      _kOpenAiRemoved;
}

class CreateProgrammesCall {
  Future<ApiCallResponse> call({
    String? challengeDescription = '',
    String? childBirthDate = '',
    int? frequency,
    String? preferedTime = '',
    String? currentDate = '',
  }) async =>
      _kOpenAiRemoved;

  String? content(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.choices[:].message.content''',
      ));
}

class GetRunNCall {
  Future<ApiCallResponse> call({
    String? threadId = '',
    String? runId = '',
  }) async =>
      _kOpenAiRemoved;
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
