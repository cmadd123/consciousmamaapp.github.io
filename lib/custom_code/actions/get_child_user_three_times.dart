// Automatic FlutterFlow imports
import '/backend/backend.dart';
// Imports other custom actions
// Imports custom functions
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
