import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ActivitiesRecord extends FirestoreRecord {
  ActivitiesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "age" field.
  double? _age;
  double get age => _age ?? 0.0;
  bool hasAge() => _age != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "materials" field.
  String? _materials;
  String get materials => _materials ?? '';
  bool hasMaterials() => _materials != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _age = castToType<double>(snapshotData['age']);
    _category = snapshotData['category'] as String?;
    _description = snapshotData['description'] as String?;
    _duration = castToType<int>(snapshotData['duration']);
    _type = snapshotData['type'] as String?;
    _materials = snapshotData['materials'] as String?;
    _location = snapshotData['location'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('activities');

  static Stream<ActivitiesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ActivitiesRecord.fromSnapshot(s));

  static Future<ActivitiesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ActivitiesRecord.fromSnapshot(s));

  static ActivitiesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActivitiesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActivitiesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActivitiesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActivitiesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActivitiesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActivitiesRecordData({
  String? title,
  double? age,
  String? category,
  String? description,
  int? duration,
  String? type,
  String? materials,
  String? location,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'age': age,
      'category': category,
      'description': description,
      'duration': duration,
      'type': type,
      'materials': materials,
      'location': location,
    }.withoutNulls,
  );

  return firestoreData;
}

class ActivitiesRecordDocumentEquality implements Equality<ActivitiesRecord> {
  const ActivitiesRecordDocumentEquality();

  @override
  bool equals(ActivitiesRecord? e1, ActivitiesRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.age == e2?.age &&
        e1?.category == e2?.category &&
        e1?.description == e2?.description &&
        e1?.duration == e2?.duration &&
        e1?.type == e2?.type &&
        e1?.materials == e2?.materials &&
        e1?.location == e2?.location;
  }

  @override
  int hash(ActivitiesRecord? e) => const ListEquality().hash([
        e?.title,
        e?.age,
        e?.category,
        e?.description,
        e?.duration,
        e?.type,
        e?.materials,
        e?.location
      ]);

  @override
  bool isValidKey(Object? o) => o is ActivitiesRecord;
}
