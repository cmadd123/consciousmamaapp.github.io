// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChildActivityStruct extends FFFirebaseStruct {
  ChildActivityStruct({
    DocumentReference? userchilde,
    List<DocumentReference>? activity,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _userchilde = userchilde,
        _activity = activity,
        super(firestoreUtilData);

  // "userchilde" field.
  DocumentReference? _userchilde;
  DocumentReference? get userchilde => _userchilde;
  set userchilde(DocumentReference? val) => _userchilde = val;

  bool hasUserchilde() => _userchilde != null;

  // "activity" field.
  List<DocumentReference>? _activity;
  List<DocumentReference> get activity => _activity ?? const [];
  set activity(List<DocumentReference>? val) => _activity = val;

  void updateActivity(Function(List<DocumentReference>) updateFn) {
    updateFn(_activity ??= []);
  }

  bool hasActivity() => _activity != null;

  static ChildActivityStruct fromMap(Map<String, dynamic> data) =>
      ChildActivityStruct(
        userchilde: data['userchilde'] as DocumentReference?,
        activity: getDataList(data['activity']),
      );

  static ChildActivityStruct? maybeFromMap(dynamic data) => data is Map
      ? ChildActivityStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'userchilde': _userchilde,
        'activity': _activity,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userchilde': serializeParam(
          _userchilde,
          ParamType.DocumentReference,
        ),
        'activity': serializeParam(
          _activity,
          ParamType.DocumentReference,
          isList: true,
        ),
      }.withoutNulls;

  static ChildActivityStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChildActivityStruct(
        userchilde: deserializeParam(
          data['userchilde'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['childern'],
        ),
        activity: deserializeParam<DocumentReference>(
          data['activity'],
          ParamType.DocumentReference,
          true,
          collectionNamePath: ['activities'],
        ),
      );

  @override
  String toString() => 'ChildActivityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ChildActivityStruct &&
        userchilde == other.userchilde &&
        listEquality.equals(activity, other.activity);
  }

  @override
  int get hashCode => const ListEquality().hash([userchilde, activity]);
}

ChildActivityStruct createChildActivityStruct({
  DocumentReference? userchilde,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChildActivityStruct(
      userchilde: userchilde,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChildActivityStruct? updateChildActivityStruct(
  ChildActivityStruct? childActivity, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    childActivity
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChildActivityStructData(
  Map<String, dynamic> firestoreData,
  ChildActivityStruct? childActivity,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (childActivity == null) {
    return;
  }
  if (childActivity.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && childActivity.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final childActivityData =
      getChildActivityFirestoreData(childActivity, forFieldValue);
  final nestedData =
      childActivityData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = childActivity.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChildActivityFirestoreData(
  ChildActivityStruct? childActivity, [
  bool forFieldValue = false,
]) {
  if (childActivity == null) {
    return {};
  }
  final firestoreData = mapToFirestore(childActivity.toMap());

  // Add any Firestore field values
  childActivity.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChildActivityListFirestoreData(
  List<ChildActivityStruct>? childActivitys,
) =>
    childActivitys
        ?.map((e) => getChildActivityFirestoreData(e, true))
        .toList() ??
    [];
