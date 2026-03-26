// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:cloud_functions/cloud_functions.dart';

Future<String> cleanupUnlabeledContent() async {
  try {
    // Call the Cloud Function
    final result = await FirebaseFunctions.instance
        .httpsCallable('cleanupUnlabeledContent')
        .call({});

    final data = result.data as Map<String, dynamic>;

    if (data['success'] == true) {
      final message = data['message'] as String;
      return message;
    } else {
      return 'Cleanup failed: ${data['message'] ?? 'Unknown error'}';
    }
  } on FirebaseFunctionsException catch (e) {
    print('Cloud function error: ${e.code} - ${e.message}');
    return 'Error: ${e.message ?? 'Failed to cleanup unlabeled content'}';
  } catch (e) {
    print('Error calling cleanup function: $e');
    return 'Error: Failed to cleanup unlabeled content';
  }
}
