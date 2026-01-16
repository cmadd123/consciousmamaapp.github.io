// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MessageAssitantStruct extends FFFirebaseStruct {
  MessageAssitantStruct({
    String? event,
    DataStruct? data,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _event = event,
        _data = data,
        super(firestoreUtilData);

  // "event" field.
  String? _event;
  String get event => _event ?? '';
  set event(String? val) => _event = val;

  bool hasEvent() => _event != null;

  // "data" field.
  DataStruct? _data;
  DataStruct get data => _data ?? DataStruct();
  set data(DataStruct? val) => _data = val;

  void updateData(Function(DataStruct) updateFn) {
    updateFn(_data ??= DataStruct());
  }

  bool hasData() => _data != null;

  static MessageAssitantStruct fromMap(Map<String, dynamic> data) =>
      MessageAssitantStruct(
        event: data['event'] as String?,
        data: data['data'] is DataStruct
            ? data['data']
            : DataStruct.maybeFromMap(data['data']),
      );

  static MessageAssitantStruct? maybeFromMap(dynamic data) => data is Map
      ? MessageAssitantStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'event': _event,
        'data': _data?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'event': serializeParam(
          _event,
          ParamType.String,
        ),
        'data': serializeParam(
          _data,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static MessageAssitantStruct fromSerializableMap(Map<String, dynamic> data) =>
      MessageAssitantStruct(
        event: deserializeParam(
          data['event'],
          ParamType.String,
          false,
        ),
        data: deserializeStructParam(
          data['data'],
          ParamType.DataStruct,
          false,
          structBuilder: DataStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'MessageAssitantStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MessageAssitantStruct &&
        event == other.event &&
        data == other.data;
  }

  @override
  int get hashCode => const ListEquality().hash([event, data]);
}

MessageAssitantStruct createMessageAssitantStruct({
  String? event,
  DataStruct? data,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MessageAssitantStruct(
      event: event,
      data: data ?? (clearUnsetFields ? DataStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MessageAssitantStruct? updateMessageAssitantStruct(
  MessageAssitantStruct? messageAssitant, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    messageAssitant
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMessageAssitantStructData(
  Map<String, dynamic> firestoreData,
  MessageAssitantStruct? messageAssitant,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (messageAssitant == null) {
    return;
  }
  if (messageAssitant.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && messageAssitant.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final messageAssitantData =
      getMessageAssitantFirestoreData(messageAssitant, forFieldValue);
  final nestedData =
      messageAssitantData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = messageAssitant.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMessageAssitantFirestoreData(
  MessageAssitantStruct? messageAssitant, [
  bool forFieldValue = false,
]) {
  if (messageAssitant == null) {
    return {};
  }
  final firestoreData = mapToFirestore(messageAssitant.toMap());

  // Handle nested data for "data" field.
  addDataStructData(
    firestoreData,
    messageAssitant.hasData() ? messageAssitant.data : null,
    'data',
    forFieldValue,
  );

  // Add any Firestore field values
  messageAssitant.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMessageAssitantListFirestoreData(
  List<MessageAssitantStruct>? messageAssitants,
) =>
    messageAssitants
        ?.map((e) => getMessageAssitantFirestoreData(e, true))
        .toList() ??
    [];
