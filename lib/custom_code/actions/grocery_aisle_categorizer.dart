/// Categorizes grocery ingredients into store aisles using keyword matching.
/// Used by the grocery list UI to group items by section.
library;

class GroceryAisleCategorizer {
  GroceryAisleCategorizer._();

  /// Returns the aisle/category name for a given ingredient name.
  static String categorize(String ingredientName) {
    final lower = ingredientName.toLowerCase().trim();

    // Check each category's keywords
    for (final entry in _aisleKeywords.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Other';
  }

  /// Emoji icon for each aisle category.
  static String emojiFor(String aisle) {
    return _aisleEmojis[aisle] ?? '🛒';
  }

  /// Sort order for aisles (matches typical grocery store layout).
  static int sortOrder(String aisle) {
    return _aisleSortOrder[aisle] ?? 99;
  }

  static const _aisleEmojis = {
    'Produce': '🥬',
    'Dairy & Eggs': '🥛',
    'Meat & Seafood': '🥩',
    'Bakery': '🍞',
    'Pantry': '🥫',
    'Baking': '🧁',
    'Condiments & Sauces': '🫙',
    'Frozen': '🧊',
    'Beverages': '🥤',
    'Spices': '🌿',
    'Other': '🛒',
  };

  static const _aisleSortOrder = {
    'Produce': 0,
    'Bakery': 1,
    'Dairy & Eggs': 2,
    'Meat & Seafood': 3,
    'Pantry': 4,
    'Baking': 5,
    'Condiments & Sauces': 6,
    'Spices': 7,
    'Frozen': 8,
    'Beverages': 9,
    'Other': 10,
  };

  static const _aisleKeywords = {
    'Produce': [
      // Vegetables
      'lettuce', 'spinach', 'kale', 'arugula', 'cabbage', 'broccoli',
      'cauliflower', 'carrot', 'celery', 'cucumber', 'tomato', 'tomatoes',
      'pepper', 'bell pepper', 'jalapeño', 'jalapeno', 'onion', 'shallot',
      'garlic', 'ginger', 'potato', 'potatoes', 'sweet potato',
      'zucchini', 'squash', 'eggplant', 'mushroom', 'corn', 'pea',
      'green bean', 'asparagus', 'artichoke', 'beet', 'radish',
      'turnip', 'parsnip', 'leek', 'scallion', 'green onion',
      'avocado', 'edamame', 'sprout', 'bok choy', 'okra',
      // Fruits
      'apple', 'banana', 'orange', 'lemon', 'lime', 'grapefruit',
      'strawberr', 'blueberr', 'raspberr', 'blackberr', 'cranberr',
      'grape', 'cherry', 'cherries', 'peach', 'pear', 'plum', 'mango',
      'pineapple', 'watermelon', 'cantaloupe', 'honeydew', 'kiwi',
      'pomegranate', 'fig', 'date', 'coconut', 'papaya', 'passion fruit',
      'nectarine', 'apricot', 'tangerine', 'clementine', 'mandarin',
      // Fresh herbs
      'fresh basil', 'fresh cilantro', 'fresh parsley', 'fresh mint',
      'fresh dill', 'fresh rosemary', 'fresh thyme', 'fresh sage',
      'fresh chive', 'fresh oregano', 'fresh tarragon',
    ],
    'Dairy & Eggs': [
      'milk', 'cream', 'half and half', 'half-and-half',
      'butter', 'margarine',
      'cheese', 'cheddar', 'mozzarella', 'parmesan', 'swiss', 'brie',
      'gouda', 'feta', 'ricotta', 'cream cheese', 'cottage cheese',
      'mascarpone', 'gruyere', 'provolone', 'colby', 'monterey jack',
      'yogurt', 'greek yogurt', 'sour cream', 'crème fraîche',
      'egg', 'eggs',
      'whipped cream', 'cool whip',
    ],
    'Meat & Seafood': [
      'chicken', 'beef', 'pork', 'turkey', 'lamb', 'veal', 'duck',
      'steak', 'ground beef', 'ground turkey', 'ground pork',
      'bacon', 'sausage', 'ham', 'salami', 'pepperoni', 'prosciutto',
      'hot dog', 'brat', 'chorizo', 'kielbasa',
      'salmon', 'tuna', 'shrimp', 'prawn', 'crab', 'lobster',
      'cod', 'tilapia', 'halibut', 'mahi', 'swordfish', 'trout',
      'scallop', 'clam', 'mussel', 'oyster', 'anchov',
      'fish', 'seafood',
    ],
    'Bakery': [
      'bread', 'bagel', 'english muffin', 'croissant', 'baguette',
      'pita', 'naan', 'tortilla', 'wrap', 'flatbread',
      'roll', 'bun', 'hamburger bun', 'hot dog bun',
      'cake', 'cupcake', 'muffin', 'donut', 'doughnut', 'pastry',
      'pie crust', 'crouton',
    ],
    'Pantry': [
      'pasta', 'spaghetti', 'penne', 'fettuccine', 'linguine',
      'macaroni', 'rigatoni', 'orzo', 'lasagna', 'noodle',
      'rice', 'quinoa', 'couscous', 'bulgur', 'farro', 'barley',
      'oat', 'oatmeal', 'granola', 'cereal', 'muesli',
      'bean', 'lentil', 'chickpea', 'black bean', 'kidney bean',
      'pinto bean', 'navy bean', 'cannellini',
      'canned tomato', 'tomato sauce', 'tomato paste', 'diced tomato',
      'crushed tomato', 'marinara', 'pasta sauce',
      'broth', 'stock', 'bouillon',
      'tuna can', 'canned tuna', 'canned chicken', 'canned salmon',
      'soup', 'canned soup',
      'peanut butter', 'almond butter', 'jam', 'jelly', 'preserve',
      'honey', 'maple syrup', 'agave',
      'nut', 'almond', 'walnut', 'pecan', 'cashew', 'pistachio',
      'peanut', 'sunflower seed', 'pumpkin seed', 'chia seed',
      'flax seed', 'sesame seed',
      'olive oil', 'vegetable oil', 'canola oil', 'coconut oil',
      'avocado oil', 'sesame oil', 'oil',
      'vinegar', 'apple cider vinegar', 'balsamic', 'red wine vinegar',
      'white vinegar', 'rice vinegar',
      'cracker', 'chip', 'pretzel', 'popcorn',
      'raisin', 'dried fruit', 'dried cranberr',
    ],
    'Baking': [
      'flour', 'all-purpose flour', 'bread flour', 'cake flour',
      'whole wheat flour', 'almond flour', 'coconut flour',
      'sugar', 'brown sugar', 'powdered sugar', 'confectioner',
      'baking soda', 'baking powder', 'yeast',
      'vanilla extract', 'vanilla', 'almond extract',
      'cocoa powder', 'chocolate chip', 'chocolate',
      'cornstarch', 'corn starch', 'cornmeal',
      'gelatin', 'pectin',
      'food coloring', 'sprinkle',
      'condensed milk', 'evaporated milk',
    ],
    'Condiments & Sauces': [
      'ketchup', 'mustard', 'mayonnaise', 'mayo',
      'soy sauce', 'teriyaki', 'worcestershire', 'fish sauce',
      'hot sauce', 'sriracha', 'tabasco', 'buffalo sauce',
      'bbq sauce', 'barbecue sauce',
      'salsa', 'guacamole', 'hummus',
      'salad dressing', 'ranch', 'caesar dressing',
      'relish', 'pickle', 'olive',
      'hoisin', 'oyster sauce', 'chili sauce', 'sambal',
      'tahini', 'miso',
      'pesto',
    ],
    'Spices': [
      'salt', 'pepper', 'black pepper', 'white pepper',
      'paprika', 'smoked paprika', 'cayenne',
      'cumin', 'coriander', 'turmeric', 'curry powder', 'curry paste',
      'chili powder', 'chili flake', 'red pepper flake',
      'cinnamon', 'nutmeg', 'allspice', 'clove', 'cardamom',
      'oregano', 'basil', 'thyme', 'rosemary', 'sage', 'dill',
      'parsley', 'cilantro', 'mint', 'bay leaf', 'bay leaves',
      'garlic powder', 'onion powder',
      'italian seasoning', 'taco seasoning', 'seasoning',
      'dried herb',
    ],
    'Frozen': [
      'frozen', 'ice cream', 'sorbet', 'gelato',
      'frozen pizza', 'frozen dinner', 'frozen vegetable',
      'frozen fruit', 'frozen berry', 'frozen berries',
      'frozen waffle', 'frozen fries', 'tater tot',
      'popsicle', 'ice pop',
    ],
    'Beverages': [
      'juice', 'orange juice', 'apple juice',
      'coffee', 'tea', 'herbal tea', 'green tea',
      'soda', 'cola', 'sparkling water', 'seltzer', 'tonic',
      'water', 'coconut water',
      'wine', 'beer', 'spirits',
      'lemonade', 'iced tea',
      'almond milk', 'oat milk', 'soy milk', 'coconut milk',
    ],
  };
}
