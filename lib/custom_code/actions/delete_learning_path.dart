import 'package:cloud_firestore/cloud_firestore.dart';

/// Deletes a single learning path and all its associated tasks
Future<void> deleteLearningPath(DocumentReference learningPathRef) async {
  final firestore = FirebaseFirestore.instance;

  // Delete all tasks for this learning path
  final tasksSnapshot = await firestore
      .collection('learning_path_tasks')
      .where('program_ref', isEqualTo: learningPathRef)
      .get();

  for (final taskDoc in tasksSnapshot.docs) {
    await taskDoc.reference.delete();
  }

  // Delete the learning path itself
  await learningPathRef.delete();
}
