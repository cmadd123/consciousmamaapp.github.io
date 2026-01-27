import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Todo Record - Simple grocery-list style todos
///
/// Supports assignment to children and/or mom/dad
/// Persists until marked complete (no due dates)
class TodoRecord extends FirestoreRecord {
  TodoRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "is_completed" field.
  bool? _isCompleted;
  bool get isCompleted => _isCompleted ?? false;
  bool hasIsCompleted() => _isCompleted != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "selected_children" field - list for multiple children
  List<DocumentReference>? _selectedChildren;
  List<DocumentReference> get selectedChildren => _selectedChildren ?? const [];
  bool hasSelectedChildren() => _selectedChildren != null && _selectedChildren!.isNotEmpty;

  // "assigned_to_mom" field.
  bool? _assignedToMom;
  bool get assignedToMom => _assignedToMom ?? false;
  bool hasAssignedToMom() => _assignedToMom != null;

  // "assigned_to_dad" field.
  bool? _assignedToDad;
  bool get assignedToDad => _assignedToDad ?? false;
  bool hasAssignedToDad() => _assignedToDad != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "sort_order" field - for manual ordering
  int? _sortOrder;
  int get sortOrder => _sortOrder ?? 0;
  bool hasSortOrder() => _sortOrder != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _isCompleted = snapshotData['is_completed'] as bool?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _selectedChildren = getDataList(snapshotData['selected_children']);
    _assignedToMom = snapshotData['assigned_to_mom'] as bool?;
    _assignedToDad = snapshotData['assigned_to_dad'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _sortOrder = castToType<int>(snapshotData['sort_order']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('todos');

  static Stream<TodoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TodoRecord.fromSnapshot(s));

  static Future<TodoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TodoRecord.fromSnapshot(s));

  static TodoRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TodoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TodoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TodoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TodoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TodoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTodoRecordData({
  String? title,
  bool? isCompleted,
  DocumentReference? userRef,
  List<DocumentReference>? selectedChildren,
  bool? assignedToMom,
  bool? assignedToDad,
  DateTime? createdTime,
  int? sortOrder,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'is_completed': isCompleted,
      'user_ref': userRef,
      'selected_children': selectedChildren,
      'assigned_to_mom': assignedToMom,
      'assigned_to_dad': assignedToDad,
      'created_time': createdTime,
      'sort_order': sortOrder,
    }.withoutNulls,
  );

  return firestoreData;
}

class TodoRecordDocumentEquality implements Equality<TodoRecord> {
  const TodoRecordDocumentEquality();

  @override
  bool equals(TodoRecord? e1, TodoRecord? e2) {
    const listEquality = ListEquality();
    return e1?.title == e2?.title &&
        e1?.isCompleted == e2?.isCompleted &&
        e1?.userRef == e2?.userRef &&
        listEquality.equals(e1?.selectedChildren, e2?.selectedChildren) &&
        e1?.assignedToMom == e2?.assignedToMom &&
        e1?.assignedToDad == e2?.assignedToDad &&
        e1?.createdTime == e2?.createdTime &&
        e1?.sortOrder == e2?.sortOrder;
  }

  @override
  int hash(TodoRecord? e) => const ListEquality().hash([
        e?.title,
        e?.isCompleted,
        e?.userRef,
        e?.selectedChildren,
        e?.assignedToMom,
        e?.assignedToDad,
        e?.createdTime,
        e?.sortOrder,
      ]);

  @override
  bool isValidKey(Object? o) => o is TodoRecord;
}
