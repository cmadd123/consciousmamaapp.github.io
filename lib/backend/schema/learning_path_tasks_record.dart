import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LearningPathTasksRecord extends FirestoreRecord {
  LearningPathTasksRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "program_ref" field.
  DocumentReference? _programRef;
  DocumentReference? get programRef => _programRef;
  bool hasProgramRef() => _programRef != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "task_time" field.
  DateTime? _taskTime;
  DateTime? get taskTime => _taskTime;
  bool hasTaskTime() => _taskTime != null;

  // "child_ref" field.
  DocumentReference? _childRef;
  DocumentReference? get childRef => _childRef;
  bool hasChildRef() => _childRef != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  // "was_skipped" field.
  bool? _wasSkipped;
  bool get wasSkipped => _wasSkipped ?? false;
  bool hasWasSkipped() => _wasSkipped != null;

  // "completion_feedback" field.
  String? _completionFeedback;
  String get completionFeedback => _completionFeedback ?? '';
  bool hasCompletionFeedback() => _completionFeedback != null;

  // "completion_note" field.
  String? _completionNote;
  String get completionNote => _completionNote ?? '';
  bool hasCompletionNote() => _completionNote != null;

  void _initializeFields() {
    _createdAt = snapshotData['created_at'] as DateTime?;
    _description = snapshotData['description'] as String?;
    _programRef = snapshotData['program_ref'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _taskTime = snapshotData['task_time'] as DateTime?;
    _childRef = snapshotData['child_ref'] as DocumentReference?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _isCompleted = snapshotData['is_completed'] as bool?;
    _duration = castToType<int>(snapshotData['duration']);
    _wasSkipped = snapshotData['was_skipped'] as bool?;
    _completionFeedback = snapshotData['completion_feedback'] as String?;
    _completionNote = snapshotData['completion_note'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('learning_path_tasks');

  static Stream<LearningPathTasksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LearningPathTasksRecord.fromSnapshot(s));

  static Future<LearningPathTasksRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => LearningPathTasksRecord.fromSnapshot(s));

  static LearningPathTasksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LearningPathTasksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LearningPathTasksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LearningPathTasksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LearningPathTasksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LearningPathTasksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLearningPathTasksRecordData({
  DateTime? createdAt,
  String? description,
  DocumentReference? programRef,
  String? title,
  DateTime? taskTime,
  DocumentReference? childRef,
  DocumentReference? userRef,
  bool? isCompleted,
  int? duration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'created_at': createdAt,
      'description': description,
      'program_ref': programRef,
      'title': title,
      'task_time': taskTime,
      'child_ref': childRef,
      'user_ref': userRef,
      'is_completed': isCompleted,
      'duration': duration,
    }.withoutNulls,
  );

  return firestoreData;
}

class LearningPathTasksRecordDocumentEquality
    implements Equality<LearningPathTasksRecord> {
  const LearningPathTasksRecordDocumentEquality();

  @override
  bool equals(LearningPathTasksRecord? e1, LearningPathTasksRecord? e2) {
    return e1?.createdAt == e2?.createdAt &&
        e1?.description == e2?.description &&
        e1?.programRef == e2?.programRef &&
        e1?.title == e2?.title &&
        e1?.taskTime == e2?.taskTime &&
        e1?.childRef == e2?.childRef &&
        e1?.userRef == e2?.userRef &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.duration == e2?.duration;
  }

  @override
  int hash(LearningPathTasksRecord? e) => const ListEquality().hash([
        e?.createdAt,
        e?.description,
        e?.programRef,
        e?.title,
        e?.taskTime,
        e?.childRef,
        e?.userRef,
        e?.isCompleted,
        e?.duration
      ]);

  @override
  bool isValidKey(Object? o) => o is LearningPathTasksRecord;
}
