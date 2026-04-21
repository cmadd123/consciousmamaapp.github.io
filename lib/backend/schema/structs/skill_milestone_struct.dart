// ignore_for_file: unnecessary_getters_setters


import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SkillMilestoneStruct extends FFFirebaseStruct {
  SkillMilestoneStruct({
    int? number,
    String? title,
    bool? completed,
    DateTime? completedDate,
    List<SkillSubMilestoneStruct>? subMilestones,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _number = number,
        _title = title,
        _completed = completed,
        _completedDate = completedDate,
        _subMilestones = subMilestones,
        super(firestoreUtilData);

  // "number" field.
  int? _number;
  int get number => _number ?? 0;
  set number(int? val) => _number = val;
  void incrementNumber(int amount) => _number = number + amount;
  bool hasNumber() => _number != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "completed" field.
  bool? _completed;
  bool get completed => _completed ?? false;
  set completed(bool? val) => _completed = val;
  bool hasCompleted() => _completed != null;

  // "completed_date" field.
  DateTime? _completedDate;
  DateTime? get completedDate => _completedDate;
  set completedDate(DateTime? val) => _completedDate = val;
  bool hasCompletedDate() => _completedDate != null;

  // "sub_milestones" field.
  List<SkillSubMilestoneStruct>? _subMilestones;
  List<SkillSubMilestoneStruct> get subMilestones =>
      _subMilestones ?? const [];
  set subMilestones(List<SkillSubMilestoneStruct>? val) => _subMilestones = val;
  void updateSubMilestones(Function(List<SkillSubMilestoneStruct>) updateFn) =>
      updateFn(_subMilestones ??= []);
  bool hasSubMilestones() => _subMilestones != null;

  static SkillMilestoneStruct fromMap(Map<String, dynamic> data) =>
      SkillMilestoneStruct(
        number: castToType<int>(data['number']),
        title: data['title'] as String?,
        completed: data['completed'] as bool?,
        completedDate: data['completed_date'] as DateTime?,
        subMilestones: getStructList<SkillSubMilestoneStruct>(
          data['sub_milestones'],
          SkillSubMilestoneStruct.fromMap,
        ),
      );

  static SkillMilestoneStruct? maybeFromMap(dynamic data) => data is Map
      ? SkillMilestoneStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'number': _number,
        'title': _title,
        'completed': _completed,
        'completed_date': _completedDate,
        'sub_milestones': _subMilestones?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'number': serializeParam(
          _number,
          ParamType.int,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'completed': serializeParam(
          _completed,
          ParamType.bool,
        ),
        'completed_date': serializeParam(
          _completedDate,
          ParamType.DateTime,
        ),
        'sub_milestones': serializeParam(
          _subMilestones,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static SkillMilestoneStruct fromSerializableMap(Map<String, dynamic> data) =>
      SkillMilestoneStruct(
        number: deserializeParam(
          data['number'],
          ParamType.int,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        completed: deserializeParam(
          data['completed'],
          ParamType.bool,
          false,
        ),
        completedDate: deserializeParam(
          data['completed_date'],
          ParamType.DateTime,
          false,
        ),
        subMilestones: deserializeStructParam<SkillSubMilestoneStruct>(
          data['sub_milestones'],
          ParamType.DataStruct,
          true,
          structBuilder: SkillSubMilestoneStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'SkillMilestoneStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is SkillMilestoneStruct &&
        number == other.number &&
        title == other.title &&
        completed == other.completed &&
        completedDate == other.completedDate &&
        listEquality.equals(subMilestones, other.subMilestones);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([number, title, completed, completedDate, subMilestones]);
}

SkillMilestoneStruct createSkillMilestoneStruct({
  int? number,
  String? title,
  bool? completed,
  DateTime? completedDate,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SkillMilestoneStruct(
      number: number,
      title: title,
      completed: completed,
      completedDate: completedDate,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SkillMilestoneStruct? updateSkillMilestoneStruct(
  SkillMilestoneStruct? skillMilestone, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    skillMilestone
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSkillMilestoneStructData(
  Map<String, dynamic> firestoreData,
  SkillMilestoneStruct? skillMilestone,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (skillMilestone == null) {
    return;
  }
  if (skillMilestone.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && skillMilestone.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final skillMilestoneData =
      getSkillMilestoneFirestoreData(skillMilestone, forFieldValue);
  final nestedData =
      skillMilestoneData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = skillMilestone.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSkillMilestoneFirestoreData(
  SkillMilestoneStruct? skillMilestone, [
  bool forFieldValue = false,
]) {
  if (skillMilestone == null) {
    return {};
  }
  final firestoreData = mapToFirestore(skillMilestone.toMap());

  // Add any Firestore field values
  skillMilestone.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSkillMilestoneListFirestoreData(
  List<SkillMilestoneStruct>? skillMilestones,
) =>
    skillMilestones?.map((e) => getSkillMilestoneFirestoreData(e, true)).toList() ??
        [];
