// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import '/flutter_flow/flutter_flow_util.dart';

class HomeActivtyModelStruct extends FFFirebaseStruct {
  HomeActivtyModelStruct({
    DocumentReference? childRef,
    DocumentReference? actitvtyRef,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _childRef = childRef,
        _actitvtyRef = actitvtyRef,
        super(firestoreUtilData);

  // "childRef" field.
  DocumentReference? _childRef;
  DocumentReference? get childRef => _childRef;
  set childRef(DocumentReference? val) => _childRef = val;

  bool hasChildRef() => _childRef != null;

  // "ActitvtyRef" field.
  DocumentReference? _actitvtyRef;
  DocumentReference? get actitvtyRef => _actitvtyRef;
  set actitvtyRef(DocumentReference? val) => _actitvtyRef = val;

  bool hasActitvtyRef() => _actitvtyRef != null;

  static HomeActivtyModelStruct fromMap(Map<String, dynamic> data) =>
      HomeActivtyModelStruct(
        childRef: data['childRef'] as DocumentReference?,
        actitvtyRef: data['ActitvtyRef'] as DocumentReference?,
      );

  static HomeActivtyModelStruct? maybeFromMap(dynamic data) => data is Map
      ? HomeActivtyModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'childRef': _childRef,
        'ActitvtyRef': _actitvtyRef,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'childRef': serializeParam(
          _childRef,
          ParamType.DocumentReference,
        ),
        'ActitvtyRef': serializeParam(
          _actitvtyRef,
          ParamType.DocumentReference,
        ),
      }.withoutNulls;

  static HomeActivtyModelStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      HomeActivtyModelStruct(
        childRef: deserializeParam(
          data['childRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['childern'],
        ),
        actitvtyRef: deserializeParam(
          data['ActitvtyRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['activities'],
        ),
      );

  @override
  String toString() => 'HomeActivtyModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is HomeActivtyModelStruct &&
        childRef == other.childRef &&
        actitvtyRef == other.actitvtyRef;
  }

  @override
  int get hashCode => const ListEquality().hash([childRef, actitvtyRef]);
}

HomeActivtyModelStruct createHomeActivtyModelStruct({
  DocumentReference? childRef,
  DocumentReference? actitvtyRef,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    HomeActivtyModelStruct(
      childRef: childRef,
      actitvtyRef: actitvtyRef,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

HomeActivtyModelStruct? updateHomeActivtyModelStruct(
  HomeActivtyModelStruct? homeActivtyModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    homeActivtyModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addHomeActivtyModelStructData(
  Map<String, dynamic> firestoreData,
  HomeActivtyModelStruct? homeActivtyModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (homeActivtyModel == null) {
    return;
  }
  if (homeActivtyModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && homeActivtyModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final homeActivtyModelData =
      getHomeActivtyModelFirestoreData(homeActivtyModel, forFieldValue);
  final nestedData =
      homeActivtyModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = homeActivtyModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getHomeActivtyModelFirestoreData(
  HomeActivtyModelStruct? homeActivtyModel, [
  bool forFieldValue = false,
]) {
  if (homeActivtyModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(homeActivtyModel.toMap());

  // Add any Firestore field values
  homeActivtyModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getHomeActivtyModelListFirestoreData(
  List<HomeActivtyModelStruct>? homeActivtyModels,
) =>
    homeActivtyModels
        ?.map((e) => getHomeActivtyModelFirestoreData(e, true))
        .toList() ??
    [];
