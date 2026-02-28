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
import 'instacart_affiliate_service.dart';

/// Instacart Developer Platform API Service
///
/// Creates pre-populated shopping list links via the Instacart Connect API.
/// Users get a one-click "add all to cart" experience instead of manual search.
///
/// Falls back to the affiliate URL approach if the API call fails.
///
/// API docs: https://docs.instacart.com/developer_platform_api/
/// Opens Instacart with grocery items. Returns a status message for UI feedback.
Future<String> openInstacartShoppingList(
  List<GroceryItemStruct> groceryItems,
) async {
  final apiKey = FFAppState().instacartApiKey;

  // If no API key configured, fall back to affiliate service
  if (apiKey.isEmpty) {
    debugPrint('Instacart API: No API key configured, falling back to affiliate URL');
    await openInstacartWithGroceryList(groceryItems);
    return 'Opening Instacart...';
  }

  // Filter to unchecked items with names
  final items = groceryItems
      .where((item) => !item.isChecked && item.name.isNotEmpty)
      .toList();

  if (items.isEmpty) {
    debugPrint('Instacart API: No items to send');
    return 'No unchecked items to send';
  }

  // Determine API base URL
  final useProd = FFAppState().instacartUseProd;
  final baseUrl = useProd
      ? 'https://connect.instacart.com'
      : 'https://connect.dev.instacart.tools';

  debugPrint('Instacart API: Sending ${items.length} items to $baseUrl');

  try {
    // Build line items from grocery list with simplified names for better matching
    final lineItems = items.map((item) {
      final lineItem = <String, dynamic>{
        'name': _simplifyIngredientName(item.name),
      };

      // Only include quantity if it's a whole number > 0 (Instacart expects product quantity, not recipe quantity)
      if (item.quantity > 0 && item.quantity == item.quantity.roundToDouble()) {
        lineItem['quantity'] = item.quantity.toInt();
      }

      // Skip units — Instacart matches products, not recipe measurements
      return lineItem;
    }).toList();

    final requestBody = {
      'title': 'MomRise Grocery List',
      'link_type': 'shopping_list',
      'line_items': lineItems,
      'landing_page_configuration': {
        'partner_linkback_url': 'https://momrise.app',
      },
    };

    debugPrint('Instacart API: Request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/idp/v1/products/products_link'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 10));

    debugPrint('Instacart API: Response status: ${response.statusCode}');
    debugPrint('Instacart API: Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final productsLinkUrl = data['products_link_url'] as String?;

      if (productsLinkUrl != null && productsLinkUrl.isNotEmpty) {
        debugPrint('Instacart API: Opening link: $productsLinkUrl');
        final uri = Uri.parse(productsLinkUrl);
        // Use external browser on both platforms to preserve user's Instacart login
        // This ensures product availability shows correctly when logged in to Instacart
        // Note: Instacart app may intercept on iOS, but that's OK - user stays logged in
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return 'Opening Instacart with your list!';
      } else {
        debugPrint('Instacart API: No products_link_url in response');
      }
    } else {
      debugPrint('Instacart API: Request failed with status ${response.statusCode}');
    }

    // If we get here, API call didn't produce a usable link — fall back
    debugPrint('Instacart API: Falling back to affiliate URL');
    await openInstacartWithGroceryList(groceryItems);
    return 'Opening Instacart...';
  } catch (e) {
    debugPrint('Instacart API: Error: $e');
    // Fall back to affiliate service on any error
    await openInstacartWithGroceryList(groceryItems);
    return 'Opening Instacart...';
  }
}

/// Simplify ingredient names for better product matching on Instacart.
/// Strips prep methods, modifiers, and brand-specific terms that prevent matches.
String _simplifyIngredientName(String name) {
  var simplified = name.trim().toLowerCase();

  // Remove prep methods and cooking descriptions
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

  // Remove size/quality modifiers
  simplified = simplified.replaceAll(
    RegExp(r'\b(small|medium|large|extra-large|jumbo|baby|'
        r'thin|thick|boneless|skinless|bone-in|skin-on|'
        r'whole|half|ground|powdered|granulated|'
        r'light|dark|low-fat|reduced-fat|fat-free|nonfat|'
        r'unsalted|salted|sweetened|unsweetened)\b'),
    '',
  );

  // Remove parenthetical notes like "(about 2 cups)" or "(optional)"
  simplified = simplified.replaceAll(RegExp(r'\([^)]*\)'), '');

  // Remove leading/trailing commas, hyphens, whitespace
  simplified = simplified.replaceAll(RegExp(r'[,\-]+'), ' ');
  simplified = simplified.replaceAll(RegExp(r'\s+'), ' ').trim();

  // If simplification made it empty, return original
  return simplified.isEmpty ? name.trim() : simplified;
}
