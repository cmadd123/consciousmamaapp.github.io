// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsStruct extends FFFirebaseStruct {
  UsStruct({
    String? amount,
    String? unitShort,
    String? unitLong,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _amount = amount,
        _unitShort = unitShort,
        _unitLong = unitLong,
        super(firestoreUtilData);

  // "amount" field.
  String? _amount;
  String get amount => _amount ?? '';
  set amount(String? val) => _amount = val;

  bool hasAmount() => _amount != null;

  // "unitShort" field.
  String? _unitShort;
  String get unitShort => _unitShort ?? '';
  set unitShort(String? val) => _unitShort = val;

  bool hasUnitShort() => _unitShort != null;

  // "unitLong" field.
  String? _unitLong;
  String get unitLong => _unitLong ?? '';
  set unitLong(String? val) => _unitLong = val;

  bool hasUnitLong() => _unitLong != null;

  static UsStruct fromMap(Map<String, dynamic> data) => UsStruct(
        amount: data['amount'] as String?,
        unitShort: data['unitShort'] as String?,
        unitLong: data['unitLong'] as String?,
      );

  static UsStruct? maybeFromMap(dynamic data) =>
      data is Map ? UsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'amount': _amount,
        'unitShort': _unitShort,
        'unitLong': _unitLong,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'amount': serializeParam(
          _amount,
          ParamType.String,
        ),
        'unitShort': serializeParam(
          _unitShort,
          ParamType.String,
        ),
        'unitLong': serializeParam(
          _unitLong,
          ParamType.String,
        ),
      }.withoutNulls;

  static UsStruct fromSerializableMap(Map<String, dynamic> data) => UsStruct(
        amount: deserializeParam(
          data['amount'],
          ParamType.String,
          false,
        ),
        unitShort: deserializeParam(
          data['unitShort'],
          ParamType.String,
          false,
        ),
        unitLong: deserializeParam(
          data['unitLong'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UsStruct &&
        amount == other.amount &&
        unitShort == other.unitShort &&
        unitLong == other.unitLong;
  }

  @override
  int get hashCode => const ListEquality().hash([amount, unitShort, unitLong]);
}

UsStruct createUsStruct({
  String? amount,
  String? unitShort,
  String? unitLong,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    UsStruct(
      amount: amount,
      unitShort: unitShort,
      unitLong: unitLong,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

UsStruct? updateUsStruct(
  UsStruct? us, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    us
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addUsStructData(
  Map<String, dynamic> firestoreData,
  UsStruct? us,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (us == null) {
    return;
  }
  if (us.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue && us.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final usData = getUsFirestoreData(us, forFieldValue);
  final nestedData = usData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = us.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getUsFirestoreData(
  UsStruct? us, [
  bool forFieldValue = false,
]) {
  if (us == null) {
    return {};
  }
  final firestoreData = mapToFirestore(us.toMap());

  // Add any Firestore field values
  us.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getUsListFirestoreData(
  List<UsStruct>? uss,
) =>
    uss?.map((e) => getUsFirestoreData(e, true)).toList() ?? [];
