// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatCompletionResultStruct extends FFFirebaseStruct {
  ChatCompletionResultStruct({
    String? id,
    String? object,
    int? created,
    String? model,
    String? serviceTier,
    String? systemFingerprint,
    List<ChoicesStruct>? choices,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _object = object,
        _created = created,
        _model = model,
        _serviceTier = serviceTier,
        _systemFingerprint = systemFingerprint,
        _choices = choices,
        super(firestoreUtilData);

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "object" field.
  String? _object;
  String get object => _object ?? '';
  set object(String? val) => _object = val;

  bool hasObject() => _object != null;

  // "created" field.
  int? _created;
  int get created => _created ?? 0;
  set created(int? val) => _created = val;

  void incrementCreated(int amount) => created = created + amount;

  bool hasCreated() => _created != null;

  // "model" field.
  String? _model;
  String get model => _model ?? '';
  set model(String? val) => _model = val;

  bool hasModel() => _model != null;

  // "service_tier" field.
  String? _serviceTier;
  String get serviceTier => _serviceTier ?? '';
  set serviceTier(String? val) => _serviceTier = val;

  bool hasServiceTier() => _serviceTier != null;

  // "system_fingerprint" field.
  String? _systemFingerprint;
  String get systemFingerprint => _systemFingerprint ?? '';
  set systemFingerprint(String? val) => _systemFingerprint = val;

  bool hasSystemFingerprint() => _systemFingerprint != null;

  // "choices" field.
  List<ChoicesStruct>? _choices;
  List<ChoicesStruct> get choices => _choices ?? const [];
  set choices(List<ChoicesStruct>? val) => _choices = val;

  void updateChoices(Function(List<ChoicesStruct>) updateFn) {
    updateFn(_choices ??= []);
  }

  bool hasChoices() => _choices != null;

  static ChatCompletionResultStruct fromMap(Map<String, dynamic> data) =>
      ChatCompletionResultStruct(
        id: data['id'] as String?,
        object: data['object'] as String?,
        created: castToType<int>(data['created']),
        model: data['model'] as String?,
        serviceTier: data['service_tier'] as String?,
        systemFingerprint: data['system_fingerprint'] as String?,
        choices: getStructList(
          data['choices'],
          ChoicesStruct.fromMap,
        ),
      );

  static ChatCompletionResultStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatCompletionResultStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'object': _object,
        'created': _created,
        'model': _model,
        'service_tier': _serviceTier,
        'system_fingerprint': _systemFingerprint,
        'choices': _choices?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.String,
        ),
        'object': serializeParam(
          _object,
          ParamType.String,
        ),
        'created': serializeParam(
          _created,
          ParamType.int,
        ),
        'model': serializeParam(
          _model,
          ParamType.String,
        ),
        'service_tier': serializeParam(
          _serviceTier,
          ParamType.String,
        ),
        'system_fingerprint': serializeParam(
          _systemFingerprint,
          ParamType.String,
        ),
        'choices': serializeParam(
          _choices,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static ChatCompletionResultStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ChatCompletionResultStruct(
        id: deserializeParam(
          data['id'],
          ParamType.String,
          false,
        ),
        object: deserializeParam(
          data['object'],
          ParamType.String,
          false,
        ),
        created: deserializeParam(
          data['created'],
          ParamType.int,
          false,
        ),
        model: deserializeParam(
          data['model'],
          ParamType.String,
          false,
        ),
        serviceTier: deserializeParam(
          data['service_tier'],
          ParamType.String,
          false,
        ),
        systemFingerprint: deserializeParam(
          data['system_fingerprint'],
          ParamType.String,
          false,
        ),
        choices: deserializeStructParam<ChoicesStruct>(
          data['choices'],
          ParamType.DataStruct,
          true,
          structBuilder: ChoicesStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'ChatCompletionResultStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ChatCompletionResultStruct &&
        id == other.id &&
        object == other.object &&
        created == other.created &&
        model == other.model &&
        serviceTier == other.serviceTier &&
        systemFingerprint == other.systemFingerprint &&
        listEquality.equals(choices, other.choices);
  }

  @override
  int get hashCode => const ListEquality().hash(
      [id, object, created, model, serviceTier, systemFingerprint, choices]);
}

ChatCompletionResultStruct createChatCompletionResultStruct({
  String? id,
  String? object,
  int? created,
  String? model,
  String? serviceTier,
  String? systemFingerprint,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChatCompletionResultStruct(
      id: id,
      object: object,
      created: created,
      model: model,
      serviceTier: serviceTier,
      systemFingerprint: systemFingerprint,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChatCompletionResultStruct? updateChatCompletionResultStruct(
  ChatCompletionResultStruct? chatCompletionResult, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    chatCompletionResult
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChatCompletionResultStructData(
  Map<String, dynamic> firestoreData,
  ChatCompletionResultStruct? chatCompletionResult,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (chatCompletionResult == null) {
    return;
  }
  if (chatCompletionResult.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && chatCompletionResult.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final chatCompletionResultData =
      getChatCompletionResultFirestoreData(chatCompletionResult, forFieldValue);
  final nestedData =
      chatCompletionResultData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      chatCompletionResult.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChatCompletionResultFirestoreData(
  ChatCompletionResultStruct? chatCompletionResult, [
  bool forFieldValue = false,
]) {
  if (chatCompletionResult == null) {
    return {};
  }
  final firestoreData = mapToFirestore(chatCompletionResult.toMap());

  // Add any Firestore field values
  chatCompletionResult.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChatCompletionResultListFirestoreData(
  List<ChatCompletionResultStruct>? chatCompletionResults,
) =>
    chatCompletionResults
        ?.map((e) => getChatCompletionResultFirestoreData(e, true))
        .toList() ??
    [];
