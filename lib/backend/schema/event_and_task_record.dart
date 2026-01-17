import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class EventAndTaskRecord extends FirestoreRecord {
  EventAndTaskRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "isrecurring" field.
  bool? _isrecurring;
  bool get isrecurring => _isrecurring ?? false;
  bool hasIsrecurring() => _isrecurring != null;

  // "selected_child" field.
  DocumentReference? _selectedChild;
  DocumentReference? get selectedChild => _selectedChild;
  bool hasSelectedChild() => _selectedChild != null;

  // "selected_children" field - list for multiple children
  List<DocumentReference>? _selectedChildren;
  List<DocumentReference> get selectedChildren => _selectedChildren ?? const [];
  bool hasSelectedChildren() => _selectedChildren != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "typ" field.
  String? _typ;
  String get typ => _typ ?? '';
  bool hasTyp() => _typ != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "lastGenerated" field.
  DateTime? _lastGenerated;
  DateTime? get lastGenerated => _lastGenerated;
  bool hasLastGenerated() => _lastGenerated != null;

  // "assigned_to_mom" field.
  bool? _assignedToMom;
  bool get assignedToMom => _assignedToMom ?? false;
  bool hasAssignedToMom() => _assignedToMom != null;

  // "assigned_to_dad" field.
  bool? _assignedToDad;
  bool get assignedToDad => _assignedToDad ?? false;
  bool hasAssignedToDad() => _assignedToDad != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _isrecurring = snapshotData['isrecurring'] as bool?;
    _selectedChild = snapshotData['selected_child'] as DocumentReference?;
    _selectedChildren = getDataList(snapshotData['selected_children']);
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _date = snapshotData['date'] as DateTime?;
    _typ = snapshotData['typ'] as String?;
    _isCompleted = snapshotData['is_completed'] as bool?;
    _lastGenerated = snapshotData['lastGenerated'] as DateTime?;
    _assignedToMom = snapshotData['assigned_to_mom'] as bool?;
    _assignedToDad = snapshotData['assigned_to_dad'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('event_and_task');

  static Stream<EventAndTaskRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EventAndTaskRecord.fromSnapshot(s));

  static Future<EventAndTaskRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EventAndTaskRecord.fromSnapshot(s));

  static EventAndTaskRecord fromSnapshot(DocumentSnapshot snapshot) =>
      EventAndTaskRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EventAndTaskRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EventAndTaskRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EventAndTaskRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EventAndTaskRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEventAndTaskRecordData({
  String? name,
  String? description,
  bool? isrecurring,
  DocumentReference? selectedChild,
  List<DocumentReference>? selectedChildren,
  DocumentReference? userRef,
  DateTime? date,
  String? typ,
  bool? isCompleted,
  DateTime? lastGenerated,
  bool? assignedToMom,
  bool? assignedToDad,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'isrecurring': isrecurring,
      'selected_child': selectedChild,
      'selected_children': selectedChildren,
      'user_ref': userRef,
      'date': date,
      'typ': typ,
      'is_completed': isCompleted,
      'lastGenerated': lastGenerated,
      'assigned_to_mom': assignedToMom,
      'assigned_to_dad': assignedToDad,
    }.withoutNulls,
  );

  return firestoreData;
}

class EventAndTaskRecordDocumentEquality
    implements Equality<EventAndTaskRecord> {
  const EventAndTaskRecordDocumentEquality();

  @override
  bool equals(EventAndTaskRecord? e1, EventAndTaskRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.isrecurring == e2?.isrecurring &&
        e1?.selectedChild == e2?.selectedChild &&
        listEquality.equals(e1?.selectedChildren, e2?.selectedChildren) &&
        e1?.userRef == e2?.userRef &&
        e1?.date == e2?.date &&
        e1?.typ == e2?.typ &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.lastGenerated == e2?.lastGenerated &&
        e1?.assignedToMom == e2?.assignedToMom &&
        e1?.assignedToDad == e2?.assignedToDad;
  }

  @override
  int hash(EventAndTaskRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.isrecurring,
        e?.selectedChild,
        e?.selectedChildren,
        e?.userRef,
        e?.date,
        e?.typ,
        e?.isCompleted,
        e?.lastGenerated,
        e?.assignedToMom,
        e?.assignedToDad
      ]);

  @override
  bool isValidKey(Object? o) => o is EventAndTaskRecord;
}
