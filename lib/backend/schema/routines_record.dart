import 'dart:async';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RoutinesRecord extends FirestoreRecord {
  RoutinesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "emoji" field.
  String? _emoji;
  String get emoji => _emoji ?? '📋';
  bool hasEmoji() => _emoji != null;

  // "steps" field — ordered list of step descriptions.
  List<String>? _steps;
  List<String> get steps => _steps ?? const [];
  bool hasSteps() => _steps != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _emoji = snapshotData['emoji'] as String?;
    _steps = getDataList(snapshotData['steps']);
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('routines');

  static Stream<RoutinesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoutinesRecord.fromSnapshot(s));

  static Future<RoutinesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoutinesRecord.fromSnapshot(s));

  static RoutinesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RoutinesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RoutinesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RoutinesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RoutinesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RoutinesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoutinesRecordData({
  String? name,
  String? emoji,
  List<String>? steps,
  DocumentReference? userRef,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'emoji': emoji,
      'steps': steps,
      'user_ref': userRef,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}
