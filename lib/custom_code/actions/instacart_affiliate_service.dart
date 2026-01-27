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

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Instacart Affiliate Service
///
/// Opens Instacart with affiliate tracking and pre-populated grocery items.
/// Earns commission on orders through Impact.com affiliate program.
///
/// Usage:
/// ```dart
/// await openInstacartWithGroceryList(groceryItems);
/// ```
Future<void> openInstacartWithGroceryList(
  List<GroceryItemStruct> groceryItems,
) async {
  // Get affiliate link from Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  try {
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint('Remote Config fetch failed: $e');
  }

  // Get affiliate base URL from Remote Config
  // Default to placeholder if not set
  String affiliateBaseUrl = remoteConfig.getString('instacart_affiliate_url');

  if (affiliateBaseUrl.isEmpty) {
    // Placeholder affiliate link - replace with your Impact.com tracking URL
    // Format: https://instacart.oloiyb.net/c/YOUR_PUBLISHER_ID/CAMPAIGN_ID/CREATIVE_ID
    affiliateBaseUrl = 'https://www.instacart.com';
    debugPrint('⚠️ Using placeholder Instacart URL. Set "instacart_affiliate_url" in Firebase Remote Config.');
  }

  // Convert grocery items to search parameters
  final searchTerms = _buildSearchTerms(groceryItems);

  // Build final URL with search parameters
  final url = _buildInstacartUrl(affiliateBaseUrl, searchTerms);

  debugPrint('🛒 Opening Instacart with ${searchTerms.length} items: $url');

  // Try to launch URL
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Open in external app/browser
    );
  } else {
    throw 'Could not launch Instacart. Please check your internet connection.';
  }
}

/// Build search terms from grocery items
///
/// Converts GroceryItemStruct list to simple ingredient names
/// Example: "2 cups milk" → "milk"
List<String> _buildSearchTerms(List<GroceryItemStruct> groceryItems) {
  final searchTerms = <String>[];

  for (final item in groceryItems) {
    if (item.name.isNotEmpty && !item.isChecked) {
      // Use the ingredient name only (no quantity/unit)
      // Clean up common words that might interfere with search
      String searchTerm = item.name.trim().toLowerCase();

      // Remove common modifiers that don't help product search
      searchTerm = searchTerm
          .replaceAll(RegExp(r'\b(fresh|organic|raw|cooked|chopped|diced|sliced|minced)\b'), '')
          .trim();

      // Only add if not empty after cleaning
      if (searchTerm.isNotEmpty) {
        searchTerms.add(searchTerm);
      }
    }
  }

  return searchTerms;
}

/// Build final Instacart URL with affiliate tracking and search parameters
///
/// For Impact.com affiliate links, the structure is:
/// https://instacart.oloiyb.net/c/PUBLISHER_ID/CAMPAIGN_ID/CREATIVE_ID?search=term1&search=term2
String _buildInstacartUrl(String baseUrl, List<String> searchTerms) {
  final uri = Uri.parse(baseUrl);

  // Add each search term as a separate parameter
  // Instacart accepts multiple "search" parameters
  if (searchTerms.isNotEmpty) {
    // For URL with query params, we need to manually build this
    // because Dart's Uri doesn't support duplicate keys well
    final searchParams = searchTerms.map((term) => 'search=${Uri.encodeComponent(term)}').join('&');

    // Combine with existing query if any
    String fullUrl = baseUrl;
    if (uri.query.isNotEmpty) {
      fullUrl += '&$searchParams';
    } else {
      fullUrl += '?$searchParams';
    }

    return fullUrl;
  }

  return baseUrl;
}
