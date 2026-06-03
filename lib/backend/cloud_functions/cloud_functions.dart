import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// HTTP-based cloud function call for functions that use onRequest
/// Includes Firebase Auth token for server-side verification
Future<Map<String, dynamic>> makeHttpCloudCall(
  String functionName,
  Map<String, dynamic> input,
) async {
  const projectRegion = 'us-central1';
  const projectId = 'parenting-plus-7szrif';
  final url = 'https://$projectRegion-$projectId.cloudfunctions.net/$functionName';

  final headers = <String, String>{'Content-Type': 'application/json'};
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final token = await user.getIdToken();
    if (token != null) headers['Authorization'] = 'Bearer $token';
  }

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'data': input}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] is Map
          ? Map<String, dynamic>.from(data['result'] as Map)
          : {};
    } else {
      final data = jsonDecode(response.body);
      final error = data['result']?['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  } catch (e) {
    print('HTTP cloud call error: $functionName - $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> makeCloudCall(
  String callName,
  Map<String, dynamic> input,
) async {
  // Use HTTP endpoint for onRequest functions that bypass App Check.
  if (callName == 'extractRecipe' || callName == 'dedupGroceryList') {
    return makeHttpCloudCall(callName, input);
  }

  try {
    final response = await FirebaseFunctions.instance
        .httpsCallable(callName, options: HttpsCallableOptions())
        .call(input);
    return response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : {};
  } on FirebaseFunctionsException catch (e) {
    print(
      'Cloud call error!\n ${callName}'
      'Code: ${e.code}\n'
      'Details: ${e.details}\n'
      'Message: ${e.message}',
    );
    // Re-throw with the actual error message from the cloud function
    throw Exception(e.message ?? 'Cloud function error');
  } catch (e) {
    print('Cloud call error:${callName} $e');
    rethrow;
  }
}
