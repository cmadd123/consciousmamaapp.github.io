import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FavActivityRecord extends FirestoreRecord {
  FavActivityRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "activity_ref" field.
  DocumentReference? _activityRef;
  DocumentReference? get activityRef => _activityRef;
  bool hasActivityRef() => _activityRef != null;

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  void _initializeFields() {
    _activityRef = snapshotData['activity_ref'] as DocumentReference?;
    _userRef = snapshotData['user_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('fav_activity');

  static Stream<FavActivityRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FavActivityRecord.fromSnapshot(s));

  static Future<FavActivityRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FavActivityRecord.fromSnapshot(s));

  static FavActivityRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FavActivityRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FavActivityRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FavActivityRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FavActivityRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FavActivityRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFavActivityRecordData({
  DocumentReference? activityRef,
  DocumentReference? userRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'activity_ref': activityRef,
      'user_ref': userRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class FavActivityRecordDocumentEquality implements Equality<FavActivityRecord> {
  const FavActivityRecordDocumentEquality();

  @override
  bool equals(FavActivityRecord? e1, FavActivityRecord? e2) {
    return e1?.activityRef == e2?.activityRef && e1?.userRef == e2?.userRef;
  }

  @override
  int hash(FavActivityRecord? e) =>
      const ListEquality().hash([e?.activityRef, e?.userRef]);

  @override
  bool isValidKey(Object? o) => o is FavActivityRecord;
}
