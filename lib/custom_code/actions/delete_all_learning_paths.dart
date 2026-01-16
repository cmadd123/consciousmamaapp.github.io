import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Deletes all learning paths and their tasks for the current user
Future<void> deleteAllLearningPaths() async {
  final userRef = currentUserReference;
  if (userRef == null) return;

  final firestore = FirebaseFirestore.instance;

  // Get all learning paths for this user
  final pathsSnapshot = await firestore
      .collection('learning_path')
      .where('user_ref', isEqualTo: userRef)
      .get();

  // Delete each path and its tasks
  for (final pathDoc in pathsSnapshot.docs) {
    // Delete all tasks for this learning path
    final tasksSnapshot = await firestore
        .collection('learning_path_tasks')
        .where('program_ref', isEqualTo: pathDoc.reference)
        .get();

    for (final taskDoc in tasksSnapshot.docs) {
      await taskDoc.reference.delete();
    }

    // Delete the learning path itself
    await pathDoc.reference.delete();
  }

  // Also delete any orphaned tasks that belong to this user
  final orphanedTasks = await firestore
      .collection('learning_path_tasks')
      .where('user_ref', isEqualTo: userRef)
      .get();

  for (final taskDoc in orphanedTasks.docs) {
    await taskDoc.reference.delete();
  }
}
