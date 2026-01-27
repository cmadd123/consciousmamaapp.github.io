import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Clear duplicate learning paths for the current user
Future<void> clearDuplicateLearningPaths() async {
  if (currentUserReference == null) {
    print('No user logged in');
    return;
  }

  print('Starting duplicate learning path cleanup...');

  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference learningPathCollection = firestore.collection('learning_path');

    // Get all learning paths for current user
    print('\n--- Fetching user learning paths ---');
    final QuerySnapshot userPaths = await learningPathCollection
        .where('user_ref', isEqualTo: currentUserReference)
        .get();

    print('Found ${userPaths.docs.length} total learning paths for user');

    if (userPaths.docs.isEmpty) {
      print('No learning paths to process');
      return;
    }

    // Group learning paths by unique key (title + child_ref)
    // Keep only the first occurrence, delete duplicates
    final Map<String, List<DocumentSnapshot>> pathGroups = {};

    for (var doc in userPaths.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String title = data['title'] ?? '';
      final childRef = data['child_ref'];

      // Create unique key
      final String key = '${title}_${childRef?.id ?? 'no_child'}';

      if (!pathGroups.containsKey(key)) {
        pathGroups[key] = [];
      }
      pathGroups[key]!.add(doc);
    }

    print('\n--- Analyzing duplicates ---');
    print('Found ${pathGroups.length} unique learning paths');

    int duplicateCount = 0;
    int keptCount = 0;
    int deletedCount = 0;

    for (var entry in pathGroups.entries) {
      final docs = entry.value;

      if (docs.length > 1) {
        duplicateCount += docs.length - 1;
        print('Found ${docs.length} copies of: ${entry.key}');

        // Keep the first one, delete the rest (and their tasks)
        for (int i = 1; i < docs.length; i++) {
          final pathRef = docs[i].reference;

          // Delete associated tasks
          final tasks = await firestore
              .collection('learning_path_tasks')
              .where('learning_path_ref', isEqualTo: pathRef)
              .get();

          for (var task in tasks.docs) {
            await task.reference.delete();
          }

          // Delete the learning path
          await pathRef.delete();
          deletedCount++;
        }
        keptCount++;
      } else {
        keptCount++;
      }
    }

    print('\n--- Cleanup Complete ---');
    print('Unique learning paths kept: $keptCount');
    print('Duplicate learning paths deleted: $deletedCount');
    print('Total processed: ${userPaths.docs.length}');

  } catch (e) {
    print('Error cleaning up learning paths: $e');
  }
}
