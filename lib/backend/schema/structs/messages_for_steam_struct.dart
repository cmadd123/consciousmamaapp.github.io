// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MessagesForSteamStruct extends FFFirebaseStruct {
  MessagesForSteamStruct({
    String? id,
    String? role,
    List<String>? messages,
    DateTime? createdAt,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _role = role,
        _messages = messages,
        _createdAt = createdAt,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  set role(String? val) => _role = val;

  bool hasRole() => _role != null;

  // "messages" field.
  List<String>? _messages;
  List<String> get messages => _messages ?? const [];
  set messages(List<String>? val) => _messages = val;

  void updateMessages(Function(List<String>) updateFn) {
    updateFn(_messages ??= []);
  }

  bool hasMessages() => _messages != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  static MessagesForSteamStruct fromMap(Map<String, dynamic> data) =>
      MessagesForSteamStruct(
        id: data['id'] as String?,
        role: data['role'] as String?,
        messages: getDataList(data['messages']),
        createdAt: data['created_at'] as DateTime?,
      );

  static MessagesForSteamStruct? maybeFromMap(dynamic data) => data is Map
      ? MessagesForSteamStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'role': _role,
        'messages': _messages,
        'created_at': _createdAt,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'role': serializeParam(
          _role,
          ParamType.String,
        ),
        'messages': serializeParam(
          _messages,
          ParamType.String,
          isList: true,
        ),
        'created_at': serializeParam(
          _createdAt,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static MessagesForSteamStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      MessagesForSteamStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        role: deserializeParam(
          data['role'],
          ParamType.String,
          false,
        ),
        messages: deserializeParam<String>(
          data['messages'],
          ParamType.String,
          true,
        ),
        createdAt: deserializeParam(
          data['created_at'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'MessagesForSteamStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is MessagesForSteamStruct &&
        id == other.id &&
        role == other.role &&
        listEquality.equals(messages, other.messages) &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, role, messages, createdAt]);
}

MessagesForSteamStruct createMessagesForSteamStruct({
  String? id,
  String? role,
  DateTime? createdAt,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MessagesForSteamStruct(
      id: id,
      role: role,
      createdAt: createdAt,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MessagesForSteamStruct? updateMessagesForSteamStruct(
  MessagesForSteamStruct? messagesForSteam, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    messagesForSteam
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMessagesForSteamStructData(
  Map<String, dynamic> firestoreData,
  MessagesForSteamStruct? messagesForSteam,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (messagesForSteam == null) {
    return;
  }
  if (messagesForSteam.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && messagesForSteam.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final messagesForSteamData =
      getMessagesForSteamFirestoreData(messagesForSteam, forFieldValue);
  final nestedData =
      messagesForSteamData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = messagesForSteam.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMessagesForSteamFirestoreData(
  MessagesForSteamStruct? messagesForSteam, [
  bool forFieldValue = false,
]) {
  if (messagesForSteam == null) {
    return {};
  }
  final firestoreData = mapToFirestore(messagesForSteam.toMap());

  // Add any Firestore field values
  messagesForSteam.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMessagesForSteamListFirestoreData(
  List<MessagesForSteamStruct>? messagesForSteams,
) =>
    messagesForSteams
        ?.map((e) => getMessagesForSteamFirestoreData(e, true))
        .toList() ??
    [];
