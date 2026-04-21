// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ResultsStruct extends FFFirebaseStruct {
  ResultsStruct({
    int? id,
    String? image,
    String? imageType,
    String? title,
    String? readyInMinutes,
    int? servings,
    String? sourceUrl,
    bool? vegetarian,
    bool? vegan,
    bool? glutenFree,
    bool? dairyFree,
    bool? veryHealthy,
    bool? cheap,
    bool? veryPopular,
    bool? sustainable,
    bool? lowFodmap,
    int? weightWatcherSmartPoints,
    String? gaps,
    String? preparationMinutes,
    String? cookingMinutes,
    int? aggregateLikes,
    int? healthScore,
    String? creditsText,
    String? license,
    String? sourceName,
    double? pricePerServing,
    List<ExtendedIngredientsStruct>? extendedIngredients,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _id = id,
        _image = image,
        _imageType = imageType,
        _title = title,
        _readyInMinutes = readyInMinutes,
        _servings = servings,
        _sourceUrl = sourceUrl,
        _vegetarian = vegetarian,
        _vegan = vegan,
        _glutenFree = glutenFree,
        _dairyFree = dairyFree,
        _veryHealthy = veryHealthy,
        _cheap = cheap,
        _veryPopular = veryPopular,
        _sustainable = sustainable,
        _lowFodmap = lowFodmap,
        _weightWatcherSmartPoints = weightWatcherSmartPoints,
        _gaps = gaps,
        _preparationMinutes = preparationMinutes,
        _cookingMinutes = cookingMinutes,
        _aggregateLikes = aggregateLikes,
        _healthScore = healthScore,
        _creditsText = creditsText,
        _license = license,
        _sourceName = sourceName,
        _pricePerServing = pricePerServing,
        _extendedIngredients = extendedIngredients,
        super(firestoreUtilData);

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "imageType" field.
  String? _imageType;
  String get imageType => _imageType ?? '';
  set imageType(String? val) => _imageType = val;

  bool hasImageType() => _imageType != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "readyInMinutes" field.
  String? _readyInMinutes;
  String get readyInMinutes => _readyInMinutes ?? '';
  set readyInMinutes(String? val) => _readyInMinutes = val;

  bool hasReadyInMinutes() => _readyInMinutes != null;

  // "servings" field.
  int? _servings;
  int get servings => _servings ?? 0;
  set servings(int? val) => _servings = val;

  void incrementServings(int amount) => servings = servings + amount;

  bool hasServings() => _servings != null;

  // "sourceUrl" field.
  String? _sourceUrl;
  String get sourceUrl => _sourceUrl ?? '';
  set sourceUrl(String? val) => _sourceUrl = val;

  bool hasSourceUrl() => _sourceUrl != null;

  // "vegetarian" field.
  bool? _vegetarian;
  bool get vegetarian => _vegetarian ?? false;
  set vegetarian(bool? val) => _vegetarian = val;

  bool hasVegetarian() => _vegetarian != null;

  // "vegan" field.
  bool? _vegan;
  bool get vegan => _vegan ?? false;
  set vegan(bool? val) => _vegan = val;

  bool hasVegan() => _vegan != null;

  // "glutenFree" field.
  bool? _glutenFree;
  bool get glutenFree => _glutenFree ?? false;
  set glutenFree(bool? val) => _glutenFree = val;

  bool hasGlutenFree() => _glutenFree != null;

  // "dairyFree" field.
  bool? _dairyFree;
  bool get dairyFree => _dairyFree ?? false;
  set dairyFree(bool? val) => _dairyFree = val;

  bool hasDairyFree() => _dairyFree != null;

  // "veryHealthy" field.
  bool? _veryHealthy;
  bool get veryHealthy => _veryHealthy ?? false;
  set veryHealthy(bool? val) => _veryHealthy = val;

  bool hasVeryHealthy() => _veryHealthy != null;

  // "cheap" field.
  bool? _cheap;
  bool get cheap => _cheap ?? false;
  set cheap(bool? val) => _cheap = val;

  bool hasCheap() => _cheap != null;

  // "veryPopular" field.
  bool? _veryPopular;
  bool get veryPopular => _veryPopular ?? false;
  set veryPopular(bool? val) => _veryPopular = val;

  bool hasVeryPopular() => _veryPopular != null;

  // "sustainable" field.
  bool? _sustainable;
  bool get sustainable => _sustainable ?? false;
  set sustainable(bool? val) => _sustainable = val;

  bool hasSustainable() => _sustainable != null;

  // "lowFodmap" field.
  bool? _lowFodmap;
  bool get lowFodmap => _lowFodmap ?? false;
  set lowFodmap(bool? val) => _lowFodmap = val;

  bool hasLowFodmap() => _lowFodmap != null;

  // "weightWatcherSmartPoints" field.
  int? _weightWatcherSmartPoints;
  int get weightWatcherSmartPoints => _weightWatcherSmartPoints ?? 0;
  set weightWatcherSmartPoints(int? val) => _weightWatcherSmartPoints = val;

  void incrementWeightWatcherSmartPoints(int amount) =>
      weightWatcherSmartPoints = weightWatcherSmartPoints + amount;

  bool hasWeightWatcherSmartPoints() => _weightWatcherSmartPoints != null;

  // "gaps" field.
  String? _gaps;
  String get gaps => _gaps ?? '';
  set gaps(String? val) => _gaps = val;

  bool hasGaps() => _gaps != null;

  // "preparationMinutes" field.
  String? _preparationMinutes;
  String get preparationMinutes => _preparationMinutes ?? '';
  set preparationMinutes(String? val) => _preparationMinutes = val;

  bool hasPreparationMinutes() => _preparationMinutes != null;

  // "cookingMinutes" field.
  String? _cookingMinutes;
  String get cookingMinutes => _cookingMinutes ?? '';
  set cookingMinutes(String? val) => _cookingMinutes = val;

  bool hasCookingMinutes() => _cookingMinutes != null;

  // "aggregateLikes" field.
  int? _aggregateLikes;
  int get aggregateLikes => _aggregateLikes ?? 0;
  set aggregateLikes(int? val) => _aggregateLikes = val;

  void incrementAggregateLikes(int amount) =>
      aggregateLikes = aggregateLikes + amount;

  bool hasAggregateLikes() => _aggregateLikes != null;

  // "healthScore" field.
  int? _healthScore;
  int get healthScore => _healthScore ?? 0;
  set healthScore(int? val) => _healthScore = val;

  void incrementHealthScore(int amount) => healthScore = healthScore + amount;

  bool hasHealthScore() => _healthScore != null;

  // "creditsText" field.
  String? _creditsText;
  String get creditsText => _creditsText ?? '';
  set creditsText(String? val) => _creditsText = val;

  bool hasCreditsText() => _creditsText != null;

  // "license" field.
  String? _license;
  String get license => _license ?? '';
  set license(String? val) => _license = val;

  bool hasLicense() => _license != null;

  // "sourceName" field.
  String? _sourceName;
  String get sourceName => _sourceName ?? '';
  set sourceName(String? val) => _sourceName = val;

  bool hasSourceName() => _sourceName != null;

  // "pricePerServing" field.
  double? _pricePerServing;
  double get pricePerServing => _pricePerServing ?? 0.0;
  set pricePerServing(double? val) => _pricePerServing = val;

  void incrementPricePerServing(double amount) =>
      pricePerServing = pricePerServing + amount;

  bool hasPricePerServing() => _pricePerServing != null;

  // "extendedIngredients" field.
  List<ExtendedIngredientsStruct>? _extendedIngredients;
  List<ExtendedIngredientsStruct> get extendedIngredients =>
      _extendedIngredients ?? const [];
  set extendedIngredients(List<ExtendedIngredientsStruct>? val) =>
      _extendedIngredients = val;

  void updateExtendedIngredients(
      Function(List<ExtendedIngredientsStruct>) updateFn) {
    updateFn(_extendedIngredients ??= []);
  }

  bool hasExtendedIngredients() => _extendedIngredients != null;

  static ResultsStruct fromMap(Map<String, dynamic> data) => ResultsStruct(
        id: castToType<int>(data['id']),
        image: data['image'] as String?,
        imageType: data['imageType'] as String?,
        title: data['title'] as String?,
        readyInMinutes: data['readyInMinutes'] as String?,
        servings: castToType<int>(data['servings']),
        sourceUrl: data['sourceUrl'] as String?,
        vegetarian: data['vegetarian'] as bool?,
        vegan: data['vegan'] as bool?,
        glutenFree: data['glutenFree'] as bool?,
        dairyFree: data['dairyFree'] as bool?,
        veryHealthy: data['veryHealthy'] as bool?,
        cheap: data['cheap'] as bool?,
        veryPopular: data['veryPopular'] as bool?,
        sustainable: data['sustainable'] as bool?,
        lowFodmap: data['lowFodmap'] as bool?,
        weightWatcherSmartPoints:
            castToType<int>(data['weightWatcherSmartPoints']),
        gaps: data['gaps'] as String?,
        preparationMinutes: data['preparationMinutes'] as String?,
        cookingMinutes: data['cookingMinutes'] as String?,
        aggregateLikes: castToType<int>(data['aggregateLikes']),
        healthScore: castToType<int>(data['healthScore']),
        creditsText: data['creditsText'] as String?,
        license: data['license'] as String?,
        sourceName: data['sourceName'] as String?,
        pricePerServing: castToType<double>(data['pricePerServing']),
        extendedIngredients: getStructList(
          data['extendedIngredients'],
          ExtendedIngredientsStruct.fromMap,
        ),
      );

  static ResultsStruct? maybeFromMap(dynamic data) =>
      data is Map ? ResultsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'image': _image,
        'imageType': _imageType,
        'title': _title,
        'readyInMinutes': _readyInMinutes,
        'servings': _servings,
        'sourceUrl': _sourceUrl,
        'vegetarian': _vegetarian,
        'vegan': _vegan,
        'glutenFree': _glutenFree,
        'dairyFree': _dairyFree,
        'veryHealthy': _veryHealthy,
        'cheap': _cheap,
        'veryPopular': _veryPopular,
        'sustainable': _sustainable,
        'lowFodmap': _lowFodmap,
        'weightWatcherSmartPoints': _weightWatcherSmartPoints,
        'gaps': _gaps,
        'preparationMinutes': _preparationMinutes,
        'cookingMinutes': _cookingMinutes,
        'aggregateLikes': _aggregateLikes,
        'healthScore': _healthScore,
        'creditsText': _creditsText,
        'license': _license,
        'sourceName': _sourceName,
        'pricePerServing': _pricePerServing,
        'extendedIngredients':
            _extendedIngredients?.map((e) => e.toMap()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'imageType': serializeParam(
          _imageType,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'readyInMinutes': serializeParam(
          _readyInMinutes,
          ParamType.String,
        ),
        'servings': serializeParam(
          _servings,
          ParamType.int,
        ),
        'sourceUrl': serializeParam(
          _sourceUrl,
          ParamType.String,
        ),
        'vegetarian': serializeParam(
          _vegetarian,
          ParamType.bool,
        ),
        'vegan': serializeParam(
          _vegan,
          ParamType.bool,
        ),
        'glutenFree': serializeParam(
          _glutenFree,
          ParamType.bool,
        ),
        'dairyFree': serializeParam(
          _dairyFree,
          ParamType.bool,
        ),
        'veryHealthy': serializeParam(
          _veryHealthy,
          ParamType.bool,
        ),
        'cheap': serializeParam(
          _cheap,
          ParamType.bool,
        ),
        'veryPopular': serializeParam(
          _veryPopular,
          ParamType.bool,
        ),
        'sustainable': serializeParam(
          _sustainable,
          ParamType.bool,
        ),
        'lowFodmap': serializeParam(
          _lowFodmap,
          ParamType.bool,
        ),
        'weightWatcherSmartPoints': serializeParam(
          _weightWatcherSmartPoints,
          ParamType.int,
        ),
        'gaps': serializeParam(
          _gaps,
          ParamType.String,
        ),
        'preparationMinutes': serializeParam(
          _preparationMinutes,
          ParamType.String,
        ),
        'cookingMinutes': serializeParam(
          _cookingMinutes,
          ParamType.String,
        ),
        'aggregateLikes': serializeParam(
          _aggregateLikes,
          ParamType.int,
        ),
        'healthScore': serializeParam(
          _healthScore,
          ParamType.int,
        ),
        'creditsText': serializeParam(
          _creditsText,
          ParamType.String,
        ),
        'license': serializeParam(
          _license,
          ParamType.String,
        ),
        'sourceName': serializeParam(
          _sourceName,
          ParamType.String,
        ),
        'pricePerServing': serializeParam(
          _pricePerServing,
          ParamType.double,
        ),
        'extendedIngredients': serializeParam(
          _extendedIngredients,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static ResultsStruct fromSerializableMap(Map<String, dynamic> data) =>
      ResultsStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        imageType: deserializeParam(
          data['imageType'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        readyInMinutes: deserializeParam(
          data['readyInMinutes'],
          ParamType.String,
          false,
        ),
        servings: deserializeParam(
          data['servings'],
          ParamType.int,
          false,
        ),
        sourceUrl: deserializeParam(
          data['sourceUrl'],
          ParamType.String,
          false,
        ),
        vegetarian: deserializeParam(
          data['vegetarian'],
          ParamType.bool,
          false,
        ),
        vegan: deserializeParam(
          data['vegan'],
          ParamType.bool,
          false,
        ),
        glutenFree: deserializeParam(
          data['glutenFree'],
          ParamType.bool,
          false,
        ),
        dairyFree: deserializeParam(
          data['dairyFree'],
          ParamType.bool,
          false,
        ),
        veryHealthy: deserializeParam(
          data['veryHealthy'],
          ParamType.bool,
          false,
        ),
        cheap: deserializeParam(
          data['cheap'],
          ParamType.bool,
          false,
        ),
        veryPopular: deserializeParam(
          data['veryPopular'],
          ParamType.bool,
          false,
        ),
        sustainable: deserializeParam(
          data['sustainable'],
          ParamType.bool,
          false,
        ),
        lowFodmap: deserializeParam(
          data['lowFodmap'],
          ParamType.bool,
          false,
        ),
        weightWatcherSmartPoints: deserializeParam(
          data['weightWatcherSmartPoints'],
          ParamType.int,
          false,
        ),
        gaps: deserializeParam(
          data['gaps'],
          ParamType.String,
          false,
        ),
        preparationMinutes: deserializeParam(
          data['preparationMinutes'],
          ParamType.String,
          false,
        ),
        cookingMinutes: deserializeParam(
          data['cookingMinutes'],
          ParamType.String,
          false,
        ),
        aggregateLikes: deserializeParam(
          data['aggregateLikes'],
          ParamType.int,
          false,
        ),
        healthScore: deserializeParam(
          data['healthScore'],
          ParamType.int,
          false,
        ),
        creditsText: deserializeParam(
          data['creditsText'],
          ParamType.String,
          false,
        ),
        license: deserializeParam(
          data['license'],
          ParamType.String,
          false,
        ),
        sourceName: deserializeParam(
          data['sourceName'],
          ParamType.String,
          false,
        ),
        pricePerServing: deserializeParam(
          data['pricePerServing'],
          ParamType.double,
          false,
        ),
        extendedIngredients: deserializeStructParam<ExtendedIngredientsStruct>(
          data['extendedIngredients'],
          ParamType.DataStruct,
          true,
          structBuilder: ExtendedIngredientsStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'ResultsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ResultsStruct &&
        id == other.id &&
        image == other.image &&
        imageType == other.imageType &&
        title == other.title &&
        readyInMinutes == other.readyInMinutes &&
        servings == other.servings &&
        sourceUrl == other.sourceUrl &&
        vegetarian == other.vegetarian &&
        vegan == other.vegan &&
        glutenFree == other.glutenFree &&
        dairyFree == other.dairyFree &&
        veryHealthy == other.veryHealthy &&
        cheap == other.cheap &&
        veryPopular == other.veryPopular &&
        sustainable == other.sustainable &&
        lowFodmap == other.lowFodmap &&
        weightWatcherSmartPoints == other.weightWatcherSmartPoints &&
        gaps == other.gaps &&
        preparationMinutes == other.preparationMinutes &&
        cookingMinutes == other.cookingMinutes &&
        aggregateLikes == other.aggregateLikes &&
        healthScore == other.healthScore &&
        creditsText == other.creditsText &&
        license == other.license &&
        sourceName == other.sourceName &&
        pricePerServing == other.pricePerServing &&
        listEquality.equals(extendedIngredients, other.extendedIngredients);
  }

  @override
  int get hashCode => const ListEquality().hash([
        id,
        image,
        imageType,
        title,
        readyInMinutes,
        servings,
        sourceUrl,
        vegetarian,
        vegan,
        glutenFree,
        dairyFree,
        veryHealthy,
        cheap,
        veryPopular,
        sustainable,
        lowFodmap,
        weightWatcherSmartPoints,
        gaps,
        preparationMinutes,
        cookingMinutes,
        aggregateLikes,
        healthScore,
        creditsText,
        license,
        sourceName,
        pricePerServing,
        extendedIngredients
      ]);
}

ResultsStruct createResultsStruct({
  int? id,
  String? image,
  String? imageType,
  String? title,
  String? readyInMinutes,
  int? servings,
  String? sourceUrl,
  bool? vegetarian,
  bool? vegan,
  bool? glutenFree,
  bool? dairyFree,
  bool? veryHealthy,
  bool? cheap,
  bool? veryPopular,
  bool? sustainable,
  bool? lowFodmap,
  int? weightWatcherSmartPoints,
  String? gaps,
  String? preparationMinutes,
  String? cookingMinutes,
  int? aggregateLikes,
  int? healthScore,
  String? creditsText,
  String? license,
  String? sourceName,
  double? pricePerServing,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ResultsStruct(
      id: id,
      image: image,
      imageType: imageType,
      title: title,
      readyInMinutes: readyInMinutes,
      servings: servings,
      sourceUrl: sourceUrl,
      vegetarian: vegetarian,
      vegan: vegan,
      glutenFree: glutenFree,
      dairyFree: dairyFree,
      veryHealthy: veryHealthy,
      cheap: cheap,
      veryPopular: veryPopular,
      sustainable: sustainable,
      lowFodmap: lowFodmap,
      weightWatcherSmartPoints: weightWatcherSmartPoints,
      gaps: gaps,
      preparationMinutes: preparationMinutes,
      cookingMinutes: cookingMinutes,
      aggregateLikes: aggregateLikes,
      healthScore: healthScore,
      creditsText: creditsText,
      license: license,
      sourceName: sourceName,
      pricePerServing: pricePerServing,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ResultsStruct? updateResultsStruct(
  ResultsStruct? results, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    results
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addResultsStructData(
  Map<String, dynamic> firestoreData,
  ResultsStruct? results,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (results == null) {
    return;
  }
  if (results.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && results.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final resultsData = getResultsFirestoreData(results, forFieldValue);
  final nestedData = resultsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = results.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getResultsFirestoreData(
  ResultsStruct? results, [
  bool forFieldValue = false,
]) {
  if (results == null) {
    return {};
  }
  final firestoreData = mapToFirestore(results.toMap());

  // Add any Firestore field values
  results.firestoreUtilData.fieldValues.forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getResultsListFirestoreData(
  List<ResultsStruct>? resultss,
) =>
    resultss?.map((e) => getResultsFirestoreData(e, true)).toList() ?? [];
