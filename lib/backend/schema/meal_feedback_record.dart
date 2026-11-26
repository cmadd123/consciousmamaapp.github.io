import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// "How did it go?" feedback on a planned meal — one doc per child per
/// planned meal (or one family-level doc when the family has no children).
///
/// Doc ID is deterministic: `{mealPlanId}_{childId | 'family'}` so a re-rate
/// overwrites instead of duplicating. See MEAL_FEEDBACK.md.
///
/// Privacy: stores the child's AGE IN MONTHS at the time of the meal, never
/// the birthdate. Owner-only access (firestore.rules → meal_feedback).
class MealFeedbackRecord extends FirestoreRecord {
  MealFeedbackRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // Rating values (stored as strings; validated by firestore.rules).
  static const String ratingLoved = 'loved';
  static const String ratingAteSome = 'ate_some';
  static const String ratingRefused = 'refused';
  static const List<String> ratings = [ratingLoved, ratingAteSome, ratingRefused];

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "child_ref" field — null for a family-level rating.
  DocumentReference? _childRef;
  DocumentReference? get childRef => _childRef;
  bool hasChildRef() => _childRef != null;

  // "child_age_months" field — child's age (months) on the plan date.
  int? _childAgeMonths;
  int? get childAgeMonths => _childAgeMonths;
  bool hasChildAgeMonths() => _childAgeMonths != null;

  // "meal_plan_ref" field — the planned meal (meal_plan doc) that was rated.
  DocumentReference? _mealPlanRef;
  DocumentReference? get mealPlanRef => _mealPlanRef;
  bool hasMealPlanRef() => _mealPlanRef != null;

  // "recipe_ref" field — entrée recipe (meal doc), if any.
  DocumentReference? _recipeRef;
  DocumentReference? get recipeRef => _recipeRef;
  bool hasRecipeRef() => _recipeRef != null;

  // "meal_combo_ref" field — meal combo, if the plan used one.
  DocumentReference? _mealComboRef;
  DocumentReference? get mealComboRef => _mealComboRef;
  bool hasMealComboRef() => _mealComboRef != null;

  // "recipe_name" field.
  String? _recipeName;
  String get recipeName => _recipeName ?? '';
  bool hasRecipeName() => _recipeName != null;

  // "meal_type" field (Breakfast / Lunch / Dinner / Snacks).
  MealTyp? _mealType;
  MealTyp? get mealType => _mealType;
  bool hasMealType() => _mealType != null;

  // "tags" field — key recipe tags (meal_typ categories, recipe_type, ...).
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "rating" field — one of [ratings].
  String? _rating;
  String get rating => _rating ?? '';
  bool hasRating() => _rating != null;

  // "make_again" field — optional; absent until the parent answers.
  bool? _makeAgain;
  bool? get makeAgain => _makeAgain;
  bool hasMakeAgain() => _makeAgain != null;

  // "plan_date" field — the date the meal was planned for.
  DateTime? _planDate;
  DateTime? get planDate => _planDate;
  bool hasPlanDate() => _planDate != null;

  // "created_at" field (server timestamp).
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field (server timestamp, set on re-rate).
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _childRef = snapshotData['child_ref'] as DocumentReference?;
    _childAgeMonths = castToType<int>(snapshotData['child_age_months']);
    _mealPlanRef = snapshotData['meal_plan_ref'] as DocumentReference?;
    _recipeRef = snapshotData['recipe_ref'] as DocumentReference?;
    _mealComboRef = snapshotData['meal_combo_ref'] as DocumentReference?;
    _recipeName = snapshotData['recipe_name'] as String?;
    _mealType = snapshotData['meal_type'] is MealTyp
        ? snapshotData['meal_type']
        : deserializeEnum<MealTyp>(snapshotData['meal_type']);
    _tags = getDataList(snapshotData['tags']);
    _rating = snapshotData['rating'] as String?;
    _makeAgain = snapshotData['make_again'] as bool?;
    _planDate = snapshotData['plan_date'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meal_feedback');

  static Stream<MealFeedbackRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MealFeedbackRecord.fromSnapshot(s));

  static Future<MealFeedbackRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MealFeedbackRecord.fromSnapshot(s));

  static MealFeedbackRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MealFeedbackRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MealFeedbackRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MealFeedbackRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MealFeedbackRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MealFeedbackRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

/// Builds the create payload. `created_at` must be added by the caller as
/// `FieldValue.serverTimestamp()` (rules require it to equal request.time).
Map<String, dynamic> createMealFeedbackRecordData({
  DocumentReference? userRef,
  DocumentReference? childRef,
  int? childAgeMonths,
  DocumentReference? mealPlanRef,
  DocumentReference? recipeRef,
  DocumentReference? mealComboRef,
  String? recipeName,
  MealTyp? mealType,
  String? rating,
  bool? makeAgain,
  DateTime? planDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'child_ref': childRef,
      'child_age_months': childAgeMonths,
      'meal_plan_ref': mealPlanRef,
      'recipe_ref': recipeRef,
      'meal_combo_ref': mealComboRef,
      'recipe_name': recipeName,
      'meal_type': mealType,
      'rating': rating,
      'make_again': makeAgain,
      'plan_date': planDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class MealFeedbackRecordDocumentEquality
    implements Equality<MealFeedbackRecord> {
  const MealFeedbackRecordDocumentEquality();

  @override
  bool equals(MealFeedbackRecord? e1, MealFeedbackRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userRef == e2?.userRef &&
        e1?.childRef == e2?.childRef &&
        e1?.childAgeMonths == e2?.childAgeMonths &&
        e1?.mealPlanRef == e2?.mealPlanRef &&
        e1?.recipeRef == e2?.recipeRef &&
        e1?.mealComboRef == e2?.mealComboRef &&
        e1?.recipeName == e2?.recipeName &&
        e1?.mealType == e2?.mealType &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        e1?.rating == e2?.rating &&
        e1?.makeAgain == e2?.makeAgain &&
        e1?.planDate == e2?.planDate &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(MealFeedbackRecord? e) => const ListEquality().hash([
        e?.userRef,
        e?.childRef,
        e?.childAgeMonths,
        e?.mealPlanRef,
        e?.recipeRef,
        e?.mealComboRef,
        e?.recipeName,
        e?.mealType,
        e?.tags,
        e?.rating,
        e?.makeAgain,
        e?.planDate,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is MealFeedbackRecord;
}
