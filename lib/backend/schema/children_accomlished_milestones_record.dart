import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChildrenAccomlishedMilestonesRecord extends FirestoreRecord {
  ChildrenAccomlishedMilestonesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "child" field.
  DocumentReference? _child;
  DocumentReference? get child => _child;
  bool hasChild() => _child != null;

  // "milestone" field.
  DocumentReference? _milestone;
  DocumentReference? get milestone => _milestone;
  bool hasMilestone() => _milestone != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "age" field.
  double? _age;
  double get age => _age ?? 0.0;
  bool hasAge() => _age != null;

  void _initializeFields() {
    _child = snapshotData['child'] as DocumentReference?;
    _milestone = snapshotData['milestone'] as DocumentReference?;
    _category = snapshotData['category'] as String?;
    _age = castToType<double>(snapshotData['age']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('children_accomlished_milestones');

  static Stream<ChildrenAccomlishedMilestonesRecord> getDocument(
          DocumentReference ref) =>
      ref
          .snapshots()
          .map((s) => ChildrenAccomlishedMilestonesRecord.fromSnapshot(s));

  static Future<ChildrenAccomlishedMilestonesRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref
          .get()
          .then((s) => ChildrenAccomlishedMilestonesRecord.fromSnapshot(s));

  static ChildrenAccomlishedMilestonesRecord fromSnapshot(
          DocumentSnapshot snapshot) =>
      ChildrenAccomlishedMilestonesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChildrenAccomlishedMilestonesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChildrenAccomlishedMilestonesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChildrenAccomlishedMilestonesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChildrenAccomlishedMilestonesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChildrenAccomlishedMilestonesRecordData({
  DocumentReference? child,
  DocumentReference? milestone,
  String? category,
  double? age,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'child': child,
      'milestone': milestone,
      'category': category,
      'age': age,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChildrenAccomlishedMilestonesRecordDocumentEquality
    implements Equality<ChildrenAccomlishedMilestonesRecord> {
  const ChildrenAccomlishedMilestonesRecordDocumentEquality();

  @override
  bool equals(ChildrenAccomlishedMilestonesRecord? e1,
      ChildrenAccomlishedMilestonesRecord? e2) {
    return e1?.child == e2?.child &&
        e1?.milestone == e2?.milestone &&
        e1?.category == e2?.category &&
        e1?.age == e2?.age;
  }

  @override
  int hash(ChildrenAccomlishedMilestonesRecord? e) =>
      const ListEquality().hash([e?.child, e?.milestone, e?.category, e?.age]);

  @override
  bool isValidKey(Object? o) => o is ChildrenAccomlishedMilestonesRecord;
}
