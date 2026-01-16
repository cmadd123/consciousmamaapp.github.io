// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ActivityModelStruct extends FFFirebaseStruct {
  ActivityModelStruct({
    String? title,
    String? locationTyp,
    String? activityTyp,
    String? description,
    List<String>? activityNeeds,
    String? activitySafetyConcerns,
    DocumentReference? childFireBaseRef,
    DateTime? activityTime,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _locationTyp = locationTyp,
        _activityTyp = activityTyp,
        _description = description,
        _activityNeeds = activityNeeds,
        _activitySafetyConcerns = activitySafetyConcerns,
        _childFireBaseRef = childFireBaseRef,
        _activityTime = activityTime,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "locationTyp" field.
  String? _locationTyp;
  String get locationTyp => _locationTyp ?? '';
  set locationTyp(String? val) => _locationTyp = val;

  bool hasLocationTyp() => _locationTyp != null;

  // "activityTyp" field.
  String? _activityTyp;
  String get activityTyp => _activityTyp ?? '';
  set activityTyp(String? val) => _activityTyp = val;

  bool hasActivityTyp() => _activityTyp != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "activityNeeds" field.
  List<String>? _activityNeeds;
  List<String> get activityNeeds => _activityNeeds ?? const [];
  set activityNeeds(List<String>? val) => _activityNeeds = val;

  void updateActivityNeeds(Function(List<String>) updateFn) {
    updateFn(_activityNeeds ??= []);
  }

  bool hasActivityNeeds() => _activityNeeds != null;

  // "activitySafetyConcerns" field.
  String? _activitySafetyConcerns;
  String get activitySafetyConcerns => _activitySafetyConcerns ?? '';
  set activitySafetyConcerns(String? val) => _activitySafetyConcerns = val;

  bool hasActivitySafetyConcerns() => _activitySafetyConcerns != null;

  // "childFireBaseRef" field.
  DocumentReference? _childFireBaseRef;
  DocumentReference? get childFireBaseRef => _childFireBaseRef;
  set childFireBaseRef(DocumentReference? val) => _childFireBaseRef = val;

  bool hasChildFireBaseRef() => _childFireBaseRef != null;

  // "activityTime" field.
  DateTime? _activityTime;
  DateTime? get activityTime => _activityTime;
  set activityTime(DateTime? val) => _activityTime = val;

  bool hasActivityTime() => _activityTime != null;

  static ActivityModelStruct fromMap(Map<String, dynamic> data) =>
      ActivityModelStruct(
        title: data['title'] as String?,
        locationTyp: data['locationTyp'] as String?,
        activityTyp: data['activityTyp'] as String?,
        description: data['description'] as String?,
        activityNeeds: getDataList(data['activityNeeds']),
        activitySafetyConcerns: data['activitySafetyConcerns'] as String?,
        childFireBaseRef: data['childFireBaseRef'] as DocumentReference?,
        activityTime: data['activityTime'] as DateTime?,
      );

  static ActivityModelStruct? maybeFromMap(dynamic data) => data is Map
      ? ActivityModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'locationTyp': _locationTyp,
        'activityTyp': _activityTyp,
        'description': _description,
        'activityNeeds': _activityNeeds,
        'activitySafetyConcerns': _activitySafetyConcerns,
        'childFireBaseRef': _childFireBaseRef,
        'activityTime': _activityTime,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'locationTyp': serializeParam(
          _locationTyp,
          ParamType.String,
        ),
        'activityTyp': serializeParam(
          _activityTyp,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'activityNeeds': serializeParam(
          _activityNeeds,
          ParamType.String,
          isList: true,
        ),
        'activitySafetyConcerns': serializeParam(
          _activitySafetyConcerns,
          ParamType.String,
        ),
        'childFireBaseRef': serializeParam(
          _childFireBaseRef,
          ParamType.DocumentReference,
        ),
        'activityTime': serializeParam(
          _activityTime,
          ParamType.DateTime,
        ),
      }.withoutNulls;

  static ActivityModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      ActivityModelStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        locationTyp: deserializeParam(
          data['locationTyp'],
          ParamType.String,
          false,
        ),
        activityTyp: deserializeParam(
          data['activityTyp'],
          ParamType.String,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        activityNeeds: deserializeParam<String>(
          data['activityNeeds'],
          ParamType.String,
          true,
        ),
        activitySafetyConcerns: deserializeParam(
          data['activitySafetyConcerns'],
          ParamType.String,
          false,
        ),
        childFireBaseRef: deserializeParam(
          data['childFireBaseRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['childern'],
        ),
        activityTime: deserializeParam(
          data['activityTime'],
          ParamType.DateTime,
          false,
        ),
      );

  @override
  String toString() => 'ActivityModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ActivityModelStruct &&
        title == other.title &&
        locationTyp == other.locationTyp &&
        activityTyp == other.activityTyp &&
        description == other.description &&
        listEquality.equals(activityNeeds, other.activityNeeds) &&
        activitySafetyConcerns == other.activitySafetyConcerns &&
        childFireBaseRef == other.childFireBaseRef &&
        activityTime == other.activityTime;
  }

  @override
  int get hashCode => const ListEquality().hash([
        title,
        locationTyp,
        activityTyp,
        description,
        activityNeeds,
        activitySafetyConcerns,
        childFireBaseRef,
        activityTime
      ]);
}

ActivityModelStruct createActivityModelStruct({
  String? title,
  String? locationTyp,
  String? activityTyp,
  String? description,
  String? activitySafetyConcerns,
  DocumentReference? childFireBaseRef,
  DateTime? activityTime,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ActivityModelStruct(
      title: title,
      locationTyp: locationTyp,
      activityTyp: activityTyp,
      description: description,
      activitySafetyConcerns: activitySafetyConcerns,
      childFireBaseRef: childFireBaseRef,
      activityTime: activityTime,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ActivityModelStruct? updateActivityModelStruct(
  ActivityModelStruct? activityModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    activityModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addActivityModelStructData(
  Map<String, dynamic> firestoreData,
  ActivityModelStruct? activityModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (activityModel == null) {
    return;
  }
  if (activityModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && activityModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final activityModelData =
      getActivityModelFirestoreData(activityModel, forFieldValue);
  final nestedData =
      activityModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = activityModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getActivityModelFirestoreData(
  ActivityModelStruct? activityModel, [
  bool forFieldValue = false,
]) {
  if (activityModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(activityModel.toMap());

  // Add any Firestore field values
  activityModel.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getActivityModelListFirestoreData(
  List<ActivityModelStruct>? activityModels,
) =>
    activityModels
        ?.map((e) => getActivityModelFirestoreData(e, true))
        .toList() ??
    [];
