import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One-time script to upload activities from JSON to Firestore
/// Run this once to populate the database with initial activities
Future<void> uploadActivitiesToFirestore() async {
  print('Starting activity upload...');

  try {
    // Read the JSON file
    final String jsonString = await rootBundle.loadString('assets/jsons/activities_complete.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> activities = data['activities'];

    print('Found ${activities.length} activities to upload');

    // Get Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference activityCollection = firestore.collection('activity');

    int successCount = 0;
    int errorCount = 0;

    // Upload each activity
    for (int i = 0; i < activities.length; i++) {
      try {
        final activity = activities[i] as Map<String, dynamic>;

        // Add the activity to Firestore
        await activityCollection.add(activity);

        successCount++;
        print('✓ Uploaded: ${activity['title']} ($successCount/${activities.length})');
      } catch (e) {
        errorCount++;
        print('✗ Failed to upload activity ${i + 1}: $e');
      }
    }

    print('\n--- Upload Complete ---');
    print('Successfully uploaded: $successCount');
    print('Errors: $errorCount');
    print('Total: ${activities.length}');
  } catch (e) {
    print('Error reading or parsing JSON file: $e');
  }
}

/// Alternative: Upload from file system instead of assets
Future<void> uploadActivitiesFromFile(String filePath) async {
  print('Starting activity upload from file: $filePath');

  try {
    // Read the JSON file from file system
    final File file = File(filePath);
    final String jsonString = await file.readAsString();
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> activities = data['activities'];

    print('Found ${activities.length} activities to upload');

    // Get Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference activityCollection = firestore.collection('activity');

    int successCount = 0;
    int errorCount = 0;

    // Upload each activity
    for (int i = 0; i < activities.length; i++) {
      try {
        final activity = activities[i] as Map<String, dynamic>;

        // Add the activity to Firestore
        await activityCollection.add(activity);

        successCount++;
        print('✓ Uploaded: ${activity['title']} ($successCount/${activities.length})');
      } catch (e) {
        errorCount++;
        print('✗ Failed to upload activity ${i + 1}: $e');
      }
    }

    print('\n--- Upload Complete ---');
    print('Successfully uploaded: $successCount');
    print('Errors: $errorCount');
    print('Total: ${activities.length}');
  } catch (e) {
    print('Error reading or parsing JSON file: $e');
  }
}
