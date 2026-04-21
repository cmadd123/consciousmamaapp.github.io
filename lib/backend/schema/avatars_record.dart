import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AvatarsRecord extends FirestoreRecord {
  AvatarsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "photoUrl" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  void _initializeFields() {
    _photoUrl = snapshotData['photoUrl'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('avatars');

  static Stream<AvatarsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AvatarsRecord.fromSnapshot(s));

  static Future<AvatarsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AvatarsRecord.fromSnapshot(s));

  static AvatarsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AvatarsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AvatarsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AvatarsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AvatarsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AvatarsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAvatarsRecordData({
  String? photoUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'photoUrl': photoUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class AvatarsRecordDocumentEquality implements Equality<AvatarsRecord> {
  const AvatarsRecordDocumentEquality();

  @override
  bool equals(AvatarsRecord? e1, AvatarsRecord? e2) {
    return e1?.photoUrl == e2?.photoUrl;
  }

  @override
  int hash(AvatarsRecord? e) => const ListEquality().hash([e?.photoUrl]);

  @override
  bool isValidKey(Object? o) => o is AvatarsRecord;
}
