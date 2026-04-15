import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MealRecord extends FirestoreRecord {
  MealRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "recipe_name" field.
  String? _recipeName;
  String get recipeName => _recipeName ?? '';
  bool hasRecipeName() => _recipeName != null;

  // "ingredients" field.
  List<String>? _ingredients;
  List<String> get ingredients => _ingredients ?? const [];
  bool hasIngredients() => _ingredients != null;

  // "CookingInstructions" field.
  List<String>? _cookingInstructions;
  List<String> get cookingInstructions => _cookingInstructions ?? const [];
  bool hasCookingInstructions() => _cookingInstructions != null;

  // "cost" field.
  double? _cost;
  double get cost => _cost ?? 0.0;
  bool hasCost() => _cost != null;

  // "main_or_sides" field.
  String? _mainOrSides;
  String get mainOrSides => _mainOrSides ?? '';
  bool hasMainOrSides() => _mainOrSides != null;

  // "meal_typ" field.
  String? _mealTyp;
  String get mealTyp => _mealTyp ?? '';
  bool hasMealTyp() => _mealTyp != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "prepare_time" field.
  double? _prepareTime;
  double get prepareTime => _prepareTime ?? 0.0;
  bool hasPrepareTime() => _prepareTime != null;

  // "cooking_time" field.
  double? _cookingTime;
  double get cookingTime => _cookingTime ?? 0.0;
  bool hasCookingTime() => _cookingTime != null;

  // "is_curated" field.
  bool? _isCurated;
  bool get isCurated => _isCurated ?? false;
  bool hasIsCurated() => _isCurated != null;

  // "source_url" field.
  String? _sourceUrl;
  String get sourceUrl => _sourceUrl ?? '';
  bool hasSourceUrl() => _sourceUrl != null;

  // "rating" field - User rating 1-5 stars (0 = unrated)
  int? _rating;
  int get rating => _rating ?? 0;
  bool hasRating() => _rating != null;

  // "recipe_type" field - Entree, Side, or Drink
  RecipeType? _recipeType;
  RecipeType? get recipeType => _recipeType;
  bool hasRecipeType() => _recipeType != null;

  // "shared_with_followers" field - Whether this recipe is in the creator's Shared Library
  bool? _sharedWithFollowers;
  bool get sharedWithFollowers => _sharedWithFollowers ?? false;
  bool hasSharedWithFollowers() => _sharedWithFollowers != null;

  // "estimated_cost" field - AI-estimated grocery cost in dollars
  double? _estimatedCost;
  double get estimatedCost => _estimatedCost ?? 0.0;
  bool hasEstimatedCost() => _estimatedCost != null && _estimatedCost! > 0;

  // "is_imported" field - Whether this recipe was imported from an external URL
  bool? _isImported;
  bool get isImported => _isImported ?? false;
  bool hasIsImported() => _isImported != null;

  // "source_domain" field - Display-friendly domain name (e.g., "allrecipes.com")
  String? _sourceDomain;
  String get sourceDomain => _sourceDomain ?? '';
  bool hasSourceDomain() => _sourceDomain != null;

  void _initializeFields() {
    _imageUrl = snapshotData['image_url'] as String?;
    _recipeName = snapshotData['recipe_name'] as String?;
    _ingredients = getDataList(snapshotData['ingredients']);
    _cookingInstructions = getDataList(snapshotData['CookingInstructions']);
    _cost = castToType<double>(snapshotData['cost']);
    _mainOrSides = snapshotData['main_or_sides'] as String?;
    _mealTyp = snapshotData['meal_typ'] as String?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _prepareTime = castToType<double>(snapshotData['prepare_time']);
    _cookingTime = castToType<double>(snapshotData['cooking_time']);
    _isCurated = snapshotData['is_curated'] as bool?;
    _sourceUrl = snapshotData['source_url'] as String?;
    _rating = castToType<int>(snapshotData['rating']);
    _recipeType = snapshotData['recipe_type'] is RecipeType
        ? snapshotData['recipe_type']
        : deserializeEnum<RecipeType>(snapshotData['recipe_type']);
    _sharedWithFollowers = snapshotData['shared_with_followers'] as bool?;
    _estimatedCost = castToType<double>(snapshotData['estimated_cost']);
    _isImported = snapshotData['is_imported'] as bool?;
    _sourceDomain = snapshotData['source_domain'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('meal');

  static Stream<MealRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MealRecord.fromSnapshot(s));

  static Future<MealRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MealRecord.fromSnapshot(s));

  static MealRecord fromSnapshot(DocumentSnapshot snapshot) => MealRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MealRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MealRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MealRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MealRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMealRecordData({
  String? imageUrl,
  String? recipeName,
  double? cost,
  String? mainOrSides,
  String? mealTyp,
  DocumentReference? userRef,
  double? prepareTime,
  double? cookingTime,
  bool? isCurated,
  String? sourceUrl,
  int? rating,
  RecipeType? recipeType,
  bool? sharedWithFollowers,
  double? estimatedCost,
  bool? isImported,
  String? sourceDomain,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'image_url': imageUrl,
      'recipe_name': recipeName,
      'cost': cost,
      'main_or_sides': mainOrSides,
      'meal_typ': mealTyp,
      'user_ref': userRef,
      'prepare_time': prepareTime,
      'cooking_time': cookingTime,
      'is_curated': isCurated,
      'source_url': sourceUrl,
      'rating': rating,
      'recipe_type': recipeType,
      'shared_with_followers': sharedWithFollowers,
      'estimated_cost': estimatedCost,
      'is_imported': isImported,
      'source_domain': sourceDomain,
    }.withoutNulls,
  );

  return firestoreData;
}

class MealRecordDocumentEquality implements Equality<MealRecord> {
  const MealRecordDocumentEquality();

  @override
  bool equals(MealRecord? e1, MealRecord? e2) {
    const listEquality = ListEquality();
    return e1?.imageUrl == e2?.imageUrl &&
        e1?.recipeName == e2?.recipeName &&
        listEquality.equals(e1?.ingredients, e2?.ingredients) &&
        listEquality.equals(e1?.cookingInstructions, e2?.cookingInstructions) &&
        e1?.cost == e2?.cost &&
        e1?.mainOrSides == e2?.mainOrSides &&
        e1?.mealTyp == e2?.mealTyp &&
        e1?.userRef == e2?.userRef &&
        e1?.prepareTime == e2?.prepareTime &&
        e1?.cookingTime == e2?.cookingTime &&
        e1?.isCurated == e2?.isCurated &&
        e1?.sourceUrl == e2?.sourceUrl &&
        e1?.rating == e2?.rating &&
        e1?.recipeType == e2?.recipeType;
  }

  @override
  int hash(MealRecord? e) => const ListEquality().hash([
        e?.imageUrl,
        e?.recipeName,
        e?.ingredients,
        e?.cookingInstructions,
        e?.cost,
        e?.mainOrSides,
        e?.mealTyp,
        e?.userRef,
        e?.prepareTime,
        e?.cookingTime,
        e?.isCurated,
        e?.sourceUrl,
        e?.rating,
        e?.recipeType,
      ]);

  @override
  bool isValidKey(Object? o) => o is MealRecord;
}
