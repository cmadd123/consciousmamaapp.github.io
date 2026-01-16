// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DataStruct extends FFFirebaseStruct {
  DataStruct({
    String? id,
    String? object,
    DeltaStruct? delta,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _object = object,
        _delta = delta,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "object" field.
  String? _object;
  String get object => _object ?? '';
  set object(String? val) => _object = val;

  bool hasObject() => _object != null;

  // "delta" field.
  DeltaStruct? _delta;
  DeltaStruct get delta => _delta ?? DeltaStruct();
  set delta(DeltaStruct? val) => _delta = val;

  void updateDelta(Function(DeltaStruct) updateFn) {
    updateFn(_delta ??= DeltaStruct());
  }

  bool hasDelta() => _delta != null;

  static DataStruct fromMap(Map<String, dynamic> data) => DataStruct(
        id: data['id'] as String?,
        object: data['object'] as String?,
        delta: data['delta'] is DeltaStruct
            ? data['delta']
            : DeltaStruct.maybeFromMap(data['delta']),
      );

  static DataStruct? maybeFromMap(dynamic data) =>
      data is Map ? DataStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'object': _object,
        'delta': _delta?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'object': serializeParam(
          _object,
          ParamType.String,
        ),
        'delta': serializeParam(
          _delta,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static DataStruct fromSerializableMap(Map<String, dynamic> data) =>
      DataStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        object: deserializeParam(
          data['object'],
          ParamType.String,
          false,
        ),
        delta: deserializeStructParam(
          data['delta'],
          ParamType.DataStruct,
          false,
          structBuilder: DeltaStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'DataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DataStruct &&
        id == other.id &&
        object == other.object &&
        delta == other.delta;
  }

  @override
  int get hashCode => const ListEquality().hash([id, object, delta]);
}

DataStruct createDataStruct({
  String? id,
  String? object,
  DeltaStruct? delta,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    DataStruct(
      id: id,
      object: object,
      delta: delta ?? (clearUnsetFields ? DeltaStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

DataStruct? updateDataStruct(
  DataStruct? data, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    data
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDataStructData(
  Map<String, dynamic> firestoreData,
  DataStruct? data,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (data == null) {
    return;
  }
  if (data.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue && data.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final dataData = getDataFirestoreData(data, forFieldValue);
  final nestedData = dataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = data.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDataFirestoreData(
  DataStruct? data, [
  bool forFieldValue = false,
]) {
  if (data == null) {
    return {};
  }
  final firestoreData = mapToFirestore(data.toMap());

  // Handle nested data for "delta" field.
  addDeltaStructData(
    firestoreData,
    data.hasDelta() ? data.delta : null,
    'delta',
    forFieldValue,
  );

  // Add any Firestore field values
  data.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDataListFirestoreData(
  List<DataStruct>? datas,
) =>
    datas?.map((e) => getDataFirestoreData(e, true)).toList() ?? [];
