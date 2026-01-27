import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Clear duplicate events/tasks for the current user
/// This addresses the issue where testers are seeing 160+ duplicate events per day
Future<void> clearDuplicateEvents() async {
  if (currentUserReference == null) {
    print('No user logged in');
    return;
  }

  print('Starting duplicate event cleanup...');

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference eventCollection = firestore.collection('event_and_task');

    // Get all events for current user
    print('\n--- Fetching user events ---');
    final QuerySnapshot userEvents = await eventCollection
        .where('user_ref', isEqualTo: currentUserReference)
        .get();

    print('Found ${userEvents.docs.length} total events for user');

    if (userEvents.docs.isEmpty) {
      print('No events to process');
      return;
    }

    // Group events by unique key (name + date + type)
    // Keep only the first occurrence, delete duplicates
    final Map<String, List<DocumentSnapshot>> eventGroups = {};

    for (var doc in userEvents.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String name = data['name'] ?? '';
      final Timestamp? dateTimestamp = data['date'] as Timestamp?;
      final String type = data['typ'] ?? '';

      // Create unique key
      final String key = '${name}_${dateTimestamp?.toDate()}_$type';

      if (!eventGroups.containsKey(key)) {
        eventGroups[key] = [];
      }
      eventGroups[key]!.add(doc);
    }

    print('\n--- Analyzing duplicates ---');
    print('Found ${eventGroups.length} unique events');

    int duplicateCount = 0;
    int keptCount = 0;
    int deletedCount = 0;

    for (var entry in eventGroups.entries) {
      final docs = entry.value;

      if (docs.length > 1) {
        duplicateCount += docs.length - 1;
        print('Found ${docs.length} copies of: ${entry.key}');

        // Keep the first one, delete the rest
        for (int i = 1; i < docs.length; i++) {
          await docs[i].reference.delete();
          deletedCount++;
        }
        keptCount++;
      } else {
        keptCount++;
      }
    }

    print('\n--- Cleanup Complete ---');
    print('Unique events kept: $keptCount');
    print('Duplicate events deleted: $deletedCount');
    print('Total processed: ${userEvents.docs.length}');

  } catch (e) {
    print('Error cleaning up events: $e');
  }
}
