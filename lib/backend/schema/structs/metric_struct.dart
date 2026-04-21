// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class MetricStruct extends FFFirebaseStruct {
  MetricStruct({
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

  static MetricStruct fromMap(Map<String, dynamic> data) => MetricStruct(
        amount: data['amount'] as String?,
        unitShort: data['unitShort'] as String?,
        unitLong: data['unitLong'] as String?,
      );

  static MetricStruct? maybeFromMap(dynamic data) =>
      data is Map ? MetricStruct.fromMap(data.cast<String, dynamic>()) : null;

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

  static MetricStruct fromSerializableMap(Map<String, dynamic> data) =>
      MetricStruct(
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
  String toString() => 'MetricStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MetricStruct &&
        amount == other.amount &&
        unitShort == other.unitShort &&
        unitLong == other.unitLong;
  }

  @override
  int get hashCode => const ListEquality().hash([amount, unitShort, unitLong]);
}

MetricStruct createMetricStruct({
  String? amount,
  String? unitShort,
  String? unitLong,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MetricStruct(
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

MetricStruct? updateMetricStruct(
  MetricStruct? metric, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    metric
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMetricStructData(
  Map<String, dynamic> firestoreData,
  MetricStruct? metric,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (metric == null) {
    return;
  }
  if (metric.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && metric.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final metricData = getMetricFirestoreData(metric, forFieldValue);
  final nestedData = metricData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = metric.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMetricFirestoreData(
  MetricStruct? metric, [
  bool forFieldValue = false,
]) {
  if (metric == null) {
    return {};
  }
  final firestoreData = mapToFirestore(metric.toMap());

  // Add any Firestore field values
  metric.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMetricListFirestoreData(
  List<MetricStruct>? metrics,
) =>
    metrics?.map((e) => getMetricFirestoreData(e, true)).toList() ?? [];
