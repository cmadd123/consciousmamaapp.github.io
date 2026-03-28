// ignore_for_file: unnecessary_getters_setters

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SkillSubMilestoneStruct extends FFFirebaseStruct {
  SkillSubMilestoneStruct({
    String? title,
    String? videoSearch,
    bool? completed,
    DateTime? completedDate,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _videoSearch = videoSearch,
        _completed = completed,
        _completedDate = completedDate,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;
  bool hasTitle() => _title != null;

  // "video_search" field.
  String? _videoSearch;
  String get videoSearch => _videoSearch ?? '';
  set videoSearch(String? val) => _videoSearch = val;
  bool hasVideoSearch() => _videoSearch != null;

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

  static SkillSubMilestoneStruct fromMap(Map<String, dynamic> data) =>
      SkillSubMilestoneStruct(
        title: data['title'] as String?,
        videoSearch: data['video_search'] as String?,
        completed: data['completed'] as bool?,
        completedDate: data['completed_date'] as DateTime?,
      );

  static SkillSubMilestoneStruct? maybeFromMap(dynamic data) => data is Map
      ? SkillSubMilestoneStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'video_search': _videoSearch,
        'completed': _completed,
        'completed_date': _completedDate,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'video_search': serializeParam(
          _videoSearch,
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
      }.withoutNulls;

  static SkillSubMilestoneStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SkillSubMilestoneStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        videoSearch: deserializeParam(
          data['video_search'],
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
      );

  @override
  String toString() => 'SkillSubMilestoneStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SkillSubMilestoneStruct &&
        title == other.title &&
        videoSearch == other.videoSearch &&
        completed == other.completed &&
        completedDate == other.completedDate;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([title, videoSearch, completed, completedDate]);
}

SkillSubMilestoneStruct createSkillSubMilestoneStruct({
  String? title,
  String? videoSearch,
  bool? completed,
  DateTime? completedDate,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SkillSubMilestoneStruct(
      title: title,
      videoSearch: videoSearch,
      completed: completed,
      completedDate: completedDate,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SkillSubMilestoneStruct? updateSkillSubMilestoneStruct(
  SkillSubMilestoneStruct? skillSubMilestone, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    skillSubMilestone
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSkillSubMilestoneStructData(
  Map<String, dynamic> firestoreData,
  SkillSubMilestoneStruct? skillSubMilestone,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (skillSubMilestone == null) {
    return;
  }
  if (skillSubMilestone.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && skillSubMilestone.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final skillSubMilestoneData =
      getSkillSubMilestoneFirestoreData(skillSubMilestone, forFieldValue);
  final nestedData =
      skillSubMilestoneData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = skillSubMilestone.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSkillSubMilestoneFirestoreData(
  SkillSubMilestoneStruct? skillSubMilestone, [
  bool forFieldValue = false,
]) {
  if (skillSubMilestone == null) {
    return {};
  }
  final firestoreData = mapToFirestore(skillSubMilestone.toMap());

  // Add any Firestore field values
  skillSubMilestone.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSkillSubMilestoneListFirestoreData(
  List<SkillSubMilestoneStruct>? skillSubMilestones,
) =>
    skillSubMilestones
        ?.map((e) => getSkillSubMilestoneFirestoreData(e, true))
        .toList() ??
    [];
