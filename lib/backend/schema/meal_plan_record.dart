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

  // "side_refs" field - List of side recipe references (for ad-hoc meal compositions)
  List<DocumentReference>? _sideRefs;
  List<DocumentReference> get sideRefs => _sideRefs ?? const [];
  bool hasSideRefs() => _sideRefs != null && _sideRefs!.isNotEmpty;

  // "dessert_refs" field - List of dessert recipe references (for ad-hoc meal compositions)
  List<DocumentReference>? _dessertRefs;
  List<DocumentReference> get dessertRefs => _dessertRefs ?? const [];
  bool hasDessertRefs() => _dessertRefs != null && _dessertRefs!.isNotEmpty;

  // "drink_type" field - Drink selection (for ad-hoc meal compositions)
  DrinkType? _drinkType;
  DrinkType? get drinkType => _drinkType;
  bool hasDrinkType() => _drinkType != null;

  // "drink_custom" field - Custom drink name if drink_type is Other
  String? _drinkCustom;
  String get drinkCustom => _drinkCustom ?? '';
  bool hasDrinkCustom() => _drinkCustom != null;

  // "is_leftover_entree" field - Mark entree as leftover (excludes from grocery list)
  bool? _isLeftoverEntree;
  bool get isLeftoverEntree => _isLeftoverEntree ?? false;
  bool hasIsLeftoverEntree() => _isLeftoverEntree != null;

  // "is_leftover_side" field - Mark side as leftover (excludes from grocery list)
  bool? _isLeftoverSide;
  bool get isLeftoverSide => _isLeftoverSide ?? false;
  bool hasIsLeftoverSide() => _isLeftoverSide != null;

  // "is_leftover_dessert" field - Mark dessert as leftover (excludes from grocery list)
  bool? _isLeftoverDessert;
  bool get isLeftoverDessert => _isLeftoverDessert ?? false;
  bool hasIsLeftoverDessert() => _isLeftoverDessert != null;

  // "is_leftover_snack" field - Mark snack as leftover (excludes from grocery list)
  bool? _isLeftoverSnack;
  bool get isLeftoverSnack => _isLeftoverSnack ?? false;
  bool hasIsLeftoverSnack() => _isLeftoverSnack != null;

  // "custom_meal" field - Custom meal text (e.g., "Eating Out", "Pizza Delivery")
  String? _customMeal;
  String get customMeal => _customMeal ?? '';
  bool hasCustomMeal() => _customMeal != null && _customMeal!.isNotEmpty;

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
    _sideRefs = getDataList(snapshotData['side_refs']);
    _dessertRefs = getDataList(snapshotData['dessert_refs']);
    _drinkType = snapshotData['drink_type'] is DrinkType
        ? snapshotData['drink_type']
        : deserializeEnum<DrinkType>(snapshotData['drink_type']);
    _drinkCustom = snapshotData['drink_custom'] as String?;
    _isLeftoverEntree = snapshotData['is_leftover_entree'] as bool?;
    _isLeftoverSide = snapshotData['is_leftover_side'] as bool?;
    _isLeftoverDessert = snapshotData['is_leftover_dessert'] as bool?;
    _isLeftoverSnack = snapshotData['is_leftover_snack'] as bool?;
    _customMeal = snapshotData['custom_meal'] as String?;
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
  DrinkType? drinkType,
  String? drinkCustom,
  bool? isLeftoverEntree,
  bool? isLeftoverSide,
  bool? isLeftoverDessert,
  bool? isLeftoverSnack,
  String? customMeal,
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
      'drink_type': drinkType,
      'drink_custom': drinkCustom,
      'is_leftover_entree': isLeftoverEntree,
      'is_leftover_side': isLeftoverSide,
      'is_leftover_dessert': isLeftoverDessert,
      'is_leftover_snack': isLeftoverSnack,
      'custom_meal': customMeal,
    }.withoutNulls,
  );

  return firestoreData;
}

class MealPlanRecordDocumentEquality implements Equality<MealPlanRecord> {
  const MealPlanRecordDocumentEquality();

  @override
  bool equals(MealPlanRecord? e1, MealPlanRecord? e2) {
    const listEquality = ListEquality();
    return e1?.date == e2?.date &&
        e1?.mealId == e2?.mealId &&
        e1?.typ == e2?.typ &&
        e1?.userRef == e2?.userRef &&
        e1?.userFirebasemeal == e2?.userFirebasemeal &&
        e1?.mealComboRef == e2?.mealComboRef &&
        e1?.notes == e2?.notes &&
        listEquality.equals(e1?.sideRefs, e2?.sideRefs) &&
        listEquality.equals(e1?.dessertRefs, e2?.dessertRefs) &&
        e1?.drinkType == e2?.drinkType &&
        e1?.drinkCustom == e2?.drinkCustom &&
        e1?.isLeftoverEntree == e2?.isLeftoverEntree &&
        e1?.isLeftoverSide == e2?.isLeftoverSide &&
        e1?.isLeftoverDessert == e2?.isLeftoverDessert &&
        e1?.isLeftoverSnack == e2?.isLeftoverSnack &&
        e1?.customMeal == e2?.customMeal;
  }

  @override
  int hash(MealPlanRecord? e) => const ListEquality()
      .hash([e?.date, e?.mealId, e?.typ, e?.userRef, e?.userFirebasemeal, e?.mealComboRef, e?.notes, e?.sideRefs, e?.dessertRefs, e?.drinkType, e?.drinkCustom, e?.isLeftoverEntree, e?.isLeftoverSide, e?.isLeftoverDessert, e?.isLeftoverSnack, e?.customMeal]);

  @override
  bool isValidKey(Object? o) => o is MealPlanRecord;
}
