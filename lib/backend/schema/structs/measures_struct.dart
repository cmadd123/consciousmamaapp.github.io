// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MeasuresStruct extends FFFirebaseStruct {
  MeasuresStruct({
    UsStruct? us,
    MetricStruct? metric,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _us = us,
        _metric = metric,
        super(firestoreUtilData);

  // "us" field.
  UsStruct? _us;
  UsStruct get us => _us ?? UsStruct();
  set us(UsStruct? val) => _us = val;

  void updateUs(Function(UsStruct) updateFn) {
    updateFn(_us ??= UsStruct());
  }

  bool hasUs() => _us != null;

  // "metric" field.
  MetricStruct? _metric;
  MetricStruct get metric => _metric ?? MetricStruct();
  set metric(MetricStruct? val) => _metric = val;

  void updateMetric(Function(MetricStruct) updateFn) {
    updateFn(_metric ??= MetricStruct());
  }

  bool hasMetric() => _metric != null;

  static MeasuresStruct fromMap(Map<String, dynamic> data) => MeasuresStruct(
        us: data['us'] is UsStruct
            ? data['us']
            : UsStruct.maybeFromMap(data['us']),
        metric: data['metric'] is MetricStruct
            ? data['metric']
            : MetricStruct.maybeFromMap(data['metric']),
      );

  static MeasuresStruct? maybeFromMap(dynamic data) =>
      data is Map ? MeasuresStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'us': _us?.toMap(),
        'metric': _metric?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'us': serializeParam(
          _us,
          ParamType.DataStruct,
        ),
        'metric': serializeParam(
          _metric,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static MeasuresStruct fromSerializableMap(Map<String, dynamic> data) =>
      MeasuresStruct(
        us: deserializeStructParam(
          data['us'],
          ParamType.DataStruct,
          false,
          structBuilder: UsStruct.fromSerializableMap,
        ),
        metric: deserializeStructParam(
          data['metric'],
          ParamType.DataStruct,
          false,
          structBuilder: MetricStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'MeasuresStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MeasuresStruct && us == other.us && metric == other.metric;
  }

  @override
  int get hashCode => const ListEquality().hash([us, metric]);
}

MeasuresStruct createMeasuresStruct({
  UsStruct? us,
  MetricStruct? metric,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MeasuresStruct(
      us: us ?? (clearUnsetFields ? UsStruct() : null),
      metric: metric ?? (clearUnsetFields ? MetricStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MeasuresStruct? updateMeasuresStruct(
  MeasuresStruct? measures, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    measures
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMeasuresStructData(
  Map<String, dynamic> firestoreData,
  MeasuresStruct? measures,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (measures == null) {
    return;
  }
  if (measures.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && measures.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final measuresData = getMeasuresFirestoreData(measures, forFieldValue);
  final nestedData = measuresData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = measures.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMeasuresFirestoreData(
  MeasuresStruct? measures, [
  bool forFieldValue = false,
]) {
  if (measures == null) {
    return {};
  }
  final firestoreData = mapToFirestore(measures.toMap());

  // Handle nested data for "us" field.
  addUsStructData(
    firestoreData,
    measures.hasUs() ? measures.us : null,
    'us',
    forFieldValue,
  );

  // Handle nested data for "metric" field.
  addMetricStructData(
    firestoreData,
    measures.hasMetric() ? measures.metric : null,
    'metric',
    forFieldValue,
  );

  // Add any Firestore field values
  measures.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMeasuresListFirestoreData(
  List<MeasuresStruct>? measuress,
) =>
    measuress?.map((e) => getMeasuresFirestoreData(e, true)).toList() ?? [];
