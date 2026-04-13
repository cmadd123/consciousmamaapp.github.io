import 'dart:async';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CreatorContentRecord extends FirestoreRecord {
  CreatorContentRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "creator_ref" field — links to the creator document.
  DocumentReference? _creatorRef;
  DocumentReference? get creatorRef => _creatorRef;
  bool hasCreatorRef() => _creatorRef != null;

  // "creator_code" field — denormalized for easy querying.
  String? _creatorCode;
  String get creatorCode => _creatorCode ?? '';
  bool hasCreatorCode() => _creatorCode != null;

  // "type" field — "meal_plan", "routine", "guide", "course" etc.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "image_url" field — cover image.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "data" field — flexible JSON for content data.
  // For meal_plan: { "monday": { "breakfast": {...}, "lunch": {...}, ... }, ... }
  Map<String, dynamic>? _data;
  Map<String, dynamic> get data => _data ?? {};
  bool hasData() => _data != null;

  // "is_active" field — whether this content is currently published.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "is_free" field — whether this content is free or paid.
  bool? _isFree;
  bool get isFree => _isFree ?? true;
  bool hasIsFree() => _isFree != null;

  // "price" field — price in cents if paid content.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;

  // "published_at" field.
  DateTime? _publishedAt;
  DateTime? get publishedAt => _publishedAt;
  bool hasPublishedAt() => _publishedAt != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "week_of" field — for weekly meal plans, the Monday date of the week.
  DateTime? _weekOf;
  DateTime? get weekOf => _weekOf;
  bool hasWeekOf() => _weekOf != null;

  // "download_count" field.
  int? _downloadCount;
  int get downloadCount => _downloadCount ?? 0;
  bool hasDownloadCount() => _downloadCount != null;

  // "creator_name" field — denormalized for display without extra read.
  String? _creatorName;
  String get creatorName => _creatorName ?? '';
  bool hasCreatorName() => _creatorName != null;

  void _initializeFields() {
    _creatorRef = snapshotData['creator_ref'] as DocumentReference?;
    _creatorCode = snapshotData['creator_code'] as String?;
    _type = snapshotData['type'] as String?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _imageUrl = snapshotData['image_url'] as String?;
    _data = snapshotData['data'] as Map<String, dynamic>?;
    _isActive = snapshotData['is_active'] as bool?;
    _isFree = snapshotData['is_free'] as bool?;
    _price = castToType<int>(snapshotData['price']);
    _publishedAt = snapshotData['published_at'] as DateTime?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _weekOf = snapshotData['week_of'] as DateTime?;
    _downloadCount = castToType<int>(snapshotData['download_count']);
    _creatorName = snapshotData['creator_name'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('creator_content');

  static Stream<CreatorContentRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CreatorContentRecord.fromSnapshot(s));

  static Future<CreatorContentRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CreatorContentRecord.fromSnapshot(s));

  static CreatorContentRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CreatorContentRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CreatorContentRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CreatorContentRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CreatorContentRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CreatorContentRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCreatorContentRecordData({
  DocumentReference? creatorRef,
  String? creatorCode,
  String? type,
  String? title,
  String? description,
  String? imageUrl,
  Map<String, dynamic>? data,
  bool? isActive,
  bool? isFree,
  int? price,
  DateTime? publishedAt,
  DateTime? createdAt,
  DateTime? weekOf,
  int? downloadCount,
  String? creatorName,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'creator_ref': creatorRef,
      'creator_code': creatorCode,
      'type': type,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'data': data,
      'is_active': isActive,
      'is_free': isFree,
      'price': price,
      'published_at': publishedAt,
      'created_at': createdAt,
      'week_of': weekOf,
      'download_count': downloadCount,
      'creator_name': creatorName,
    }.withoutNulls,
  );

  return firestoreData;
}
