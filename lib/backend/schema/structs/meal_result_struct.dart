// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MealResultStruct extends FFFirebaseStruct {
  MealResultStruct({
    List<ResultsStruct>? results,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _results = results,
        super(firestoreUtilData);

  // "results" field.
  List<ResultsStruct>? _results;
  List<ResultsStruct> get results => _results ?? const [];
  set results(List<ResultsStruct>? val) => _results = val;

  void updateResults(Function(List<ResultsStruct>) updateFn) {
    updateFn(_results ??= []);
  }

  bool hasResults() => _results != null;

  static MealResultStruct fromMap(Map<String, dynamic> data) =>
      MealResultStruct(
        results: getStructList(
          data['results'],
          ResultsStruct.fromMap,
        ),
      );

  static MealResultStruct? maybeFromMap(dynamic data) => data is Map
      ? MealResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'results': _results?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'results': serializeParam(
          _results,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static MealResultStruct fromSerializableMap(Map<String, dynamic> data) =>
      MealResultStruct(
        results: deserializeStructParam<ResultsStruct>(
          data['results'],
          ParamType.DataStruct,
          true,
          structBuilder: ResultsStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'MealResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MealResultStruct &&
        listEquality.equals(results, other.results);
  }

  @override
  int get hashCode => const ListEquality().hash([results]);
}

MealResultStruct createMealResultStruct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MealResultStruct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MealResultStruct? updateMealResultStruct(
  MealResultStruct? mealResult, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    mealResult
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMealResultStructData(
  Map<String, dynamic> firestoreData,
  MealResultStruct? mealResult,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (mealResult == null) {
    return;
  }
  if (mealResult.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && mealResult.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final mealResultData = getMealResultFirestoreData(mealResult, forFieldValue);
  final nestedData = mealResultData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = mealResult.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMealResultFirestoreData(
  MealResultStruct? mealResult, [
  bool forFieldValue = false,
]) {
  if (mealResult == null) {
    return {};
  }
  final firestoreData = mapToFirestore(mealResult.toMap());

  // Add any Firestore field values
  mealResult.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMealResultListFirestoreData(
  List<MealResultStruct>? mealResults,
) =>
    mealResults?.map((e) => getMealResultFirestoreData(e, true)).toList() ?? [];
