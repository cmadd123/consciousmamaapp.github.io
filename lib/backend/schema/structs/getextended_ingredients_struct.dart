// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GetextendedIngredientsStruct extends FFFirebaseStruct {
  GetextendedIngredientsStruct({
    List<ExtendedIngredientsStruct>? extendedIngredients,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _extendedIngredients = extendedIngredients,
        super(firestoreUtilData);

  // "extendedIngredients" field.
  List<ExtendedIngredientsStruct>? _extendedIngredients;
  List<ExtendedIngredientsStruct> get extendedIngredients =>
      _extendedIngredients ?? const [];
  set extendedIngredients(List<ExtendedIngredientsStruct>? val) =>
      _extendedIngredients = val;

  void updateExtendedIngredients(
      Function(List<ExtendedIngredientsStruct>) updateFn) {
    updateFn(_extendedIngredients ??= []);
  }

  bool hasExtendedIngredients() => _extendedIngredients != null;

  static GetextendedIngredientsStruct fromMap(Map<String, dynamic> data) =>
      GetextendedIngredientsStruct(
        extendedIngredients: getStructList(
          data['extendedIngredients'],
          ExtendedIngredientsStruct.fromMap,
        ),
      );

  static GetextendedIngredientsStruct? maybeFromMap(dynamic data) => data is Map
      ? GetextendedIngredientsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'extendedIngredients':
            _extendedIngredients?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'extendedIngredients': serializeParam(
          _extendedIngredients,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static GetextendedIngredientsStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GetextendedIngredientsStruct(
        extendedIngredients: deserializeStructParam<ExtendedIngredientsStruct>(
          data['extendedIngredients'],
          ParamType.DataStruct,
          true,
          structBuilder: ExtendedIngredientsStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'GetextendedIngredientsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is GetextendedIngredientsStruct &&
        listEquality.equals(extendedIngredients, other.extendedIngredients);
  }

  @override
  int get hashCode => const ListEquality().hash([extendedIngredients]);
}

GetextendedIngredientsStruct createGetextendedIngredientsStruct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    GetextendedIngredientsStruct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

GetextendedIngredientsStruct? updateGetextendedIngredientsStruct(
  GetextendedIngredientsStruct? getextendedIngredients, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    getextendedIngredients
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addGetextendedIngredientsStructData(
  Map<String, dynamic> firestoreData,
  GetextendedIngredientsStruct? getextendedIngredients,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (getextendedIngredients == null) {
    return;
  }
  if (getextendedIngredients.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      getextendedIngredients.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final getextendedIngredientsData = getGetextendedIngredientsFirestoreData(
      getextendedIngredients, forFieldValue);
  final nestedData =
      getextendedIngredientsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      getextendedIngredients.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getGetextendedIngredientsFirestoreData(
  GetextendedIngredientsStruct? getextendedIngredients, [
  bool forFieldValue = false,
]) {
  if (getextendedIngredients == null) {
    return {};
  }
  final firestoreData = mapToFirestore(getextendedIngredients.toMap());

  // Add any Firestore field values
  getextendedIngredients.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getGetextendedIngredientsListFirestoreData(
  List<GetextendedIngredientsStruct>? getextendedIngredientss,
) =>
    getextendedIngredientss
        ?.map((e) => getGetextendedIngredientsFirestoreData(e, true))
        .toList() ??
    [];
