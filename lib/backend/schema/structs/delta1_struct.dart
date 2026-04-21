// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class Delta1Struct extends FFFirebaseStruct {
  Delta1Struct({
    List<ContentStruct>? content,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _content = content,
        super(firestoreUtilData);

  // "content" field.
  List<ContentStruct>? _content;
  List<ContentStruct> get content => _content ?? const [];
  set content(List<ContentStruct>? val) => _content = val;

  void updateContent(Function(List<ContentStruct>) updateFn) {
    updateFn(_content ??= []);
  }

  bool hasContent() => _content != null;

  static Delta1Struct fromMap(Map<String, dynamic> data) => Delta1Struct(
        content: getStructList(
          data['content'],
          ContentStruct.fromMap,
        ),
      );

  static Delta1Struct? maybeFromMap(dynamic data) =>
      data is Map ? Delta1Struct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'content': _content?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'content': serializeParam(
          _content,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static Delta1Struct fromSerializableMap(Map<String, dynamic> data) =>
      Delta1Struct(
        content: deserializeStructParam<ContentStruct>(
          data['content'],
          ParamType.DataStruct,
          true,
          structBuilder: ContentStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'Delta1Struct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is Delta1Struct && listEquality.equals(content, other.content);
  }

  @override
  int get hashCode => const ListEquality().hash([content]);
}

Delta1Struct createDelta1Struct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    Delta1Struct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

Delta1Struct? updateDelta1Struct(
  Delta1Struct? delta1, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    delta1
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addDelta1StructData(
  Map<String, dynamic> firestoreData,
  Delta1Struct? delta1,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (delta1 == null) {
    return;
  }
  if (delta1.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && delta1.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final delta1Data = getDelta1FirestoreData(delta1, forFieldValue);
  final nestedData = delta1Data.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = delta1.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getDelta1FirestoreData(
  Delta1Struct? delta1, [
  bool forFieldValue = false,
]) {
  if (delta1 == null) {
    return {};
  }
  final firestoreData = mapToFirestore(delta1.toMap());

  // Add any Firestore field values
  delta1.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getDelta1ListFirestoreData(
  List<Delta1Struct>? delta1s,
) =>
    delta1s?.map((e) => getDelta1FirestoreData(e, true)).toList() ?? [];
