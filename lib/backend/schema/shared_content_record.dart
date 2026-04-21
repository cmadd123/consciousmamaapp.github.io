import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SharedContentRecord extends FirestoreRecord {
  SharedContentRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "share_code" field - unique short code for sharing (e.g., "abc123")
  String? _shareCode;
  String get shareCode => _shareCode ?? '';
  bool hasShareCode() => _shareCode != null;

  // "content_type" field - what type of content is being shared
  SharedContentType? _contentType;
  SharedContentType? get contentType => _contentType;
  bool hasContentType() => _contentType != null;

  // "shared_by_user" field - reference to user who shared
  DocumentReference? _sharedByUser;
  DocumentReference? get sharedByUser => _sharedByUser;
  bool hasSharedByUser() => _sharedByUser != null;

  // "shared_by_name" field - display name of user who shared
  String? _sharedByName;
  String get sharedByName => _sharedByName ?? 'A MomRise User';
  bool hasSharedByName() => _sharedByName != null;

  // "title" field - title of the shared content
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field - optional description
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "preview_image" field - optional preview image URL
  String? _previewImage;
  String get previewImage => _previewImage ?? '';
  bool hasPreviewImage() => _previewImage != null;

  // "content_data" field - JSON map of the actual content to be imported
  Map<String, dynamic>? _contentData;
  Map<String, dynamic> get contentData => _contentData ?? {};
  bool hasContentData() => _contentData != null;

  // "created_at" field - when the share was created
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "expires_at" field - optional expiration date
  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;
  bool hasExpiresAt() => _expiresAt != null;

  // "view_count" field - how many times this has been viewed
  int? _viewCount;
  int get viewCount => _viewCount ?? 0;
  bool hasViewCount() => _viewCount != null;

  // "import_count" field - how many times this has been imported
  int? _importCount;
  int get importCount => _importCount ?? 0;
  bool hasImportCount() => _importCount != null;

  // "is_active" field - whether the share is still active
  bool? _isActive;
  bool get isActive => _isActive ?? true;
  bool hasIsActive() => _isActive != null;

  void _initializeFields() {
    _shareCode = snapshotData['share_code'] as String?;
    _contentType = snapshotData['content_type'] is SharedContentType
        ? snapshotData['content_type']
        : deserializeEnum<SharedContentType>(snapshotData['content_type']);
    _sharedByUser = snapshotData['shared_by_user'] as DocumentReference?;
    _sharedByName = snapshotData['shared_by_name'] as String?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _previewImage = snapshotData['preview_image'] as String?;
    _contentData = snapshotData['content_data'] as Map<String, dynamic>?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _expiresAt = snapshotData['expires_at'] as DateTime?;
    _viewCount = castToType<int>(snapshotData['view_count']);
    _importCount = castToType<int>(snapshotData['import_count']);
    _isActive = snapshotData['is_active'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('shared_content');

  static Stream<SharedContentRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SharedContentRecord.fromSnapshot(s));

  static Future<SharedContentRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SharedContentRecord.fromSnapshot(s));

  static SharedContentRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SharedContentRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SharedContentRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SharedContentRecord._(reference, mapFromFirestore(data));

  /// Find shared content by share code
  static Future<SharedContentRecord?> getByShareCode(String shareCode) async {
    final query = await collection
        .where('share_code', isEqualTo: shareCode)
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return SharedContentRecord.fromSnapshot(query.docs.first);
  }

  @override
  String toString() =>
      'SharedContentRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SharedContentRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSharedContentRecordData({
  String? shareCode,
  SharedContentType? contentType,
  DocumentReference? sharedByUser,
  String? sharedByName,
  String? title,
  String? description,
  String? previewImage,
  Map<String, dynamic>? contentData,
  DateTime? createdAt,
  DateTime? expiresAt,
  int? viewCount,
  int? importCount,
  bool? isActive,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'share_code': shareCode,
      'content_type': contentType,
      'shared_by_user': sharedByUser,
      'shared_by_name': sharedByName,
      'title': title,
      'description': description,
      'preview_image': previewImage,
      'content_data': contentData,
      'created_at': createdAt,
      'expires_at': expiresAt,
      'view_count': viewCount,
      'import_count': importCount,
      'is_active': isActive,
    }.withoutNulls,
  );

  return firestoreData;
}

class SharedContentRecordDocumentEquality
    implements Equality<SharedContentRecord> {
  const SharedContentRecordDocumentEquality();

  @override
  bool equals(SharedContentRecord? e1, SharedContentRecord? e2) {
    const mapEquality = MapEquality();
    return e1?.shareCode == e2?.shareCode &&
        e1?.contentType == e2?.contentType &&
        e1?.sharedByUser == e2?.sharedByUser &&
        e1?.sharedByName == e2?.sharedByName &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.previewImage == e2?.previewImage &&
        mapEquality.equals(e1?.contentData, e2?.contentData) &&
        e1?.createdAt == e2?.createdAt &&
        e1?.expiresAt == e2?.expiresAt &&
        e1?.viewCount == e2?.viewCount &&
        e1?.importCount == e2?.importCount &&
        e1?.isActive == e2?.isActive;
  }

  @override
  int hash(SharedContentRecord? e) => const ListEquality().hash([
        e?.shareCode,
        e?.contentType,
        e?.sharedByUser,
        e?.sharedByName,
        e?.title,
        e?.description,
        e?.previewImage,
        e?.contentData,
        e?.createdAt,
        e?.expiresAt,
        e?.viewCount,
        e?.importCount,
        e?.isActive,
      ]);

  @override
  bool isValidKey(Object? o) => o is SharedContentRecord;
}
