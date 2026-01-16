import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LearningPathRecord extends FirestoreRecord {
  LearningPathRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "start_date" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "end_date" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "child_ref" field.
  DocumentReference? _childRef;
  DocumentReference? get childRef => _childRef;
  bool hasChildRef() => _childRef != null;

  // "tasks_count" field.
  int? _tasksCount;
  int get tasksCount => _tasksCount ?? 0;
  bool hasTasksCount() => _tasksCount != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "puzzle_theme" field.
  String? _puzzleTheme;
  String get puzzleTheme => _puzzleTheme ?? 'dinosaurs';
  bool hasPuzzleTheme() => _puzzleTheme != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _startDate = snapshotData['start_date'] as DateTime?;
    _description = snapshotData['description'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _endDate = snapshotData['end_date'] as DateTime?;
    _childRef = snapshotData['child_ref'] as DocumentReference?;
    _tasksCount = castToType<int>(snapshotData['tasks_count']);
    _isCompleted = snapshotData['is_completed'] as bool?;
    _puzzleTheme = snapshotData['puzzle_theme'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('learning_path');

  static Stream<LearningPathRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LearningPathRecord.fromSnapshot(s));

  static Future<LearningPathRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LearningPathRecord.fromSnapshot(s));

  static LearningPathRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LearningPathRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LearningPathRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LearningPathRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LearningPathRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LearningPathRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLearningPathRecordData({
  String? title,
  DateTime? startDate,
  String? description,
  DocumentReference? userRef,
  DateTime? endDate,
  DocumentReference? childRef,
  int? tasksCount,
  bool? isCompleted,
  String? puzzleTheme,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'start_date': startDate,
      'description': description,
      'user_ref': userRef,
      'end_date': endDate,
      'child_ref': childRef,
      'tasks_count': tasksCount,
      'is_completed': isCompleted,
      'puzzle_theme': puzzleTheme,
    }.withoutNulls,
  );

  return firestoreData;
}

class LearningPathRecordDocumentEquality
    implements Equality<LearningPathRecord> {
  const LearningPathRecordDocumentEquality();

  @override
  bool equals(LearningPathRecord? e1, LearningPathRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.startDate == e2?.startDate &&
        e1?.description == e2?.description &&
        e1?.userRef == e2?.userRef &&
        e1?.endDate == e2?.endDate &&
        e1?.childRef == e2?.childRef &&
        e1?.tasksCount == e2?.tasksCount &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.puzzleTheme == e2?.puzzleTheme;
  }

  @override
  int hash(LearningPathRecord? e) => const ListEquality().hash([
        e?.title,
        e?.startDate,
        e?.description,
        e?.userRef,
        e?.endDate,
        e?.childRef,
        e?.tasksCount,
        e?.isCompleted,
        e?.puzzleTheme,
      ]);

  @override
  bool isValidKey(Object? o) => o is LearningPathRecord;
}
