import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Upload activities from JSON to Firestore.
/// Clears existing activities first to avoid duplicates.
///
/// IMPORTANT: Requires Firestore rules to temporarily allow writes:
///   match /activity/{activityId} { allow write: if isAuthenticated(); }
/// Remember to change it back to `allow write: if false;` after running.
Future<void> uploadActivitiesToFirestore() async {
  print('Starting activity upload...');

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference activityCollection = firestore.collection('activity');

    // Step 1: Delete all existing activities
    print('Clearing existing activities...');
    final existing = await activityCollection.get();
    if (existing.docs.isNotEmpty) {
      int deleted = 0;
      final batches = <WriteBatch>[];
      var batch = firestore.batch();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
        deleted++;
        if (deleted % 500 == 0) {
          batches.add(batch);
          batch = firestore.batch();
        }
      }
      if (deleted % 500 != 0) {
        batches.add(batch);
      }
      for (final b in batches) {
        await b.commit();
      }
      print('Deleted $deleted existing activities');
    } else {
      print('No existing activities to clear');
    }

    // Step 2: Read the JSON file (using the larger 190 dataset)
    final String jsonString = await rootBundle.loadString('assets/jsons/activities_190_new.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> activities = data['activities'];

    print('Found ${activities.length} activities to upload');

    int successCount = 0;
    int errorCount = 0;

    // Step 3: Upload each activity
    for (int i = 0; i < activities.length; i++) {
      try {
        final activity = activities[i] as Map<String, dynamic>;
        await activityCollection.add(activity);
        successCount++;
        if (successCount % 20 == 0) {
          print('Progress: $successCount/${activities.length}');
        }
      } catch (e) {
        errorCount++;
        print('Failed to upload activity ${i + 1}: $e');
      }
    }

    print('\n--- Upload Complete ---');
    print('Successfully uploaded: $successCount');
    print('Errors: $errorCount');
    print('Total: ${activities.length}');
  } catch (e) {
    print('Error: $e');
  }
}
