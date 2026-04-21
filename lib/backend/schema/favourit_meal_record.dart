import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FavouritMealRecord extends FirestoreRecord {
  FavouritMealRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "user_ref" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "meal_ref" field.
  DocumentReference? _mealRef;
  DocumentReference? get mealRef => _mealRef;
  bool hasMealRef() => _mealRef != null;

  void _initializeFields() {
    _userRef = snapshotData['user_ref'] as DocumentReference?;
    _mealRef = snapshotData['meal_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('favourit_meal');

  static Stream<FavouritMealRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FavouritMealRecord.fromSnapshot(s));

  static Future<FavouritMealRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FavouritMealRecord.fromSnapshot(s));

  static FavouritMealRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FavouritMealRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FavouritMealRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FavouritMealRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FavouritMealRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FavouritMealRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFavouritMealRecordData({
  DocumentReference? userRef,
  DocumentReference? mealRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_ref': userRef,
      'meal_ref': mealRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class FavouritMealRecordDocumentEquality
    implements Equality<FavouritMealRecord> {
  const FavouritMealRecordDocumentEquality();

  @override
  bool equals(FavouritMealRecord? e1, FavouritMealRecord? e2) {
    return e1?.userRef == e2?.userRef && e1?.mealRef == e2?.mealRef;
  }

  @override
  int hash(FavouritMealRecord? e) =>
      const ListEquality().hash([e?.userRef, e?.mealRef]);

  @override
  bool isValidKey(Object? o) => o is FavouritMealRecord;
}
