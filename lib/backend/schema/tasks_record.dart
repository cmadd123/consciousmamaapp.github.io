import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TasksRecord extends FirestoreRecord {
  TasksRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "duration" field.
  double? _duration;
  double get duration => _duration ?? 0.0;
  bool hasDuration() => _duration != null;

  // "created_by" field.
  DocumentReference? _createdBy;
  DocumentReference? get createdBy => _createdBy;
  bool hasCreatedBy() => _createdBy != null;

  // "selected_child" field.
  DocumentReference? _selectedChild;
  DocumentReference? get selectedChild => _selectedChild;
  bool hasSelectedChild() => _selectedChild != null;

  // "program_id" field.
  DocumentReference? _programId;
  DocumentReference? get programId => _programId;
  bool hasProgramId() => _programId != null;

  // "task_date" field.
  String? _taskDate;
  String get taskDate => _taskDate ?? '';
  bool hasTaskDate() => _taskDate != null;

  // "task_start_time" field.
  DateTime? _taskStartTime;
  DateTime? get taskStartTime => _taskStartTime;
  bool hasTaskStartTime() => _taskStartTime != null;

  // "iscompeted" field.
  bool? _iscompeted;
  bool get iscompeted => _iscompeted ?? false;
  bool hasIscompeted() => _iscompeted != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _duration = castToType<double>(snapshotData['duration']);
    _createdBy = snapshotData['created_by'] as DocumentReference?;
    _selectedChild = snapshotData['selected_child'] as DocumentReference?;
    _programId = snapshotData['program_id'] as DocumentReference?;
    _taskDate = snapshotData['task_date'] as String?;
    _taskStartTime = snapshotData['task_start_time'] as DateTime?;
    _iscompeted = snapshotData['iscompeted'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Tasks');

  static Stream<TasksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TasksRecord.fromSnapshot(s));

  static Future<TasksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TasksRecord.fromSnapshot(s));

  static TasksRecord fromSnapshot(DocumentSnapshot snapshot) => TasksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TasksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TasksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TasksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TasksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTasksRecordData({
  String? title,
  String? description,
  double? duration,
  DocumentReference? createdBy,
  DocumentReference? selectedChild,
  DocumentReference? programId,
  String? taskDate,
  DateTime? taskStartTime,
  bool? iscompeted,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'description': description,
      'duration': duration,
      'created_by': createdBy,
      'selected_child': selectedChild,
      'program_id': programId,
      'task_date': taskDate,
      'task_start_time': taskStartTime,
      'iscompeted': iscompeted,
    }.withoutNulls,
  );

  return firestoreData;
}

class TasksRecordDocumentEquality implements Equality<TasksRecord> {
  const TasksRecordDocumentEquality();

  @override
  bool equals(TasksRecord? e1, TasksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.duration == e2?.duration &&
        e1?.createdBy == e2?.createdBy &&
        e1?.selectedChild == e2?.selectedChild &&
        e1?.programId == e2?.programId &&
        e1?.taskDate == e2?.taskDate &&
        e1?.taskStartTime == e2?.taskStartTime &&
        e1?.iscompeted == e2?.iscompeted;
  }

  @override
  int hash(TasksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.description,
        e?.duration,
        e?.createdBy,
        e?.selectedChild,
        e?.programId,
        e?.taskDate,
        e?.taskStartTime,
        e?.iscompeted
      ]);

  @override
  bool isValidKey(Object? o) => o is TasksRecord;
}
