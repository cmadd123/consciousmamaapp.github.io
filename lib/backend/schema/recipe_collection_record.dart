import 'dart:async';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A creator-curated, named group of recipes (e.g. "5 Crockpot Dinners").
/// Recipes are stored as embedded snapshots so followers can import them as
/// plain cookbook recipes without reading the creator's private meal docs.
class RecipeCollectionRecord extends FirestoreRecord {
  RecipeCollectionRecord._(
    super.reference,
    super.data,
  ) {
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

  // "creator_ref" field.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  // "creator_code" field — denormalized so followers can query by code.
  String? _creatorCode;
  String get creatorCode => _creatorCode ?? '';
  bool hasCreatorCode() => _creatorCode != null;

  // "cover_image_url" field.
  String? _coverImageUrl;
  String get coverImageUrl => _coverImageUrl ?? '';
  bool hasCoverImageUrl() => _coverImageUrl != null;

  // "recipes" field — list of embedded recipe snapshot maps. Each entry:
  // {name, image_url, ingredients[], instructions[], estimated_cost,
  //  source_url, recipe_type, meal_type}.
  List<dynamic>? _recipes;
  List<dynamic> get recipes => _recipes ?? const [];
  bool hasRecipes() => _recipes != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "download_count" field.
  int? _downloadCount;
  int get downloadCount => _downloadCount ?? 0;
  bool hasDownloadCount() => _downloadCount != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
    _creatorCode = snapshotData['creator_code'] as String?;
    _coverImageUrl = snapshotData['cover_image_url'] as String?;
    _recipes = (snapshotData['recipes'] as List?)?.toList();
    _isActive = snapshotData['is_active'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _downloadCount = castToType<int>(snapshotData['download_count']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('recipe_collections');

  static Stream<RecipeCollectionRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RecipeCollectionRecord.fromSnapshot(s));

  static Future<RecipeCollectionRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RecipeCollectionRecord.fromSnapshot(s));

  static RecipeCollectionRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RecipeCollectionRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RecipeCollectionRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RecipeCollectionRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RecipeCollectionRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RecipeCollectionRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRecipeCollectionRecordData({
  String? name,
  String? description,
  DocumentReference? creatorRef,
  String? creatorCode,
  String? coverImageUrl,
  bool? isActive,
  DateTime? createdAt,
  int? downloadCount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'creator_ref': creatorRef,
      'creator_code': creatorCode,
      'cover_image_url': coverImageUrl,
      'is_active': isActive,
      'created_at': createdAt,
      'download_count': downloadCount,
    }.withoutNulls,
  );

  return firestoreData;
}
