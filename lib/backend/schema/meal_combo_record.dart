import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// MealComboRecord - A complete meal combination (Entrée + Sides + Drink)
/// This allows users to save and reuse meal combinations for planning
class MealComboRecord extends FirestoreRecord {
  MealComboRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field - Optional name for the combo (e.g., "Taco Tuesday")
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "entree_ref" field - Reference to the entrée recipe (required)
  DocumentReference? _entreeRef;
  DocumentReference? get entreeRef => _entreeRef;
  bool hasEntreeRef() => _entreeRef != null;

  // "side_refs" field - List of references to side recipes (0-2)
  List<DocumentReference>? _sideRefs;
  List<DocumentReference> get sideRefs => _sideRefs ?? const [];
  bool hasSideRefs() => _sideRefs != null;

  // "dessert_refs" field - List of references to dessert recipes (0-2)
  List<DocumentReference>? _dessertRefs;
  List<DocumentReference> get dessertRefs => _dessertRefs ?? const [];
  bool hasDessertRefs() => _dessertRefs != null && _dessertRefs!.isNotEmpty;

  // "drink_type" field - Simple drink selection from enum
  DrinkType? _drinkType;
  DrinkType? get drinkType => _drinkType;
  bool hasDrinkType() => _drinkType != null;

  // "drink_custom" field - Custom drink name if drink_type is Other
  String? _drinkCustom;
  String get drinkCustom => _drinkCustom ?? '';
  bool hasDrinkCustom() => _drinkCustom != null;

  // "rating" field - User rating 1-5 stars (0 = unrated)
  int? _rating;
  int get rating => _rating ?? 0;
  bool hasRating() => _rating != null;

  // "times_used" field - How many times this combo has been used
  int? _timesUsed;
  int get timesUsed => _timesUsed ?? 0;
  bool hasTimesUsed() => _timesUsed != null;

  // "last_used" field - When this combo was last used
  DateTime? _lastUsed;
  DateTime? get lastUsed => _lastUsed;
  bool hasLastUsed() => _lastUsed != null;

  // "is_favorite" field - Quick favorite flag
  bool? _isFavorite;
  bool get isFavorite => _isFavorite ?? false;
  bool hasIsFavorite() => _isFavorite != null;

  // "meal_typ" field - Which meal this is typically for (Breakfast/Lunch/Dinner/Snacks)
  MealTyp? _mealTyp;
  MealTyp? get mealTyp => _mealTyp;
  bool hasMealTyp() => _mealTyp != null;

  // "user_ref" field - Owner of this combo
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "created_time" field
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "day_template_group" field - Groups templates saved together as a "day"
  String? _dayTemplateGroup;
  String get dayTemplateGroup => _dayTemplateGroup ?? '';
  bool hasDayTemplateGroup() => _dayTemplateGroup != null && _dayTemplateGroup!.isNotEmpty;

  // "day_template_name" field - Display name for the saved day (e.g., "Monday", "Taco Night")
  String? _dayTemplateName;
  String get dayTemplateName => _dayTemplateName ?? '';
  bool hasDayTemplateName() => _dayTemplateName != null && _dayTemplateName!.isNotEmpty;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _entreeRef = snapshotData['entree_ref'] as DocumentReference?;
    _sideRefs = getDataList(snapshotData['side_refs']);
    _dessertRefs = getDataList(snapshotData['dessert_refs']);
    _drinkType = snapshotData['drink_type'] is DrinkType
        ? snapshotData['drink_type']
        : deserializeEnum<DrinkType>(snapshotData['drink_type']);
    _drinkCustom = snapshotData['drink_custom'] as String?;
    _rating = castToType<int>(snapshotData['rating']);
    _timesUsed = castToType<int>(snapshotData['times_used']);
    _lastUsed = snapshotData['last_used'] as DateTime?;
    _isFavorite = snapshotData['is_favorite'] as bool?;
    _mealTyp = snapshotData['meal_typ'] is MealTyp
        ? snapshotData['meal_typ']
        : deserializeEnum<MealTyp>(snapshotData['meal_typ']);
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _dayTemplateGroup = snapshotData['day_template_group'] as String?;
    _dayTemplateName = snapshotData['day_template_name'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meal_combo');

  static Stream<MealComboRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MealComboRecord.fromSnapshot(s));

  static Future<MealComboRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MealComboRecord.fromSnapshot(s));

  static MealComboRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MealComboRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MealComboRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MealComboRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MealComboRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MealComboRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMealComboRecordData({
  String? name,
  DocumentReference? entreeRef,
  DrinkType? drinkType,
  String? drinkCustom,
  int? rating,
  int? timesUsed,
  DateTime? lastUsed,
  bool? isFavorite,
  MealTyp? mealTyp,
  DocumentReference? userRef,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'entree_ref': entreeRef,
      'drink_type': drinkType,
      'drink_custom': drinkCustom,
      'rating': rating,
      'times_used': timesUsed,
      'last_used': lastUsed,
      'is_favorite': isFavorite,
      'meal_typ': mealTyp,
      'user_ref': userRef,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class MealComboRecordDocumentEquality implements Equality<MealComboRecord> {
  const MealComboRecordDocumentEquality();

  @override
  bool equals(MealComboRecord? e1, MealComboRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.entreeRef == e2?.entreeRef &&
        listEquality.equals(e1?.sideRefs, e2?.sideRefs) &&
        listEquality.equals(e1?.dessertRefs, e2?.dessertRefs) &&
        e1?.drinkType == e2?.drinkType &&
        e1?.drinkCustom == e2?.drinkCustom &&
        e1?.rating == e2?.rating &&
        e1?.timesUsed == e2?.timesUsed &&
        e1?.lastUsed == e2?.lastUsed &&
        e1?.isFavorite == e2?.isFavorite &&
        e1?.mealTyp == e2?.mealTyp &&
        e1?.userRef == e2?.userRef &&
        e1?.createdTime == e2?.createdTime &&
        e1?.dayTemplateGroup == e2?.dayTemplateGroup &&
        e1?.dayTemplateName == e2?.dayTemplateName;
  }

  @override
  int hash(MealComboRecord? e) => const ListEquality().hash([
        e?.name,
        e?.entreeRef,
        e?.sideRefs,
        e?.dessertRefs,
        e?.drinkType,
        e?.drinkCustom,
        e?.rating,
        e?.timesUsed,
        e?.lastUsed,
        e?.isFavorite,
        e?.mealTyp,
        e?.userRef,
        e?.createdTime,
        e?.dayTemplateGroup,
        e?.dayTemplateName,
      ]);

  @override
  bool isValidKey(Object? o) => o is MealComboRecord;
}
