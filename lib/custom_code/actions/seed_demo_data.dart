// Seed Demo Data for Screenshots
// Run this once to populate the app with nice demo data

import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Seeds demo meals with appealing recipes
Future<void> seedDemoMeals() async {
  if (currentUserReference == null) return;

  final meals = [
    {
      'recipe_name': 'Rainbow Veggie Pasta',
      'image_url': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
      'ingredients': [
        '8 oz pasta (any shape)',
        '1 cup cherry tomatoes, halved',
        '1 cup broccoli florets',
        '1/2 cup corn kernels',
        '1/4 cup grated parmesan',
        '2 tbsp olive oil',
        'Salt and pepper to taste'
      ],
      'CookingInstructions': [
        'Cook pasta according to package directions',
        'Steam broccoli until tender-crisp (3-4 min)',
        'Toss pasta with olive oil, veggies, and parmesan',
        'Season with salt and pepper',
        'Serve warm with extra cheese on top'
      ],
      'prepare_time': 10.0,
      'cooking_time': 15.0,
      'meal_typ': 'dinner',
      'main_or_sides': 'main',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 5,
    },
    {
      'recipe_name': 'Banana Oat Pancakes',
      'image_url': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
      'ingredients': [
        '1 ripe banana',
        '1 cup rolled oats',
        '1 egg',
        '1/2 cup milk',
        '1 tsp vanilla extract',
        '1/2 tsp cinnamon',
        'Maple syrup for serving'
      ],
      'CookingInstructions': [
        'Blend oats into flour in a blender',
        'Add banana, egg, milk, vanilla, and cinnamon',
        'Blend until smooth',
        'Pour 1/4 cup portions onto greased pan',
        'Cook until bubbles form, flip and cook other side',
        'Serve with fresh fruit and maple syrup'
      ],
      'prepare_time': 5.0,
      'cooking_time': 10.0,
      'meal_typ': 'breakfast',
      'main_or_sides': 'main',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 5,
    },
    {
      'recipe_name': 'Cheesy Quesadillas',
      'image_url': 'https://images.unsplash.com/photo-1618040996337-56904b7850b9?w=400',
      'ingredients': [
        '4 flour tortillas',
        '1 cup shredded cheddar cheese',
        '1/2 cup black beans, drained',
        '1/4 cup corn',
        'Sour cream for dipping',
        'Salsa for dipping'
      ],
      'CookingInstructions': [
        'Place tortilla in pan over medium heat',
        'Sprinkle cheese, beans, and corn on half',
        'Fold tortilla in half',
        'Cook 2-3 minutes per side until golden',
        'Cut into triangles and serve with dips'
      ],
      'prepare_time': 5.0,
      'cooking_time': 10.0,
      'meal_typ': 'lunch',
      'main_or_sides': 'main',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 4,
    },
    {
      'recipe_name': 'Apple Cinnamon Oatmeal',
      'image_url': 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400',
      'ingredients': [
        '1 cup rolled oats',
        '2 cups water or milk',
        '1 apple, diced',
        '1 tsp cinnamon',
        '2 tbsp honey or maple syrup',
        'Pinch of salt'
      ],
      'CookingInstructions': [
        'Bring water/milk to a boil',
        'Add oats and reduce heat',
        'Stir in diced apple and cinnamon',
        'Cook 5 minutes, stirring occasionally',
        'Drizzle with honey and serve'
      ],
      'prepare_time': 5.0,
      'cooking_time': 8.0,
      'meal_typ': 'breakfast',
      'main_or_sides': 'main',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 4,
    },
    {
      'recipe_name': 'Mini Veggie Pizzas',
      'image_url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      'ingredients': [
        '4 English muffins, halved',
        '1/2 cup pizza sauce',
        '1 cup mozzarella cheese',
        '1/4 cup diced bell peppers',
        '1/4 cup sliced olives',
        'Italian seasoning'
      ],
      'CookingInstructions': [
        'Preheat oven to 375°F',
        'Place muffin halves on baking sheet',
        'Spread sauce on each half',
        'Top with cheese and veggies',
        'Bake 10-12 minutes until cheese melts',
        'Let cool slightly before serving'
      ],
      'prepare_time': 10.0,
      'cooking_time': 12.0,
      'meal_typ': 'dinner',
      'main_or_sides': 'main',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 5,
    },
    {
      'recipe_name': 'Creamy Mashed Potatoes',
      'image_url': 'https://images.unsplash.com/photo-1600335895229-6e75511892c8?w=400',
      'ingredients': [
        '4 large potatoes, peeled and cubed',
        '1/4 cup butter',
        '1/2 cup milk',
        'Salt and pepper to taste',
        'Chives for garnish'
      ],
      'CookingInstructions': [
        'Boil potatoes until fork-tender (15-20 min)',
        'Drain and return to pot',
        'Add butter and mash',
        'Gradually add milk while mashing',
        'Season and top with chives'
      ],
      'prepare_time': 10.0,
      'cooking_time': 20.0,
      'meal_typ': 'dinner',
      'main_or_sides': 'sides',
      'user_ref': currentUserReference,
      'is_curated': false,
      'rating': 4,
    },
  ];

  final mealCollection = FirebaseFirestore.instance.collection('meal');

  for (final meal in meals) {
    await mealCollection.add(meal);
  }

  print('Seeded ${meals.length} demo meals');
}

/// Seeds demo activities with descriptions
Future<void> seedDemoActivities() async {
  final activities = [
    {
      'Title': 'Sensory Rice Bin',
      'Description': 'Fill a bin with colored rice and hide small toys for your child to discover. Great for developing fine motor skills and sensory exploration.',
      'Location': 'indoor',
      'Energy': 'low',
      'ThingsNeeded': 'Plastic bin, rice, food coloring, small toys',
      'ActivitySafetyConcerns': 'Supervise to prevent rice from being eaten. Not suitable for children who still mouth objects.',
      'time_duration': '20 minutes',
      'parent_proximity': 'nearby',
      'setup_time': '5+ min',
      'cleanup_difficulty': 'messy',
      'bubble_calm': 8,
      'bubble_need_to_move': 2,
      'bubble_learning': 7,
      'bubble_creative': 6,
      'bubble_independent': 7,
      'bubble_connection': 3,
      'bubble_outdoor': 0,
      'bubble_minimal_setup': 3,
      'bubble_sensory': 10,
      'bubble_brain_busy': 6,
    },
    {
      'Title': 'Dance Party',
      'Description': 'Put on your favorite upbeat music and dance together! Take turns choosing songs and showing off your best moves.',
      'Location': 'indoor',
      'Energy': 'high',
      'ThingsNeeded': 'Music player, speakers',
      'ActivitySafetyConcerns': 'Clear space of tripping hazards. Watch for slippery floors.',
      'time_duration': '15 minutes',
      'parent_proximity': 'involved',
      'setup_time': '0-2 min',
      'cleanup_difficulty': 'easy',
      'bubble_calm': 1,
      'bubble_need_to_move': 10,
      'bubble_learning': 3,
      'bubble_creative': 6,
      'bubble_independent': 2,
      'bubble_connection': 9,
      'bubble_outdoor': 0,
      'bubble_minimal_setup': 10,
      'bubble_sensory': 5,
      'bubble_brain_busy': 3,
    },
    {
      'Title': 'Playdough Creations',
      'Description': 'Roll, squish, and create with homemade or store-bought playdough. Add cookie cutters, rolling pins, and plastic utensils for extra fun.',
      'Location': 'indoor',
      'Energy': 'low',
      'ThingsNeeded': 'Playdough, cookie cutters, rolling pin, plastic utensils',
      'ActivitySafetyConcerns': 'Non-toxic playdough recommended. Supervise younger children.',
      'time_duration': '30 minutes',
      'parent_proximity': 'nearby',
      'setup_time': '0-2 min',
      'cleanup_difficulty': 'easy',
      'bubble_calm': 8,
      'bubble_need_to_move': 2,
      'bubble_learning': 5,
      'bubble_creative': 10,
      'bubble_independent': 8,
      'bubble_connection': 4,
      'bubble_outdoor': 0,
      'bubble_minimal_setup': 8,
      'bubble_sensory': 9,
      'bubble_brain_busy': 6,
    },
    {
      'Title': 'Bubble Chase',
      'Description': 'Blow bubbles outside and let your child chase and pop them! Great for burning energy and practicing coordination.',
      'Location': 'outdoor',
      'Energy': 'high',
      'ThingsNeeded': 'Bubble solution, bubble wands',
      'ActivitySafetyConcerns': 'Avoid slippery surfaces. Keep bubble solution away from eyes.',
      'time_duration': '15 minutes',
      'parent_proximity': 'involved',
      'setup_time': '0-2 min',
      'cleanup_difficulty': 'easy',
      'bubble_calm': 2,
      'bubble_need_to_move': 9,
      'bubble_learning': 3,
      'bubble_creative': 4,
      'bubble_independent': 3,
      'bubble_connection': 8,
      'bubble_outdoor': 10,
      'bubble_minimal_setup': 9,
      'bubble_sensory': 6,
      'bubble_brain_busy': 4,
    },
    {
      'Title': 'Story Time Theater',
      'Description': 'Act out your favorite picture book together using stuffed animals as characters. Let your child direct the show!',
      'Location': 'indoor',
      'Energy': 'medium',
      'ThingsNeeded': 'Picture books, stuffed animals or puppets',
      'ActivitySafetyConcerns': 'None',
      'time_duration': '20 minutes',
      'parent_proximity': 'involved',
      'setup_time': '0-2 min',
      'cleanup_difficulty': 'easy',
      'bubble_calm': 6,
      'bubble_need_to_move': 4,
      'bubble_learning': 8,
      'bubble_creative': 9,
      'bubble_independent': 3,
      'bubble_connection': 10,
      'bubble_outdoor': 0,
      'bubble_minimal_setup': 8,
      'bubble_sensory': 3,
      'bubble_brain_busy': 7,
    },
  ];

  final activityCollection = FirebaseFirestore.instance.collection('activity');

  for (final activity in activities) {
    await activityCollection.add(activity);
  }

  print('Seeded ${activities.length} demo activities');
}

/// Main function to seed all demo data
Future<void> seedAllDemoData() async {
  try {
    await seedDemoMeals();
    await seedDemoActivities();
    print('All demo data seeded successfully!');
  } catch (e) {
    print('Error seeding demo data: $e');
  }
}
