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

Future parseAndSaveProgram(
  String openAiResponse,
  DocumentReference? selectedChild,
  DocumentReference? createdBy,
) async {
  // Add your function code here!
  // Step 1: Convert JSON string to Map
  try {
    // Step 1: Convert JSON string to Map
    Map<String, dynamic> decodedResponse = jsonDecode(openAiResponse);

    // Step 2: Extract program details with safety checks
    String programTitle = decodedResponse["title"] ?? "Untitled Program";
    List<dynamic> tasks =
        decodedResponse["tasks"] ?? []; // Ensure tasks is a list

    if (tasks.isEmpty) {
      print("Error: No tasks found in OpenAI response.");
      return; // Exit the function early
    }

    // Step 3: Reference Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Step 4: Store Program in 'Programs' collection
    DocumentReference programRef = await firestore.collection('programs').add({
      'title': programTitle,
      'tasks': [], // Tasks will be added later
      'created_at': FieldValue.serverTimestamp(),
      'created_by': createdBy, // Add created_by field
    });

    // Step 5: Store Tasks in 'Tasks' collection and link them to the program
    List<DocumentReference> taskRefs = [];

    for (var task in tasks) {
      DocumentReference taskRef = await firestore.collection('Tasks').add({
        'title': task["title"] ?? "Untitled Task",
        'description': task["description"] ?? "No description",
        'mission_start_time': task["mission_start_time"] != null
            ? Timestamp.fromDate(DateTime.parse(task["mission_start_time"]))
            : FieldValue.serverTimestamp(),
        'duration': (task["duration"] ?? 0).toDouble(),
        'created_by': createdBy, // Use provided createdBy
        'selected_child': selectedChild, // Use provided selectedChild
        'program_id': programRef, // Link task to program
        'created_at': FieldValue.serverTimestamp(),
      });

      // Store task reference
      taskRefs.add(taskRef);
    }

    // Step 6: Update program with task references
    await programRef.update({'tasks': taskRefs});

    print("✅ Program and tasks successfully stored in Firebase!");
  } catch (e) {
    print("❌ Error processing OpenAI response: $e");
  }
}
