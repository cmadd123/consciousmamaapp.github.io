// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A structured grocery item with quantity parsing and aggregation support.
///
/// Parses ingredient strings like "2 cups flour" into:
/// - quantity: 2.0
/// - unit: "cups"
/// - name: "flour"
///
/// Supports aggregation when the same ingredient with the same unit is added.
class GroceryItemStruct extends FFFirebaseStruct {
  GroceryItemStruct({
    double? quantity,
    String? unit,
    String? name,
    String? originalText,
    bool? isChecked,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _quantity = quantity,
        _unit = unit,
        _name = name,
        _originalText = originalText,
        _isChecked = isChecked,
        super(firestoreUtilData);

  // "quantity" field - numeric amount (e.g., 2.0 for "2 cups")
  double? _quantity;
  double get quantity => _quantity ?? 0.0;
  set quantity(double? val) => _quantity = val;

  void incrementQuantity(double amount) => _quantity = (quantity) + amount;

  bool hasQuantity() => _quantity != null;

  // "unit" field - measurement unit (e.g., "cups", "tbsp", "oz")
  String? _unit;
  String get unit => _unit ?? '';
  set unit(String? val) => _unit = val;

  bool hasUnit() => _unit != null && _unit!.isNotEmpty;

  // "name" field - ingredient name (e.g., "flour", "sugar")
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null && _name!.isNotEmpty;

  // "originalText" field - the original unparsed text
  String? _originalText;
  String get originalText => _originalText ?? '';
  set originalText(String? val) => _originalText = val;

  bool hasOriginalText() => _originalText != null && _originalText!.isNotEmpty;

  // "isChecked" field - whether the item has been checked off
  bool? _isChecked;
  bool get isChecked => _isChecked ?? false;
  set isChecked(bool? val) => _isChecked = val;

  bool hasIsChecked() => _isChecked != null;

  /// Returns a display string like "2 cups flour" or just "flour" if no quantity
  String get displayText {
    if (quantity > 0 && hasUnit()) {
      // Format quantity nicely (remove .0 for whole numbers)
      String qtyStr = quantity == quantity.truncateToDouble()
          ? quantity.toInt().toString()
          : quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '$qtyStr $unit $name'.trim();
    } else if (quantity > 0) {
      String qtyStr = quantity == quantity.truncateToDouble()
          ? quantity.toInt().toString()
          : quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '$qtyStr $name'.trim();
    }
    return name;
  }

  /// Unique key for aggregation - combines normalized name and unit
  String get aggregationKey {
    return '${_normalizeIngredientName(name)}|${_normalizeUnit(unit)}'.toLowerCase();
  }

  /// Check if this item can be aggregated with another
  bool canAggregateWith(GroceryItemStruct other) {
    return aggregationKey == other.aggregationKey;
  }

  /// Create a new GroceryItemStruct by parsing an ingredient string
  static GroceryItemStruct fromIngredientString(String ingredientStr) {
    final parsed = _parseIngredient(ingredientStr);
    return GroceryItemStruct(
      quantity: parsed['quantity'] as double?,
      unit: parsed['unit'] as String?,
      name: parsed['name'] as String?,
      originalText: ingredientStr,
      isChecked: false,
    );
  }

  /// Parse an ingredient string into quantity, unit, and name
  static Map<String, dynamic> _parseIngredient(String ingredientStr) {
    // First, decode any HTML entities that might be in the string
    String text = _decodeHtmlEntities(ingredientStr.trim());
    double? quantity;
    String? unit;
    String name = text;

    // Common unit patterns (case insensitive)
    // NOTE: Avoid single letters (c, g, t, l) as they match first letter of ingredient names
    final unitPatterns = [
      'cups?', 'cup',
      'tablespoons?', 'tbsps?', 'tbsp', 'tbs',
      'teaspoons?', 'tsps?', 'tsp',
      'ounces?', 'oz',
      'pounds?', 'lbs?', 'lb',
      'grams?',
      'kilograms?', 'kg',
      'milliliters?', 'ml',
      'liters?',
      'pints?', 'pt',
      'quarts?', 'qt',
      'gallons?', 'gal',
      'pinch(?:es)?',
      'dash(?:es)?',
      'cloves?',
      'slices?',
      'pieces?',
      'cans?',
      'packages?', 'pkgs?', 'pkg',
      'bunches?',
      'stalks?',
      'heads?',
      'sprigs?',
      'large',
      'medium',
      'small',
    ];

    // Pattern to match: optional quantity (decimal/fraction), optional unit (must be followed by space), then ingredient name
    // Supports: "2 cups flour", "1/2 cup sugar", "2.5 oz cheese", "flour", "1 large egg"
    // Unit must be a complete word (followed by space) to avoid matching first letters
    final quantityPattern = RegExp(
      r'^(\d+(?:\.\d+)?(?:\s*/\s*\d+)?|\d+/\d+)?\s*(?:(' + unitPatterns.join('|') + r')\s+)?(?:of\s+)?(.*)$',
      caseSensitive: false,
    );

    final match = quantityPattern.firstMatch(text);
    if (match != null) {
      final qtyStr = match.group(1);
      final unitStr = match.group(2);
      final nameStr = match.group(3);

      // Parse quantity (handle fractions like "1/2" or "1 1/2")
      if (qtyStr != null && qtyStr.isNotEmpty) {
        quantity = _parseQuantity(qtyStr);
      }

      // Normalize unit
      if (unitStr != null && unitStr.isNotEmpty) {
        unit = _normalizeUnit(unitStr);
      }

      // Set name
      if (nameStr != null && nameStr.isNotEmpty) {
        name = nameStr.trim();
      } else if (unitStr != null) {
        // If we only got a unit with no name, treat the whole thing as name
        name = text;
        unit = null;
        quantity = null;
      }
    }

    return {
      'quantity': quantity,
      'unit': unit,
      'name': name,
    };
  }

  /// Parse a quantity string that might be a fraction
  static double? _parseQuantity(String qtyStr) {
    qtyStr = qtyStr.trim();

    // Check for mixed number like "1 1/2"
    final mixedMatch = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(qtyStr);
    if (mixedMatch != null) {
      final whole = double.parse(mixedMatch.group(1)!);
      final num = double.parse(mixedMatch.group(2)!);
      final denom = double.parse(mixedMatch.group(3)!);
      return whole + (num / denom);
    }

    // Check for simple fraction like "1/2"
    final fractionMatch = RegExp(r'^(\d+)/(\d+)$').firstMatch(qtyStr);
    if (fractionMatch != null) {
      final num = double.parse(fractionMatch.group(1)!);
      final denom = double.parse(fractionMatch.group(2)!);
      return num / denom;
    }

    // Try parsing as decimal
    return double.tryParse(qtyStr);
  }

  /// Normalize unit to a standard form for comparison
  static String _normalizeUnit(String unit) {
    final u = unit.toLowerCase().trim();

    // Map variations to standard units
    final unitMap = {
      'c': 'cup', 'cups': 'cup',
      'tbsp': 'tablespoon', 'tbsps': 'tablespoon', 'tbs': 'tablespoon', 'tablespoons': 'tablespoon',
      'tsp': 'teaspoon', 'tsps': 'teaspoon', 't': 'teaspoon', 'teaspoons': 'teaspoon',
      'oz': 'ounce', 'ounces': 'ounce',
      'lb': 'pound', 'lbs': 'pound', 'pounds': 'pound',
      'g': 'gram', 'grams': 'gram',
      'kg': 'kilogram', 'kilograms': 'kilogram',
      'ml': 'milliliter', 'milliliters': 'milliliter',
      'l': 'liter', 'liters': 'liter',
      'pt': 'pint', 'pints': 'pint',
      'qt': 'quart', 'quarts': 'quart',
      'gal': 'gallon', 'gallons': 'gallon',
      'pkg': 'package', 'pkgs': 'package', 'packages': 'package',
      'pinches': 'pinch',
      'dashes': 'dash',
      'cloves': 'clove',
      'slices': 'slice',
      'pieces': 'piece',
      'cans': 'can',
      'bunches': 'bunch',
      'stalks': 'stalk',
      'heads': 'head',
      'sprigs': 'sprig',
    };

    return unitMap[u] ?? u;
  }

  /// Normalize ingredient name for comparison by removing descriptive adjectives
  /// This allows "freshly cut strawberries" to match "strawberries"
  static String _normalizeIngredientName(String name) {
    String normalized = name.toLowerCase().trim();

    // Remove common cooking/prep adjectives that don't change the base ingredient
    // Order matters - put longer phrases first to avoid partial matches
    final descriptiveWords = [
      // Freshness/state descriptors
      'freshly', 'fresh', 'frozen', 'thawed', 'canned', 'dried', 'raw',
      // Cutting/prep methods
      'finely chopped', 'roughly chopped', 'thinly sliced', 'thickly sliced',
      'finely diced', 'coarsely chopped', 'finely minced',
      'chopped', 'diced', 'sliced', 'minced', 'grated', 'shredded',
      'cubed', 'julienned', 'crushed', 'mashed', 'pureed', 'ground',
      'halved', 'quartered', 'cut', 'trimmed', 'peeled', 'seeded',
      'pitted', 'cored', 'deveined', 'deboned', 'skinless', 'boneless',
      // Temperature
      'room temperature', 'cold', 'warm', 'hot', 'chilled', 'softened', 'melted',
      // Size descriptors
      'small', 'medium', 'large', 'extra large', 'jumbo', 'baby', 'mini',
      // Quality descriptors
      'organic', 'all-purpose', 'all purpose', 'unbleached', 'bleached',
      'unsalted', 'salted', 'low-sodium', 'low sodium', 'reduced-fat', 'reduced fat',
      'nonfat', 'non-fat', 'fat-free', 'fat free', 'whole', 'skim', 'lowfat', 'low-fat',
      // Cooking state
      'cooked', 'uncooked', 'toasted', 'roasted', 'baked', 'fried', 'sauteed',
      'boiled', 'steamed', 'grilled', 'smoked', 'cured', 'brined',
      // Color descriptors (for items where color doesn't matter)
      'white', 'brown', 'golden', 'dark', 'light',
      // Other common descriptors
      'packed', 'loosely packed', 'firmly packed', 'sifted', 'divided',
      'plus more', 'to taste', 'optional', 'for garnish', 'for serving',
    ];

    for (final word in descriptiveWords) {
      // Use word boundaries to avoid matching partial words
      normalized = normalized.replaceAll(RegExp('\\b$word\\b'), '');
    }

    // Clean up multiple spaces and trim
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove leading/trailing punctuation and "of" at the start
    normalized = normalized.replaceAll(RegExp(r'^[\s,]+'), '');
    normalized = normalized.replaceAll(RegExp(r'[\s,]+$'), '');
    normalized = normalized.replaceAll(RegExp(r'^of\s+'), '');

    return normalized;
  }

  /// Decode HTML entities that might be in ingredient strings
  static String _decodeHtmlEntities(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Common HTML entities
    final entities = {
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&quot;': '"',
      '&apos;': "'",
      '&#39;': "'",
      '&#x27;': "'",
      '&nbsp;': ' ',
      '&#160;': ' ',
      '&#8217;': "'",
      '&#8216;': "'",
      '&#8220;': '"',
      '&#8221;': '"',
      '&#189;': '½',
      '&#188;': '¼',
      '&#190;': '¾',
      '&#8211;': '-',
      '&#8212;': '-',
      '&#176;': '°',
    };

    for (final entry in entities.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    // Handle numeric entities (decimal) like &#65;
    result = result.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) => String.fromCharCode(int.parse(match.group(1)!)),
    );

    // Handle numeric entities (hex) like &#x41;
    result = result.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
    );

    return result.trim();
  }

  static GroceryItemStruct fromMap(Map<String, dynamic> data) =>
      GroceryItemStruct(
        quantity: castToType<double>(data['quantity']),
        unit: data['unit'] as String?,
        name: data['name'] as String?,
        originalText: data['originalText'] as String?,
        isChecked: data['isChecked'] as bool?,
      );

  static GroceryItemStruct? maybeFromMap(dynamic data) => data is Map
      ? GroceryItemStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'quantity': _quantity,
        'unit': _unit,
        'name': _name,
        'originalText': _originalText,
        'isChecked': _isChecked,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'quantity': serializeParam(_quantity, ParamType.double),
        'unit': serializeParam(_unit, ParamType.String),
        'name': serializeParam(_name, ParamType.String),
        'originalText': serializeParam(_originalText, ParamType.String),
        'isChecked': serializeParam(_isChecked, ParamType.bool),
      }.withoutNulls;

  static GroceryItemStruct fromSerializableMap(Map<String, dynamic> data) =>
      GroceryItemStruct(
        quantity: deserializeParam(data['quantity'], ParamType.double, false),
        unit: deserializeParam(data['unit'], ParamType.String, false),
        name: deserializeParam(data['name'], ParamType.String, false),
        originalText: deserializeParam(data['originalText'], ParamType.String, false),
        isChecked: deserializeParam(data['isChecked'], ParamType.bool, false),
      );

  @override
  String toString() => 'GroceryItemStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GroceryItemStruct &&
        quantity == other.quantity &&
        unit == other.unit &&
        name == other.name &&
        originalText == other.originalText &&
        isChecked == other.isChecked;
  }

  @override
  int get hashCode => const ListEquality().hash([quantity, unit, name, originalText, isChecked]);
}

GroceryItemStruct createGroceryItemStruct({
  double? quantity,
  String? unit,
  String? name,
  String? originalText,
  bool? isChecked,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    GroceryItemStruct(
      quantity: quantity,
      unit: unit,
      name: name,
      originalText: originalText,
      isChecked: isChecked,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

GroceryItemStruct? updateGroceryItemStruct(
  GroceryItemStruct? groceryItem, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    groceryItem
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addGroceryItemStructData(
  Map<String, dynamic> firestoreData,
  GroceryItemStruct? groceryItem,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (groceryItem == null) {
    return;
  }
  if (groceryItem.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && groceryItem.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final groceryItemData =
      getGroceryItemFirestoreData(groceryItem, forFieldValue);
  final nestedData =
      groceryItemData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = groceryItem.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getGroceryItemFirestoreData(
  GroceryItemStruct? groceryItem, [
  bool forFieldValue = false,
]) {
  if (groceryItem == null) {
    return {};
  }
  final firestoreData = mapToFirestore(groceryItem.toMap());

  // Add any Firestore field values
  groceryItem.firestoreUtilData.fieldValues
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getGroceryItemListFirestoreData(
  List<GroceryItemStruct>? groceryItems,
) =>
    groceryItems
        ?.map((e) => getGroceryItemFirestoreData(e, true))
        .toList() ??
    [];
