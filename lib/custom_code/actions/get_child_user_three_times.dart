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

Future<List<ChildernRecord>> getChildUserThreeTimes(
    List<ChildernRecord>? childreanOrgnailList) async {
  // make a new list contain that have  childreanOrgnailList values  3 times
  List<ChildernRecord> newList = [];

  if (childreanOrgnailList != null) {
    for (ChildernRecord record in childreanOrgnailList) {
      newList.add(record);
      newList.add(record);
      newList.add(record);
    }
  }

  return newList;
}
