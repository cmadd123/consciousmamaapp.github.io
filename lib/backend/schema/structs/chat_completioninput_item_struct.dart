// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// {"role":"user", "content": "hello"}
class ChatCompletioninputItemStruct extends FFFirebaseStruct {
  ChatCompletioninputItemStruct({
    String? role,
    String? content,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _role = role,
        _content = content,
        super(firestoreUtilData);

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  set role(String? val) => _role = val;

  bool hasRole() => _role != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  set content(String? val) => _content = val;

  bool hasContent() => _content != null;

  static ChatCompletioninputItemStruct fromMap(Map<String, dynamic> data) =>
      ChatCompletioninputItemStruct(
        role: data['role'] as String?,
        content: data['content'] as String?,
      );

  static ChatCompletioninputItemStruct? maybeFromMap(dynamic data) =>
      data is Map
          ? ChatCompletioninputItemStruct.fromMap(data.cast<String, dynamic>())
          : null;

  Map<String, dynamic> toMap() => {
        'role': _role,
        'content': _content,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'role': serializeParam(
          _role,
          ParamType.String,
        ),
        'content': serializeParam(
          _content,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChatCompletioninputItemStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ChatCompletioninputItemStruct(
        role: deserializeParam(
          data['role'],
          ParamType.String,
          false,
        ),
        content: deserializeParam(
          data['content'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChatCompletioninputItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatCompletioninputItemStruct &&
        role == other.role &&
        content == other.content;
  }

  @override
  int get hashCode => const ListEquality().hash([role, content]);
}

ChatCompletioninputItemStruct createChatCompletioninputItemStruct({
  String? role,
  String? content,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChatCompletioninputItemStruct(
      role: role,
      content: content,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChatCompletioninputItemStruct? updateChatCompletioninputItemStruct(
  ChatCompletioninputItemStruct? chatCompletioninputItem, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    chatCompletioninputItem
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChatCompletioninputItemStructData(
  Map<String, dynamic> firestoreData,
  ChatCompletioninputItemStruct? chatCompletioninputItem,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (chatCompletioninputItem == null) {
    return;
  }
  if (chatCompletioninputItem.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue &&
      chatCompletioninputItem.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final chatCompletioninputItemData = getChatCompletioninputItemFirestoreData(
      chatCompletioninputItem, forFieldValue);
  final nestedData =
      chatCompletioninputItemData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      chatCompletioninputItem.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChatCompletioninputItemFirestoreData(
  ChatCompletioninputItemStruct? chatCompletioninputItem, [
  bool forFieldValue = false,
]) {
  if (chatCompletioninputItem == null) {
    return {};
  }
  final firestoreData = mapToFirestore(chatCompletioninputItem.toMap());

  // Add any Firestore field values
  chatCompletioninputItem.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChatCompletioninputItemListFirestoreData(
  List<ChatCompletioninputItemStruct>? chatCompletioninputItems,
) =>
    chatCompletioninputItems
        ?.map((e) => getChatCompletioninputItemFirestoreData(e, true))
        .toList() ??
    [];
