import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProgramsRecord extends FirestoreRecord {
  ProgramsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "tasks" field.
  List<DocumentReference>? _tasks;
  List<DocumentReference> get tasks => _tasks ?? const [];
  bool hasTasks() => _tasks != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "created_by" field.
  DocumentReference? _createdBy;
  DocumentReference? get createdBy => _createdBy;
  bool hasCreatedBy() => _createdBy != null;

  // "end_date" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "start_date" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "task_dates" field.
  List<DateTime>? _taskDates;
  List<DateTime> get taskDates => _taskDates ?? const [];
  bool hasTaskDates() => _taskDates != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _tasks = getDataList(snapshotData['tasks']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _createdBy = snapshotData['created_by'] as DocumentReference?;
    _endDate = snapshotData['end_date'] as DateTime?;
    _description = snapshotData['description'] as String?;
    _startDate = snapshotData['start_date'] as DateTime?;
    _taskDates = getDataList(snapshotData['task_dates']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('programs');

  static Stream<ProgramsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProgramsRecord.fromSnapshot(s));

  static Future<ProgramsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProgramsRecord.fromSnapshot(s));

  static ProgramsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProgramsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProgramsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProgramsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProgramsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProgramsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProgramsRecordData({
  String? title,
  DateTime? createdAt,
  DocumentReference? createdBy,
  DateTime? endDate,
  String? description,
  DateTime? startDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'created_at': createdAt,
      'created_by': createdBy,
      'end_date': endDate,
      'description': description,
      'start_date': startDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProgramsRecordDocumentEquality implements Equality<ProgramsRecord> {
  const ProgramsRecordDocumentEquality();

  @override
  bool equals(ProgramsRecord? e1, ProgramsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.title == e2?.title &&
        listEquality.equals(e1?.tasks, e2?.tasks) &&
        e1?.createdAt == e2?.createdAt &&
        e1?.createdBy == e2?.createdBy &&
        e1?.endDate == e2?.endDate &&
        e1?.description == e2?.description &&
        e1?.startDate == e2?.startDate &&
        listEquality.equals(e1?.taskDates, e2?.taskDates);
  }

  @override
  int hash(ProgramsRecord? e) => const ListEquality().hash([
        e?.title,
        e?.tasks,
        e?.createdAt,
        e?.createdBy,
        e?.endDate,
        e?.description,
        e?.startDate,
        e?.taskDates
      ]);

  @override
  bool isValidKey(Object? o) => o is ProgramsRecord;
}
