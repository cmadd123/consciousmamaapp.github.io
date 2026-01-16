import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MealPlanRecord extends FirestoreRecord {
  MealPlanRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "meal_id" field.
  String? _mealId;
  String get mealId => _mealId ?? '';
  bool hasMealId() => _mealId != null;

  // "typ" field.
  MealTyp? _typ;
  MealTyp? get typ => _typ;
  bool hasTyp() => _typ != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "user_firebasemeal" field - Reference to single recipe (MealRecord)
  DocumentReference? _userFirebasemeal;
  DocumentReference? get userFirebasemeal => _userFirebasemeal;
  bool hasUserFirebasemeal() => _userFirebasemeal != null;

  // "meal_combo_ref" field - Reference to meal combo (MealComboRecord)
  DocumentReference? _mealComboRef;
  DocumentReference? get mealComboRef => _mealComboRef;
  bool hasMealComboRef() => _mealComboRef != null;

  // "notes" field - Optional notes for this meal plan entry
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null && _notes!.isNotEmpty;

  // Helper to check if this is a meal combo vs single recipe
  bool get isMealCombo => _mealComboRef != null;

  void _initializeFields() {
    _date = snapshotData['date'] as DateTime?;
    _mealId = snapshotData['meal_id'] as String?;
    _typ = snapshotData['typ'] is MealTyp
        ? snapshotData['typ']
        : deserializeEnum<MealTyp>(snapshotData['typ']);
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _userFirebasemeal = snapshotData['user_firebasemeal'] as DocumentReference?;
    _mealComboRef = snapshotData['meal_combo_ref'] as DocumentReference?;
    _notes = snapshotData['notes'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meal_plan');

  static Stream<MealPlanRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MealPlanRecord.fromSnapshot(s));

  static Future<MealPlanRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MealPlanRecord.fromSnapshot(s));

  static MealPlanRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MealPlanRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MealPlanRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MealPlanRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MealPlanRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MealPlanRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMealPlanRecordData({
  DateTime? date,
  String? mealId,
  MealTyp? typ,
  DocumentReference? userRef,
  DocumentReference? userFirebasemeal,
  DocumentReference? mealComboRef,
  String? notes,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'date': date,
      'meal_id': mealId,
      'typ': typ,
      'user_ref': userRef,
      'user_firebasemeal': userFirebasemeal,
      'meal_combo_ref': mealComboRef,
      'notes': notes,
    }.withoutNulls,
  );

  return firestoreData;
}

class MealPlanRecordDocumentEquality implements Equality<MealPlanRecord> {
  const MealPlanRecordDocumentEquality();

  @override
  bool equals(MealPlanRecord? e1, MealPlanRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.mealId == e2?.mealId &&
        e1?.typ == e2?.typ &&
        e1?.userRef == e2?.userRef &&
        e1?.userFirebasemeal == e2?.userFirebasemeal &&
        e1?.mealComboRef == e2?.mealComboRef &&
        e1?.notes == e2?.notes;
  }

  @override
  int hash(MealPlanRecord? e) => const ListEquality()
      .hash([e?.date, e?.mealId, e?.typ, e?.userRef, e?.userFirebasemeal, e?.mealComboRef, e?.notes]);

  @override
  bool isValidKey(Object? o) => o is MealPlanRecord;
}
