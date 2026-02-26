// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Walmart Affiliate API Service
///
/// Searches Walmart's product catalog and builds add-to-cart URLs
/// with affiliate tracking. Users get a pre-populated Walmart cart.
///
/// Flow:
/// 1. Search Walmart catalog for each grocery item
/// 2. Collect matched product IDs
/// 3. Build add-to-cart URL with affiliate tracking
/// 4. Open in browser
///
/// Requires: Walmart Affiliate API key + Impact.com publisher ID
/// stored in Firebase Remote Config.
Future<String> openWalmartShoppingList(
  List<GroceryItemStruct> groceryItems,
) async {
  final apiKey = FFAppState().walmartApiKey;
  final publisherId = FFAppState().walmartPublisherId;

  if (apiKey.isEmpty) {
    debugPrint('Walmart API: No API key configured');
    // Fall back to basic search URL
    await _openWalmartSearch(groceryItems);
    return 'Opening Walmart...';
  }

  // Filter to unchecked items with names
  final items = groceryItems
      .where((item) => !item.isChecked && item.name.isNotEmpty)
      .toList();

  if (items.isEmpty) {
    debugPrint('Walmart API: No items to send');
    return 'No unchecked items to send';
  }

  debugPrint('Walmart API: Searching ${items.length} items');

  try {
    // Search for each item and collect product IDs
    final productIds = <String>[];

    for (final item in items) {
      final productId = await _searchWalmartProduct(
        _simplifyIngredientName(item.name),
        apiKey,
      );
      if (productId != null) {
        productIds.add(productId);
      }
    }

    debugPrint('Walmart API: Found ${productIds.length}/${items.length} products');

    if (productIds.isNotEmpty) {
      final cartUrl = _buildWalmartCartUrl(productIds, publisherId);
      debugPrint('Walmart API: Opening cart URL: $cartUrl');

      final uri = Uri.parse(cartUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return 'Opening Walmart with ${productIds.length} items!';
    }

    // No products found — fall back to search
    debugPrint('Walmart API: No products matched, falling back to search');
    await _openWalmartSearch(groceryItems);
    return 'Opening Walmart...';
  } catch (e) {
    debugPrint('Walmart API: Error: $e');
    await _openWalmartSearch(groceryItems);
    return 'Opening Walmart...';
  }
}

/// Search Walmart's product catalog for a single item.
/// Returns the first matching product ID, or null if no match.
Future<String?> _searchWalmartProduct(String query, String apiKey) async {
  try {
    final uri = Uri.parse(
      'https://developer.api.walmart.com/api-proxy/service/affil/product/v2/search',
    ).replace(queryParameters: {
      'query': query,
      'numItems': '1',
      'format': 'json',
    });

    final response = await http.get(
      uri,
      headers: {
        'WM_SEC.KEY_VERSION': '1',
        'WM_CONSUMER.ID': apiKey,
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items != null && items.isNotEmpty) {
        final firstItem = items[0] as Map<String, dynamic>;
        final itemId = firstItem['itemId']?.toString();
        debugPrint('Walmart API: "$query" → product $itemId (${firstItem['name']})');
        return itemId;
      }
    }

    debugPrint('Walmart API: No match for "$query"');
    return null;
  } catch (e) {
    debugPrint('Walmart API: Search error for "$query": $e');
    return null;
  }
}

/// Build a Walmart add-to-cart URL with affiliate tracking.
///
/// Format: https://www.walmart.com/cart/addToCart?items=ID1,ID2,ID3
/// With Impact.com affiliate wrapping if publisher ID is available.
String _buildWalmartCartUrl(List<String> productIds, String publisherId) {
  final itemsParam = productIds.join(',');
  final cartUrl = 'https://www.walmart.com/cart/addToCart?items=$itemsParam';

  // If we have a publisher ID, wrap in Impact.com affiliate tracking
  if (publisherId.isNotEmpty) {
    return 'https://goto.walmart.com/c/$publisherId/568844/9383?veh=aff&sourceid=imp_000011112222333344&u=${Uri.encodeComponent(cartUrl)}';
  }

  return cartUrl;
}

/// Fallback: open Walmart with a basic search for the first few items.
Future<void> _openWalmartSearch(List<GroceryItemStruct> groceryItems) async {
  final unchecked = groceryItems
      .where((item) => !item.isChecked && item.name.isNotEmpty)
      .take(5)
      .map((item) => _simplifyIngredientName(item.name))
      .join(' ');

  final url = 'https://www.walmart.com/search?q=${Uri.encodeComponent(unchecked)}';
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Simplify ingredient names for better product matching.
String _simplifyIngredientName(String name) {
  var simplified = name.trim().toLowerCase();

  simplified = simplified.replaceAll(
    RegExp(r'\b(chopped|diced|sliced|minced|grated|shredded|crushed|'
        r'melted|softened|room temperature|cold|warm|hot|frozen|thawed|'
        r'peeled|seeded|deveined|trimmed|halved|quartered|cubed|'
        r'julienned|roughly|finely|thinly|coarsely|freshly|'
        r'packed|sifted|drained|rinsed|dried|toasted|roasted|'
        r'divided|optional|to taste|as needed|for garnish|'
        r'plus more|and more|or more)\b'),
    '',
  );

  simplified = simplified.replaceAll(
    RegExp(r'\b(small|medium|large|extra-large|jumbo|baby|'
        r'thin|thick|boneless|skinless|bone-in|skin-on|'
        r'whole|half|ground|powdered|granulated|'
        r'light|dark|low-fat|reduced-fat|fat-free|nonfat|'
        r'unsalted|salted|sweetened|unsweetened)\b'),
    '',
  );

  simplified = simplified.replaceAll(RegExp(r'\([^)]*\)'), '');
  simplified = simplified.replaceAll(RegExp(r'[,\-]+'), ' ');
  simplified = simplified.replaceAll(RegExp(r'\s+'), ' ').trim();

  return simplified.isEmpty ? name.trim() : simplified;
}
