import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChildernRecord extends FirestoreRecord {
  ChildernRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "birth_day" field.
  DateTime? _birthDay;
  DateTime? get birthDay => _birthDay;
  bool hasBirthDay() => _birthDay != null;

  // "selectedColor" field.
  Color? _selectedColor;
  Color? get selectedColor => _selectedColor;
  bool hasSelectedColor() => _selectedColor != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "selectedAvatar" field.
  String? _selectedAvatar;
  String get selectedAvatar => _selectedAvatar ?? '';
  bool hasSelectedAvatar() => _selectedAvatar != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  bool hasId() => _id != null;

  // "avatar" field.
  String? _avatar;
  String get avatar => _avatar ?? '';
  bool hasAvatar() => _avatar != null;

  // "gender" field.
  String? _gender;
  String get gender => _gender ?? '';
  bool hasGender() => _gender != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _birthDay = snapshotData['birth_day'] as DateTime?;
    _selectedColor = getSchemaColor(snapshotData['selectedColor']);
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _selectedAvatar = snapshotData['selectedAvatar'] as String?;
    _id = snapshotData['id'] as String?;
    _avatar = snapshotData['avatar'] as String?;
    _gender = snapshotData['gender'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('childern');

  static Stream<ChildernRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChildernRecord.fromSnapshot(s));

  static Future<ChildernRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChildernRecord.fromSnapshot(s));

  static ChildernRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ChildernRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChildernRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChildernRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChildernRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChildernRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChildernRecordData({
  String? name,
  DateTime? birthDay,
  Color? selectedColor,
  DocumentReference? userRef,
  String? selectedAvatar,
  String? id,
  String? avatar,
  String? gender,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'birth_day': birthDay,
      'selectedColor': selectedColor,
      'userRef': userRef,
      'selectedAvatar': selectedAvatar,
      'id': id,
      'avatar': avatar,
      'gender': gender,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChildernRecordDocumentEquality implements Equality<ChildernRecord> {
  const ChildernRecordDocumentEquality();

  @override
  bool equals(ChildernRecord? e1, ChildernRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.birthDay == e2?.birthDay &&
        e1?.selectedColor == e2?.selectedColor &&
        e1?.userRef == e2?.userRef &&
        e1?.selectedAvatar == e2?.selectedAvatar &&
        e1?.id == e2?.id &&
        e1?.avatar == e2?.avatar &&
        e1?.gender == e2?.gender;
  }

  @override
  int hash(ChildernRecord? e) => const ListEquality().hash([
        e?.name,
        e?.birthDay,
        e?.selectedColor,
        e?.userRef,
        e?.selectedAvatar,
        e?.id,
        e?.avatar,
        e?.gender
      ]);

  @override
  bool isValidKey(Object? o) => o is ChildernRecord;
}
