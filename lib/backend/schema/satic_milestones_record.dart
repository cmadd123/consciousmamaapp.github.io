import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SaticMilestonesRecord extends FirestoreRecord {
  SaticMilestonesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "Title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "Category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "act_goal" field.
  ActGoalMilestones? _actGoal;
  ActGoalMilestones? get actGoal => _actGoal;
  bool hasActGoal() => _actGoal != null;

  // "age" field.
  double? _age;
  double get age => _age ?? 0.0;
  bool hasAge() => _age != null;

  void _initializeFields() {
    _title = snapshotData['Title'] as String?;
    _category = snapshotData['Category'] as String?;
    _actGoal = snapshotData['act_goal'] is ActGoalMilestones
        ? snapshotData['act_goal']
        : deserializeEnum<ActGoalMilestones>(snapshotData['act_goal']);
    _age = castToType<double>(snapshotData['age']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Static_Milestones');

  static Stream<SaticMilestonesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SaticMilestonesRecord.fromSnapshot(s));

  static Future<SaticMilestonesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SaticMilestonesRecord.fromSnapshot(s));

  static SaticMilestonesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SaticMilestonesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SaticMilestonesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SaticMilestonesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SaticMilestonesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SaticMilestonesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSaticMilestonesRecordData({
  String? title,
  String? category,
  ActGoalMilestones? actGoal,
  double? age,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Title': title,
      'Category': category,
      'act_goal': actGoal,
      'age': age,
    }.withoutNulls,
  );

  return firestoreData;
}

class SaticMilestonesRecordDocumentEquality
    implements Equality<SaticMilestonesRecord> {
  const SaticMilestonesRecordDocumentEquality();

  @override
  bool equals(SaticMilestonesRecord? e1, SaticMilestonesRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.category == e2?.category &&
        e1?.actGoal == e2?.actGoal &&
        e1?.age == e2?.age;
  }

  @override
  int hash(SaticMilestonesRecord? e) =>
      const ListEquality().hash([e?.title, e?.category, e?.actGoal, e?.age]);

  @override
  bool isValidKey(Object? o) => o is SaticMilestonesRecord;
}
