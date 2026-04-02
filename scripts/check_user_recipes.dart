import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to check recipes for a specific user
/// Run with: flutter run scripts/check_user_recipes.dart
void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final userId = 'JR9Ns79vyKNJOl1WVvPe9dHs4pL2';
  final userRef = FirebaseFirestore.instance.doc('users/$userId');

  print('🔍 Checking recipes for user: $userId\n');

  try {
    // Query meal collection for this user
    final recipesQuery = await FirebaseFirestore.instance
        .collection('meal')
        .where('user_ref', isEqualTo: userRef)
        .get();

    print('📊 Found ${recipesQuery.docs.length} recipes\n');

    if (recipesQuery.docs.isEmpty) {
      print('❌ No recipes found for this user.');
      print('\nPossible reasons:');
      print('1. User has no recipes (only templates with is_curated: true)');
      print('2. User ID is incorrect');
      print('3. Recipes are stored under a different user_ref format\n');

      // Check if user document exists
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        print('✅ User document exists');
        print('   Email: ${userDoc.data()?['email'] ?? 'N/A'}');
        print('   Display Name: ${userDoc.data()?['display_name'] ?? 'N/A'}');
      } else {
        print('❌ User document does NOT exist');
      }
    } else {
      print('📝 Recipe Details:\n');

      for (var i = 0; i < recipesQuery.docs.length; i++) {
        final doc = recipesQuery.docs[i];
        final data = doc.data();

        print('Recipe ${i + 1}:');
        print('  ID: ${doc.id}');
        print('  Name: ${data['recipe_name'] ?? 'N/A'}');
        print('  Meal Type: ${data['meal_typ'] ?? 'N/A'}');
        print('  Recipe Type: ${data['recipe_type'] ?? 'N/A'}');
        print('  Is Curated: ${data['is_curated'] ?? false}');
        print('  Ingredients: ${(data['ingredients'] as List?)?.length ?? 0} items');
        print('  Created: ${data['created_time']}');
        print('');
      }

      // Summary by type
      final userRecipes = recipesQuery.docs.where((d) => d.data()['is_curated'] != true).length;
      final templates = recipesQuery.docs.where((d) => d.data()['is_curated'] == true).length;

      print('\n📈 Summary:');
      print('  User Recipes: $userRecipes');
      print('  Templates (is_curated: true): $templates');
      print('  Total: ${recipesQuery.docs.length}');
    }
  } catch (e) {
    print('❌ Error querying recipes: $e');
  }
}
