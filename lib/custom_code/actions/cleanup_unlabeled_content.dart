// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
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
