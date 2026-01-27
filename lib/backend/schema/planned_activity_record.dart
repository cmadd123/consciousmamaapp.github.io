import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Planned Activity Record - Links activities to calendar dates
///
/// Allows scheduling activities for specific days and children
/// Shows up in both calendar and activities section
class PlannedActivityRecord extends FirestoreRecord {
  PlannedActivityRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "activity_ref" field - reference to the activity
  DocumentReference? _activityRef;
  DocumentReference? get activityRef => _activityRef;
  bool hasActivityRef() => _activityRef != null;

  // "date" field - the scheduled date
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "selected_children" field - which children this is planned for
  List<DocumentReference>? _selectedChildren;
  List<DocumentReference> get selectedChildren => _selectedChildren ?? const [];
  bool hasSelectedChildren() => _selectedChildren != null && _selectedChildren!.isNotEmpty;

  // "is_completed" field - has the activity been done
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "notes" field - optional notes about this planned instance
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _activityRef = snapshotData['activity_ref'] as DocumentReference?;
    _date = snapshotData['date'] as DateTime?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _selectedChildren = getDataList(snapshotData['selected_children']);
    _isCompleted = snapshotData['is_completed'] as bool?;
    _notes = snapshotData['notes'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('planned_activities');

  static Stream<PlannedActivityRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PlannedActivityRecord.fromSnapshot(s));

  static Future<PlannedActivityRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PlannedActivityRecord.fromSnapshot(s));

  static PlannedActivityRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PlannedActivityRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PlannedActivityRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PlannedActivityRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PlannedActivityRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PlannedActivityRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPlannedActivityRecordData({
  DocumentReference? activityRef,
  DateTime? date,
  DocumentReference? userRef,
  List<DocumentReference>? selectedChildren,
  bool? isCompleted,
  String? notes,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'activity_ref': activityRef,
      'date': date,
      'user_ref': userRef,
      'selected_children': selectedChildren,
      'is_completed': isCompleted,
      'notes': notes,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class PlannedActivityRecordDocumentEquality
    implements Equality<PlannedActivityRecord> {
  const PlannedActivityRecordDocumentEquality();

  @override
  bool equals(PlannedActivityRecord? e1, PlannedActivityRecord? e2) {
    const listEquality = ListEquality();
    return e1?.activityRef == e2?.activityRef &&
        e1?.date == e2?.date &&
        e1?.userRef == e2?.userRef &&
        listEquality.equals(e1?.selectedChildren, e2?.selectedChildren) &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.notes == e2?.notes &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(PlannedActivityRecord? e) => const ListEquality().hash([
        e?.activityRef,
        e?.date,
        e?.userRef,
        e?.selectedChildren,
        e?.isCompleted,
        e?.notes,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is PlannedActivityRecord;
}
