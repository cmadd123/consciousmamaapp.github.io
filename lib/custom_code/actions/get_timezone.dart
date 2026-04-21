// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_timezone/flutter_timezone.dart';

Future<String> getTimezone() async {
  try {
    final String timezone = await FlutterTimezone.getLocalTimezone();
    return timezone;
  } catch (e) {
    print("Error getting timezone: $e");
    return "Unknown";
  }
}
