import 'dart:async';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppContentRecord extends FirestoreRecord {
  AppContentRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "author" field.
  String? _author;
  String get author => _author ?? '';
  bool hasAuthor() => _author != null;

  // "body" field — the full content text.
  String? _body;
  String get body => _body ?? '';
  bool hasBody() => _body != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "emoji" field.
  String? _emoji;
  String get emoji => _emoji ?? '📄';
  bool hasEmoji() => _emoji != null;

  // "is_published" field.
  bool? _isPublished;
  bool get isPublished => _isPublished ?? false;
  bool hasIsPublished() => _isPublished != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "read_time_minutes" field — estimated read time.
  int? _readTimeMinutes;
  int get readTimeMinutes => _readTimeMinutes ?? 0;
  bool hasReadTimeMinutes() => _readTimeMinutes != null;

  // "pdf_url" field — Firebase Storage URL for uploaded PDFs.
  String? _pdfUrl;
  String get pdfUrl => _pdfUrl ?? '';
  bool hasPdfUrl() => _pdfUrl != null && _pdfUrl!.isNotEmpty;

  // "content_type" field — "text" or "pdf"
  String? _contentType;
  String get contentType => _contentType ?? 'text';

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _author = snapshotData['author'] as String?;
    _body = snapshotData['body'] as String?;
    _category = snapshotData['category'] as String?;
    _emoji = snapshotData['emoji'] as String?;
    _isPublished = snapshotData['is_published'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _readTimeMinutes = castToType<int>(snapshotData['read_time_minutes']);
    _pdfUrl = snapshotData['pdf_url'] as String?;
    _contentType = snapshotData['content_type'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('app_content');

  static Stream<AppContentRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AppContentRecord.fromSnapshot(s));

  static Future<AppContentRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AppContentRecord.fromSnapshot(s));

  static AppContentRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AppContentRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AppContentRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AppContentRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AppContentRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AppContentRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAppContentRecordData({
  String? title,
  String? author,
  String? body,
  String? category,
  String? emoji,
  bool? isPublished,
  DateTime? createdAt,
  int? readTimeMinutes,
  String? pdfUrl,
  String? contentType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'author': author,
      'body': body,
      'category': category,
      'emoji': emoji,
      'is_published': isPublished,
      'created_at': createdAt,
      'read_time_minutes': readTimeMinutes,
      'pdf_url': pdfUrl,
      'content_type': contentType,
    }.withoutNulls,
  );

  return firestoreData;
}
