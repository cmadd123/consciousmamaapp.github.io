import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Clear all existing activities and re-upload with complete data
Future<void> clearAndReuploadActivities() async {
  print('Starting clear and re-upload process...');

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference activityCollection = firestore.collection('activity');

    // Step 1: Delete all existing activities
    print('\n--- Deleting existing activities ---');
    final QuerySnapshot existingActivities = await activityCollection.get();
    print('Found ${existingActivities.docs.length} existing activities to delete');

    int deleteCount = 0;
    for (var doc in existingActivities.docs) {
      await doc.reference.delete();
      deleteCount++;
      print('✓ Deleted activity $deleteCount/${existingActivities.docs.length}');
    }

    print('\n--- Deleted all existing activities ---');

    // Step 2: Upload new activities with complete data
    print('\n--- Uploading new activities ---');
    print('📂 Loading JSON file: assets/jsons/activities_complete.json');
    final String jsonString = await rootBundle.loadString('assets/jsons/activities_complete.json');
    print('📄 JSON file loaded, size: ${jsonString.length} characters');

    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> activities = data['activities'];

    print('📊 Found ${activities.length} activities to upload from JSON');

    if (activities.isEmpty) {
      print('❌ ERROR: No activities found in JSON!');
      return;
    }

    // Print first few activity titles for verification
    print('📝 First 3 activities:');
    for (int i = 0; i < 3 && i < activities.length; i++) {
      print('   ${i + 1}. ${activities[i]['title']}');
    }

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < activities.length; i++) {
      try {
        final activity = activities[i] as Map<String, dynamic>;

        // Verify description exists
        if (!activity.containsKey('description') || activity['description'] == null || activity['description'].toString().isEmpty) {
          print('⚠ Warning: Activity ${activity['title']} has no description');
        }

        // Upload as-is - activity_record.dart already handles both lowercase and capitalized fields
        // Keep lowercase for consistency with JSON source
        final Map<String, dynamic> firestoreData = Map.from(activity);

        await activityCollection.add(firestoreData);
        successCount++;
        print('✓ Uploaded: ${activity['title']} ($successCount/${activities.length})');
      } catch (e) {
        errorCount++;
        print('✗ Failed to upload activity ${i + 1}: $e');
      }
    }

    print('\n--- Upload Complete ---');
    print('Deleted: ${deleteCount}');
    print('Successfully uploaded: $successCount');
    print('Errors: $errorCount');
    print('Total: ${activities.length}');
  } catch (e) {
    print('Error: $e');
  }
}
