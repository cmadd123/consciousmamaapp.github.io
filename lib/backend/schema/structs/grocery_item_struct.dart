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
      String qtyStr = _formatQuantity(quantity);
      String displayUnit = _pluralizeUnit(unit, quantity);
      return '$qtyStr $displayUnit $name'.trim();
    } else if (quantity > 0) {
      String qtyStr = _formatQuantity(quantity);
      return '$qtyStr $name'.trim();
    }
    return name;
  }

  /// Pluralize unit based on quantity (e.g., "1 cup" vs "2 cups")
  static String _pluralizeUnit(String unit, double quantity) {
    // Don't pluralize if quantity is exactly 1
    if (quantity == 1.0) {
      return unit;
    }

    // Units that need 's' for plural
    final needsS = ['cup', 'tablespoon', 'teaspoon', 'stick', 'ounce', 'pound',
                    'gram', 'kilogram', 'milliliter', 'liter', 'pint', 'quart',
                    'gallon', 'package', 'can', 'piece', 'slice'];

    if (needsS.contains(unit)) {
      return '${unit}s';
    }

    // Units already plural or don't change
    return unit;
  }

  /// Format quantity as fraction or decimal
  static String _formatQuantity(double qty) {
    // Whole numbers - just return as int
    if (qty == qty.truncateToDouble()) {
      return qty.toInt().toString();
    }

    // Try to represent as a simple fraction
    final fraction = _toFraction(qty);
    if (fraction != null) {
      return fraction;
    }

    // Fall back to decimal (max 2 decimal places, trim trailing zeros)
    return qty.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Convert decimal to common cooking fraction (e.g., 1.333... -> "1 1/3")
  static String? _toFraction(double value) {
    final whole = value.truncate();
    final decimal = value - whole;

    // If very close to whole number, just return whole
    if (decimal.abs() < 0.02) {
      return whole.toString();
    }

    // Common cooking fractions (tolerance 0.02 for better matching)
    // Sorted by value for easier reading
    final fractions = {
      0.0625: '1/16',
      0.125: '1/8',
      0.1667: '1/6',
      0.1875: '3/16',
      0.200: '1/5',
      0.250: '1/4',
      0.3125: '5/16',
      0.3333: '1/3',
      0.375: '3/8',
      0.400: '2/5',
      0.4375: '7/16',
      0.500: '1/2',
      0.5625: '9/16',
      0.600: '3/5',
      0.625: '5/8',
      0.6667: '2/3',
      0.6875: '11/16',
      0.750: '3/4',
      0.800: '4/5',
      0.8125: '13/16',
      0.8333: '5/6',
      0.875: '7/8',
      0.9375: '15/16',
    };

    for (var entry in fractions.entries) {
      if ((decimal - entry.key).abs() < 0.02) {
        if (whole == 0) {
          return entry.value;
        }
        return '$whole ${entry.value}';
      }
    }

    return null; // No simple fraction found
  }

  /// Unique key for aggregation - combines normalized name and unit
  String get aggregationKey {
    return '${_normalizeIngredientName(name)}|${_normalizeUnit(unit)}'.toLowerCase();
  }

  /// Check if this item can be aggregated with another
  /// Returns true if same ingredient and compatible units
  bool canAggregateWith(GroceryItemStruct other) {
    // Same ingredient name?
    if (_normalizeIngredientName(name) != _normalizeIngredientName(other.name)) {
      return false;
    }

    // Same unit or compatible units?
    final myUnit = _normalizeUnit(unit);
    final otherUnit = _normalizeUnit(other.unit);

    return myUnit == otherUnit || _areUnitsCompatible(myUnit, otherUnit);
  }

  /// Check if two units are compatible for conversion
  static bool _areUnitsCompatible(String unit1, String unit2) {
    // Volume conversions (stick is volume for butter)
    const volumeUnits = ['teaspoon', 'tablespoon', 'cup', 'stick', 'milliliter', 'liter'];
    if (volumeUnits.contains(unit1) && volumeUnits.contains(unit2)) {
      return true;
    }

    // Weight conversions
    const weightUnits = ['ounce', 'pound', 'gram', 'kilogram'];
    if (weightUnits.contains(unit1) && weightUnits.contains(unit2)) {
      return true;
    }

    return false;
  }

  /// Convert quantity to a standard unit and return converted value
  /// Returns a tuple of (quantity, standardUnit)
  static Map<String, dynamic> _convertToStandardUnit(double quantity, String unit) {
    final normalized = _normalizeUnit(unit);

    // Volume conversions (standard: tablespoon)
    switch (normalized) {
      case 'teaspoon':
        return {'quantity': quantity / 3, 'unit': 'tablespoon'};
      case 'tablespoon':
        return {'quantity': quantity, 'unit': 'tablespoon'};
      case 'stick':
        return {'quantity': quantity * 8, 'unit': 'tablespoon'}; // 1 stick = 8 tbsp
      case 'cup':
        return {'quantity': quantity * 16, 'unit': 'tablespoon'};
      case 'milliliter':
        return {'quantity': quantity / 14.787, 'unit': 'tablespoon'};
      case 'liter':
        return {'quantity': quantity * 67.628, 'unit': 'tablespoon'};
    }

    // Weight conversions (standard: ounce)
    switch (normalized) {
      case 'ounce':
        return {'quantity': quantity, 'unit': 'ounce'};
      case 'pound':
        return {'quantity': quantity * 16, 'unit': 'ounce'};
      case 'gram':
        return {'quantity': quantity / 28.35, 'unit': 'ounce'};
      case 'kilogram':
        return {'quantity': quantity * 35.274, 'unit': 'ounce'};
    }

    // No conversion needed
    return {'quantity': quantity, 'unit': normalized};
  }

  /// Get the preferred display unit for an ingredient based on cooking conventions
  static String _getPreferredUnit(String ingredientName, double quantity, String currentUnit) {
    final normalized = _normalizeIngredientName(ingredientName).toLowerCase();

    // Butter, margarine, shortening - prefer tablespoons, then sticks
    if (normalized.contains('butter') || normalized.contains('margarine') || normalized.contains('shortening')) {
      if (currentUnit == 'tablespoon') {
        // 8 tbsp = 1 stick, keep as tablespoons unless it's a clean stick count
        if (quantity >= 8 && quantity % 8 == 0) {
          return 'stick';
        }
        return 'tablespoon';
      }
      return currentUnit;
    }

    // Sugar, flour - prefer cups for larger amounts, tablespoons for small
    if (normalized.contains('sugar') || normalized.contains('flour')) {
      if (currentUnit == 'tablespoon' && quantity >= 4) {
        return 'cup';
      }
      return currentUnit;
    }

    // Liquids (milk, water, broth, stock, juice, oil) - prefer cups
    if (normalized.contains('milk') || normalized.contains('water') || normalized.contains('broth') ||
        normalized.contains('stock') || normalized.contains('juice') || normalized.contains('oil') ||
        normalized.contains('cream')) {
      if (currentUnit == 'tablespoon' && quantity >= 4) {
        return 'cup';
      }
      return currentUnit;
    }

    // Spices, extracts, small seasonings - prefer teaspoons
    if (normalized.contains('extract') || normalized.contains('vanilla') || normalized.contains('cinnamon') ||
        normalized.contains('salt') || normalized.contains('pepper') || normalized.contains('spice') ||
        normalized.contains('baking powder') || normalized.contains('baking soda')) {
      if (currentUnit == 'tablespoon' && quantity < 3) {
        return 'teaspoon';
      }
      return currentUnit;
    }

    // Cheese - prefer cups when shredded/grated, ounces when in blocks
    if (normalized.contains('cheese')) {
      if (currentUnit == 'tablespoon') {
        return 'cup'; // Shredded cheese
      }
      return currentUnit;
    }

    // Default: no preference
    return currentUnit;
  }

  /// Combine this item with another, handling unit conversion
  void combineWith(GroceryItemStruct other) {
    // Convert both to standard units
    final myConverted = _convertToStandardUnit(quantity, unit);
    final otherConverted = _convertToStandardUnit(other.quantity, other.unit);

    // Add quantities in standard unit
    var totalQuantity = (myConverted['quantity'] as double) + (otherConverted['quantity'] as double);
    var displayUnit = myConverted['unit'] as String;

    // Apply ingredient-specific preferred units
    final preferredUnit = _getPreferredUnit(name, totalQuantity, displayUnit);

    if (preferredUnit != displayUnit) {
      // Convert to preferred unit
      if (displayUnit == 'tablespoon' && preferredUnit == 'cup') {
        totalQuantity = totalQuantity / 16;
        displayUnit = 'cup';
      } else if (displayUnit == 'tablespoon' && preferredUnit == 'teaspoon') {
        totalQuantity = totalQuantity * 3;
        displayUnit = 'teaspoon';
      } else if (displayUnit == 'tablespoon' && preferredUnit == 'stick') {
        totalQuantity = totalQuantity / 8;
        displayUnit = 'stick';
      }
    } else {
      // Generic fallback for non-specific ingredients
      // For volume: if tablespoons >= 3, convert to cups for easier reading
      if (displayUnit == 'tablespoon' && totalQuantity >= 3) {
        totalQuantity = totalQuantity / 16;
        displayUnit = 'cup';
      }

      // For weight: if ounces >= 16, convert to pounds for easier reading
      if (displayUnit == 'ounce' && totalQuantity >= 16) {
        totalQuantity = totalQuantity / 16;
        displayUnit = 'pound';
      }
    }

    // Update this item with combined quantity in best display unit
    _quantity = totalQuantity;
    _unit = displayUnit;
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
      'sticks': 'stick', // 1 stick butter = 8 tbsp = 1/2 cup
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

    // Normalize plurals to singular form
    normalized = _singularize(normalized);

    return normalized;
  }

  /// Convert plural ingredient names to singular for better matching
  static String _singularize(String word) {
    if (word.isEmpty) return word;

    // Common irregular plurals
    final irregularPlurals = {
      'tomatoes': 'tomato',
      'potatoes': 'potato',
      'cherries': 'cherry',
      'strawberries': 'strawberry',
      'blueberries': 'blueberry',
      'raspberries': 'raspberry',
      'blackberries': 'blackberry',
      'cranberries': 'cranberry',
      'loaves': 'loaf',
      'halves': 'half',
      'knives': 'knife',
      'leaves': 'leaf',
    };

    // Check for exact irregular plural match
    if (irregularPlurals.containsKey(word)) {
      return irregularPlurals[word]!;
    }

    // Check for irregular plurals in the last word (for multi-word ingredients)
    final words = word.split(' ');
    if (words.length > 1) {
      final lastWord = words.last;
      if (irregularPlurals.containsKey(lastWord)) {
        words[words.length - 1] = irregularPlurals[lastWord]!;
        return words.join(' ');
      }
    }

    // Regular plural rules (apply to last word only for multi-word ingredients)
    String processWord(String w) {
      // Words ending in "ies" -> "y" (berries -> berry)
      if (w.endsWith('ies') && w.length > 4) {
        return '${w.substring(0, w.length - 3)}y';
      }
      // Words ending in "oes" -> "o" (tomatoes -> tomato)
      if (w.endsWith('oes') && w.length > 4) {
        return w.substring(0, w.length - 2);
      }
      // Words ending in "ses" -> "s" (glasses -> glass)
      if (w.endsWith('ses') && w.length > 4) {
        return w.substring(0, w.length - 2);
      }
      // Words ending in "xes" -> "x" (boxes -> box)
      if (w.endsWith('xes') && w.length > 4) {
        return w.substring(0, w.length - 2);
      }
      // Words ending in "ches", "shes" -> remove "es"
      if ((w.endsWith('ches') || w.endsWith('shes')) && w.length > 5) {
        return w.substring(0, w.length - 2);
      }
      // Words ending in "s" but not "ss" -> remove "s"
      if (w.endsWith('s') && !w.endsWith('ss') && w.length > 2) {
        return w.substring(0, w.length - 1);
      }
      return w;
    }

    if (words.length > 1) {
      words[words.length - 1] = processWord(words.last);
      return words.join(' ');
    }

    return processWord(word);
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
