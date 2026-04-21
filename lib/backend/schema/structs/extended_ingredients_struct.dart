// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ExtendedIngredientsStruct extends FFFirebaseStruct {
  ExtendedIngredientsStruct({
    int? id,
    String? aisle,
    String? image,
    String? consistency,
    String? name,
    String? nameClean,
    String? original,
    String? originalName,
    String? amount,
    String? unit,
    List<String>? meta,
    MeasuresStruct? measures,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _aisle = aisle,
        _image = image,
        _consistency = consistency,
        _name = name,
        _nameClean = nameClean,
        _original = original,
        _originalName = originalName,
        _amount = amount,
        _unit = unit,
        _meta = meta,
        _measures = measures,
        super(firestoreUtilData);

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "aisle" field.
  String? _aisle;
  String get aisle => _aisle ?? '';
  set aisle(String? val) => _aisle = val;

  bool hasAisle() => _aisle != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "consistency" field.
  String? _consistency;
  String get consistency => _consistency ?? '';
  set consistency(String? val) => _consistency = val;

  bool hasConsistency() => _consistency != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "nameClean" field.
  String? _nameClean;
  String get nameClean => _nameClean ?? '';
  set nameClean(String? val) => _nameClean = val;

  bool hasNameClean() => _nameClean != null;

  // "original" field.
  String? _original;
  String get original => _original ?? '';
  set original(String? val) => _original = val;

  bool hasOriginal() => _original != null;

  // "originalName" field.
  String? _originalName;
  String get originalName => _originalName ?? '';
  set originalName(String? val) => _originalName = val;

  bool hasOriginalName() => _originalName != null;

  // "amount" field.
  String? _amount;
  String get amount => _amount ?? '';
  set amount(String? val) => _amount = val;

  bool hasAmount() => _amount != null;

  // "unit" field.
  String? _unit;
  String get unit => _unit ?? '';
  set unit(String? val) => _unit = val;

  bool hasUnit() => _unit != null;

  // "meta" field.
  List<String>? _meta;
  List<String> get meta => _meta ?? const [];
  set meta(List<String>? val) => _meta = val;

  void updateMeta(Function(List<String>) updateFn) {
    updateFn(_meta ??= []);
  }

  bool hasMeta() => _meta != null;

  // "measures" field.
  MeasuresStruct? _measures;
  MeasuresStruct get measures => _measures ?? MeasuresStruct();
  set measures(MeasuresStruct? val) => _measures = val;

  void updateMeasures(Function(MeasuresStruct) updateFn) {
    updateFn(_measures ??= MeasuresStruct());
  }

  bool hasMeasures() => _measures != null;

  static ExtendedIngredientsStruct fromMap(Map<String, dynamic> data) =>
      ExtendedIngredientsStruct(
        id: castToType<int>(data['id']),
        aisle: data['aisle'] as String?,
        image: data['image'] as String?,
        consistency: data['consistency'] as String?,
        name: data['name'] as String?,
        nameClean: data['nameClean'] as String?,
        original: data['original'] as String?,
        originalName: data['originalName'] as String?,
        amount: data['amount'] as String?,
        unit: data['unit'] as String?,
        meta: getDataList(data['meta']),
        measures: data['measures'] is MeasuresStruct
            ? data['measures']
            : MeasuresStruct.maybeFromMap(data['measures']),
      );

  static ExtendedIngredientsStruct? maybeFromMap(dynamic data) => data is Map
      ? ExtendedIngredientsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'aisle': _aisle,
        'image': _image,
        'consistency': _consistency,
        'name': _name,
        'nameClean': _nameClean,
        'original': _original,
        'originalName': _originalName,
        'amount': _amount,
        'unit': _unit,
        'meta': _meta,
        'measures': _measures?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'aisle': serializeParam(
          _aisle,
          ParamType.String,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'consistency': serializeParam(
          _consistency,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'nameClean': serializeParam(
          _nameClean,
          ParamType.String,
        ),
        'original': serializeParam(
          _original,
          ParamType.String,
        ),
        'originalName': serializeParam(
          _originalName,
          ParamType.String,
        ),
        'amount': serializeParam(
          _amount,
          ParamType.String,
        ),
        'unit': serializeParam(
          _unit,
          ParamType.String,
        ),
        'meta': serializeParam(
          _meta,
          ParamType.String,
          isList: true,
        ),
        'measures': serializeParam(
          _measures,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static ExtendedIngredientsStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      ExtendedIngredientsStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        aisle: deserializeParam(
          data['aisle'],
          ParamType.String,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        consistency: deserializeParam(
          data['consistency'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        nameClean: deserializeParam(
          data['nameClean'],
          ParamType.String,
          false,
        ),
        original: deserializeParam(
          data['original'],
          ParamType.String,
          false,
        ),
        originalName: deserializeParam(
          data['originalName'],
          ParamType.String,
          false,
        ),
        amount: deserializeParam(
          data['amount'],
          ParamType.String,
          false,
        ),
        unit: deserializeParam(
          data['unit'],
          ParamType.String,
          false,
        ),
        meta: deserializeParam<String>(
          data['meta'],
          ParamType.String,
          true,
        ),
        measures: deserializeStructParam(
          data['measures'],
          ParamType.DataStruct,
          false,
          structBuilder: MeasuresStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'ExtendedIngredientsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ExtendedIngredientsStruct &&
        id == other.id &&
        aisle == other.aisle &&
        image == other.image &&
        consistency == other.consistency &&
        name == other.name &&
        nameClean == other.nameClean &&
        original == other.original &&
        originalName == other.originalName &&
        amount == other.amount &&
        unit == other.unit &&
        listEquality.equals(meta, other.meta) &&
        measures == other.measures;
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        aisle,
        image,
        consistency,
        name,
        nameClean,
        original,
        originalName,
        amount,
        unit,
        meta,
        measures
      ]);
}

ExtendedIngredientsStruct createExtendedIngredientsStruct({
  int? id,
  String? aisle,
  String? image,
  String? consistency,
  String? name,
  String? nameClean,
  String? original,
  String? originalName,
  String? amount,
  String? unit,
  MeasuresStruct? measures,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ExtendedIngredientsStruct(
      id: id,
      aisle: aisle,
      image: image,
      consistency: consistency,
      name: name,
      nameClean: nameClean,
      original: original,
      originalName: originalName,
      amount: amount,
      unit: unit,
      measures: measures ?? (clearUnsetFields ? MeasuresStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ExtendedIngredientsStruct? updateExtendedIngredientsStruct(
  ExtendedIngredientsStruct? extendedIngredients, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    extendedIngredients
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addExtendedIngredientsStructData(
  Map<String, dynamic> firestoreData,
  ExtendedIngredientsStruct? extendedIngredients,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (extendedIngredients == null) {
    return;
  }
  if (extendedIngredients.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && extendedIngredients.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final extendedIngredientsData =
      getExtendedIngredientsFirestoreData(extendedIngredients, forFieldValue);
  final nestedData =
      extendedIngredientsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields =
      extendedIngredients.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getExtendedIngredientsFirestoreData(
  ExtendedIngredientsStruct? extendedIngredients, [
  bool forFieldValue = false,
]) {
  if (extendedIngredients == null) {
    return {};
  }
  final firestoreData = mapToFirestore(extendedIngredients.toMap());

  // Handle nested data for "measures" field.
  addMeasuresStructData(
    firestoreData,
    extendedIngredients.hasMeasures() ? extendedIngredients.measures : null,
    'measures',
    forFieldValue,
  );

  // Add any Firestore field values
  extendedIngredients.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getExtendedIngredientsListFirestoreData(
  List<ExtendedIngredientsStruct>? extendedIngredientss,
) =>
    extendedIngredientss
        ?.map((e) => getExtendedIngredientsFirestoreData(e, true))
        .toList() ??
    [];
