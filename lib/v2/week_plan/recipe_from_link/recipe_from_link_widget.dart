// Recipe import from URL with Pinterest error handling
import 'dart:convert';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/cloud_functions/cloud_functions.dart';
import '/backend/schema/enums/enums.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_icons.dart';
import '/flutter_flow/upload_data.dart';
import '/v2/cong_for_a_new_meal/cong_for_a_new_meal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'recipe_from_link_model.dart';
export 'recipe_from_link_model.dart';

class RecipeFromLinkWidget extends StatefulWidget {
  const RecipeFromLinkWidget({
    super.key,
    this.weekData,
    required this.dateTyyp,
    bool? isGenrateForm,
    this.isReplceItem,
    this.editCookingMeal,
  }) : isGenrateForm = isGenrateForm ?? true;

  final DateTime? weekData;
  final MealTyp? dateTyyp;
  final bool isGenrateForm;
  final MealPlanRecord? isReplceItem;
  final MealRecord? editCookingMeal;

  static String routeName = 'recipeFromLink';
  static String routePath = '/recipeFromLink';

  @override
  State<RecipeFromLinkWidget> createState() => _RecipeFromLinkWidgetState();
}

class _RecipeFromLinkWidgetState extends State<RecipeFromLinkWidget> {
  String _formatImportCost(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  Future<void> _editImportCost() async {
    final controller = TextEditingController(
      text: (_model.estimatedCost != null && _model.estimatedCost! > 0)
          ? _formatImportCost(_model.estimatedCost!)
          : '',
    );
    final newVal = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit estimated cost'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ ', hintText: '20 or 20.14'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newVal != null && newVal >= 0) {
      setState(() => _model.estimatedCost = newVal);
    }
  }

  late RecipeFromLinkModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecipeFromLinkModel());

    _model.urlTextFieldTextController ??= TextEditingController();
    _model.urlTextFieldFocusNode ??= FocusNode();

    _model.ingredientTextFieldTextController ??= TextEditingController();
    _model.ingredientTextFieldFocusNode ??= FocusNode();

    _model.instructionTextFieldTextController ??= TextEditingController();
    _model.instructionTextFieldFocusNode ??= FocusNode();

    _model.pasteTextFieldTextController ??= TextEditingController();
    _model.pasteTextFieldFocusNode ??= FocusNode();

    _model.recipeNameTextFieldTextController ??= TextEditingController();
    _model.recipeNameTextFieldFocusNode ??= FocusNode();

    // CRITICAL: Clear any previous recipe data on fresh widget creation
    // This ensures clean state when pushReplacement creates new widget
    _model.clearRecipe();

    // Check for shared URL from external apps (Pinterest, browser, etc.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSharedUrl();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // DO NOT check for shared URL here - only in initState
    // This prevents premature consumption during navigation transitions
    // The initState check is sufficient for handling shared URLs
  }

  /// Check if there's a shared URL and auto-extract it
  void _checkForSharedUrl() {
    final sharedUrl = FFAppState().consumeSharedRecipeUrl();
    if (sharedUrl != null && sharedUrl.isNotEmpty) {
      debugPrint('RecipeFromLink: New shared URL detected: $sharedUrl');
      // Clear ALL previous recipe data before loading new one
      setState(() {
        _model.clearRecipe();
        // Clear all text controllers
        _model.urlTextFieldTextController?.clear();
        _model.recipeNameTextFieldTextController?.clear();
        _model.ingredientTextFieldTextController?.clear();
        _model.instructionTextFieldTextController?.clear();
        _model.pasteTextFieldTextController?.clear();
        // Set new URL
        _model.urlTextFieldTextController?.text = sharedUrl;
      });
      // Small delay to ensure UI clears before extracting
      Future.delayed(const Duration(milliseconds: 100), () {
        // Auto-extract the recipe
        _extractRecipe();
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Map error codes from cloud function to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'PINTEREST_LOGIN_WALL':
        return 'Pinterest is requiring a login to view this pin. Open it in the Pinterest app, tap the source link, and share that URL instead.';
      case 'PINTEREST_VIDEO':
        return 'Video pins can\'t be imported yet. Try finding the recipe on the creator\'s website or blog.';
      case 'PINTEREST_SOCIAL_SOURCE':
        return 'This pin links to social media, not a recipe website. Try finding the recipe on the creator\'s blog instead.';
      case 'PINTEREST_PRODUCT_SOURCE':
        return 'This pin links to a product page, not a recipe. Try a different pin.';
      case 'PINTEREST_SOURCE_DEAD':
        return 'The recipe website linked from this pin is no longer available. Try pasting the recipe text instead.';
      case 'PINTEREST_NO_RECIPE':
        return 'This pin is just a food photo — no recipe text found. Try searching for the recipe by name, or tap "Paste Text" to add it manually.';
      default:
        // Use the error code as the message if it's descriptive enough
        if (errorCode.length > 20) return errorCode;
        return 'Couldn\'t extract a recipe. Try pasting the recipe text instead.';
    }
  }

  // Whether a photo-import scan is in flight. Drives the spinner inside the
  // "Import from photo" CTA.
  bool _isScanning = false;

  /// Import a recipe from a photo (screenshot of Instagram, cookbook page,
  /// magazine, handwritten card — anything). Same flow as the existing
  /// _scanCookbookPage in edite_add_meal_widget.dart, surfaced here so users
  /// who land on the recipe-import page have a path that works for
  /// Instagram (which has no public API) and any platform whose URL doesn't
  /// expose recipe data.
  Future<void> _importFromPhoto() async {
    final mediaSource = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Import from photo',
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(sheetContext).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt,
                        color: FlutterFlowTheme.of(sheetContext).primary),
                  ),
                  title: const Text('Take a photo',
                      style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Snap a cookbook page or magazine',
                      style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 12,
                          color: Colors.grey)),
                  onTap: () => Navigator.pop(sheetContext, 'camera'),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(sheetContext).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library,
                        color: FlutterFlowTheme.of(sheetContext).primary),
                  ),
                  title: const Text('Choose a screenshot',
                      style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Works for Instagram, Pinterest, anywhere',
                      style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 12,
                          color: Colors.grey)),
                  onTap: () => Navigator.pop(sheetContext, 'gallery'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    if (mediaSource == null) return;

    final selectedMedia = await selectMedia(
      maxWidth: 2048.00,
      maxHeight: 2048.00,
      imageQuality: 95,
      mediaSource: mediaSource == 'camera'
          ? MediaSource.camera
          : MediaSource.photoGallery,
    );

    if (selectedMedia == null || selectedMedia.isEmpty) return;

    setState(() {
      _isScanning = true;
      _model.errorMessage = null;
    });

    try {
      final imageBytes = selectedMedia.first.bytes;
      final imageBase64 = base64Encode(imageBytes);

      // Call the same Cloud Function the edit/add meal scan flow uses —
      // single source of truth for image-to-recipe extraction (Claude vision).
      const projectRegion = 'us-central1';
      const projectId = 'parenting-plus-7szrif';
      final url =
          'https://$projectRegion-$projectId.cloudfunctions.net/scanCookbookWithClaude';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': {'imageBase64': imageBase64}
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final resultData = result['result'] as Map<String, dynamic>?;
      if (resultData == null) {
        throw Exception('Invalid response from server');
      }
      if (resultData['success'] != true) {
        throw Exception(resultData['error'] ?? 'Failed to read recipe from photo');
      }

      final recipeData = resultData['recipe'] as Map<String, dynamic>;
      setState(() {
        _model.populateFromRecipe(recipeData);
        _autoDetectCategories(recipeData);
        _isScanning = false;
      });
    } catch (e) {
      debugPrint('Photo import error: $e');
      setState(() {
        _isScanning = false;
        _model.errorMessage =
            "Couldn't read the recipe from that photo. Try a clearer shot, or use the URL/paste options above.";
      });
    }
  }

  /// Extract recipe from URL using cloud function
  Future<void> _extractRecipe() async {
    final url = _model.urlTextFieldTextController?.text.trim() ?? '';
    if (url.isEmpty) {
      setState(() {
        _model.errorMessage = 'Please enter a recipe URL';
      });
      return;
    }

    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() {
        _model.errorMessage = 'Please enter a valid URL starting with http:// or https://';
      });
      return;
    }

    setState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      debugPrint('🔵 Calling extractRecipe cloud function with URL: $url');
      final result = await makeCloudCall('extractRecipe', {'url': url});
      debugPrint('🔵 Cloud function result type: ${result.runtimeType}');
      debugPrint('🔵 Cloud function keys: ${result.keys.toList()}');
      debugPrint('🔵 Has error key: ${result.containsKey('error')}');
      debugPrint('🔵 Has name key: ${result.containsKey('name')}');
      if (result.containsKey('error')) {
        debugPrint('🔵 Error value: ${result['error']}');
      }
      if (result.containsKey('name')) {
        debugPrint('🔵 Name value: ${result['name']}');
      }

      // Check if cloud function returned an error
      if (result['error'] != null) {
        debugPrint('❌ Cloud function returned error: ${result['error']}');
        final errorCode = result['error'].toString();
        final errorMessage = result['message']?.toString();
        setState(() {
          // Use the descriptive message from the cloud function if available
          _model.errorMessage = errorMessage ?? _getErrorMessage(errorCode);
          _model.isLoading = false;
        });
        return;
      }

      // The cloud function returns the recipe directly (no wrapper)
      // Check if we got a valid recipe object
      if (result.isNotEmpty && result['name'] != null) {
        debugPrint('✅ Recipe extracted successfully: ${result['name']}');
        debugPrint('   - ${(result['ingredients'] as List?)?.length ?? 0} ingredients');
        debugPrint('   - ${(result['instructions'] as List?)?.length ?? 0} instructions');
        debugPrint('   - Image URL: ${result['imageUrl'] ?? 'none'}');
        debugPrint('   - Servings: ${result['servings'] ?? 'none'}');
        final recipe = result;
        final ingredients = recipe['ingredients'] as List? ?? [];
        final instructions = recipe['instructions'] as List? ?? [];

        setState(() {
          _model.populateFromRecipe(recipe);
          _model.isLoading = false;

          // Auto-detect meal type categories from recipe name/description
          _autoDetectCategories(recipe);

          // Show warning if recipe is incomplete (website doesn't have full recipe data)
          if (ingredients.isEmpty && instructions.isEmpty) {
            _model.errorMessage = 'This website doesn\'t share full recipe details. You can add ingredients and instructions manually, or try a different link from a recipe blog.';
          } else if (ingredients.isEmpty) {
            _model.errorMessage = 'No ingredients found. You can add them manually below.';
          } else if (instructions.isEmpty) {
            _model.errorMessage = 'No instructions found. You can view the original recipe for steps.';
          }
        });
      } else {
        debugPrint('❌ Cloud function returned invalid recipe data: ${result.toString()}');
        setState(() {
          _model.errorMessage = 'Could not extract recipe from this URL. Try a different link or add the recipe manually.';
          _model.isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error calling extractRecipe: $e');
      setState(() {
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceFirst('Exception:', '').trim();
        }

        final url = _model.urlTextFieldTextController?.text.toLowerCase() ?? '';

        // Categorize by URL type for client-side fallback messages
        if (url.contains('pinterest.com') || url.contains('pin.it')) {
          if (errorMsg.contains('429') || errorMsg.contains('rate')) {
            _model.errorMessage = 'Too many recipe imports at once. Wait a moment and try again.';
          } else {
            _model.errorMessage = 'Couldn\'t extract a recipe from this pin. Pinterest pins with a website link work best.\n\nTap "Paste Text" to add the recipe manually.';
          }
        } else if (url.contains('instagram.com') || url.contains('facebook.com')) {
          // Instagram has no public API for arbitrary creator posts (Meta
          // deprecated oEmbed in 2020 and the Graph API only returns the
          // authenticated user's own content). Route the user to the screenshot
          // path — works for any post type (Reel, post, Story, carousel) and
          // is legally safe since the user did the capture.
          _model.errorMessage =
              "Instagram doesn't share recipe data through their API. Two ways around it: screenshot the post and use 'Import from photo', or copy the recipe caption and tap 'Paste Text' below.";
        } else if (url.contains('tiktok.com')) {
          // TikTok normally succeeds via oEmbed in the backend. If we hit this
          // branch the network call itself failed (no internet, DNS, etc.).
          _model.errorMessage =
              "Couldn't reach TikTok. Check your connection and try again, or screenshot the video and use 'Import from photo'.";
        } else if (url.contains('youtube.com') || url.contains('youtu.be')) {
          _model.errorMessage = 'Video pages don\'t share recipe data. Check the video description for a link to the full recipe.';
        } else if (url.contains('etsy.com') || url.contains('amazon.com') || url.contains('walmart.com')) {
          _model.errorMessage = 'This is a product page, not a recipe. Try sharing a link from a recipe blog instead.';
        } else if (errorMsg.contains('403') || errorMsg.contains('forbidden') || errorMsg.contains('Blocked')) {
          _model.errorMessage = 'This website blocked access. Try pasting the recipe text instead, or use a different recipe site.';
        } else if (errorMsg.contains('timeout') || errorMsg.contains('Timeout')) {
          _model.errorMessage = 'The request timed out. The website may be slow — try again or paste the recipe text instead.';
        } else {
          _model.errorMessage = 'Couldn\'t find recipe data on this page. Recipe blogs like AllRecipes and Food Network work best.\n\nTap "Paste Text" to add it manually.';
        }
        _model.isLoading = false;
      });
    }
  }

  /// Auto-detect meal type categories from recipe name and description
  void _autoDetectCategories(Map<String, dynamic> recipe) {
    final name = (recipe['name'] as String? ?? '').toLowerCase();
    final description = (recipe['description'] as String? ?? '').toLowerCase();
    final combinedText = '$name $description';

    // Keywords for each category
    final breakfastKeywords = ['breakfast', 'pancake', 'waffle', 'oatmeal', 'cereal', 'toast', 'eggs', 'bacon', 'sausage', 'brunch', 'muffin', 'bagel', 'croissant', 'french toast', 'scrambled', 'omelet', 'smoothie bowl'];
    final lunchKeywords = ['lunch', 'sandwich', 'wrap', 'salad', 'soup', 'panini', 'burger', 'sub', 'hoagie'];
    final dinnerKeywords = ['dinner', 'roast', 'steak', 'chicken breast', 'pork chop', 'salmon', 'pasta', 'casserole', 'curry', 'stir fry', 'grilled', 'baked chicken', 'pot roast', 'lasagna', 'enchilada', 'risotto'];
    final sideKeywords = ['side', 'sides', 'side dish', 'fries', 'mashed potato', 'coleslaw', 'green beans', 'corn', 'rice', 'roasted vegetables'];
    final snackKeywords = ['snack', 'appetizer', 'dip', 'chip', 'cracker', 'finger food', 'bite', 'ball'];
    final dessertKeywords = ['dessert', 'cake', 'cookie', 'brownie', 'pie', 'ice cream', 'chocolate', 'sweet', 'pudding', 'tart', 'cupcake', 'cheesecake', 'candy', 'fudge', 'truffle'];

    // Keywords for dietary restrictions
    final glutenFreeKeywords = ['gluten-free', 'gluten free', 'gf', 'celiac'];
    final dairyFreeKeywords = ['dairy-free', 'dairy free', 'lactose-free', 'lactose free', 'vegan'];
    final nutFreeKeywords = ['nut-free', 'nut free', 'peanut-free', 'peanut free'];
    final vegetarianKeywords = ['vegetarian', 'veggie', 'meatless'];
    final veganKeywords = ['vegan', 'plant-based', 'plant based'];

    // Check for matches (allowing multiple categories)
    if (breakfastKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Breakfast');
    }
    if (lunchKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Lunch');
    }
    if (dinnerKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Dinner');
    }
    if (sideKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Side');
    }
    if (snackKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Snacks');
    }
    if (dessertKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Dessert');
    }

    // Check for dietary restrictions
    if (glutenFreeKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Gluten-Free');
    }
    if (dairyFreeKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Dairy-Free');
    }
    if (nutFreeKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Nut-Free');
    }
    if (vegetarianKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Vegetarian');
    }
    if (veganKeywords.any((keyword) => combinedText.contains(keyword))) {
      _model.selectedCategories.add('Vegan');
    }

    // If no meal type categories detected, default to Dinner (most common)
    final mealTypes = _model.selectedCategories.where((c) => ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Dessert'].contains(c)).toList();
    if (mealTypes.isEmpty) {
      _model.selectedCategories.add('Dinner');
    }

    debugPrint('Auto-detected categories: ${_model.selectedCategories.join(', ')}');
  }

  /// Extract recipe from pasted text using AI
  Future<void> _extractFromText() async {
    final text = _model.pasteTextFieldTextController?.text.trim() ?? '';
    if (text.isEmpty) {
      setState(() {
        _model.errorMessage = 'Please paste your recipe text';
      });
      return;
    }

    if (text.length < 20) {
      setState(() {
        _model.errorMessage = 'Please paste more of the recipe — include ingredients and instructions';
      });
      return;
    }

    setState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      final result = await makeCloudCall('extractRecipe', {'text': text});

      if (result['success'] == true && result['recipe'] != null) {
        final recipe = result['recipe'] as Map<String, dynamic>;
        setState(() {
          _model.populateFromRecipe(recipe);
          // Auto-detect meal type categories from recipe name/description
          _autoDetectCategories(recipe);
          _model.isLoading = false;
        });
      } else {
        setState(() {
          _model.errorMessage = result['error'] as String? ??
              'Could not parse the recipe. Try including the recipe name, ingredients, and instructions.';
          _model.isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceFirst('Exception:', '').trim();
        }
        _model.errorMessage = errorMsg.isNotEmpty
            ? errorMsg
            : 'Something went wrong. Please try again.';
        _model.isLoading = false;
      });
    }
  }

  /// Save recipe to Firestore and add to meal plan
  Future<void> _saveRecipe() async {
    if (_model.recipeName == null || _model.recipeName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe name is required')),
      );
      return;
    }

    if (_model.ingredientsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    setState(() {
      _model.isLoading = true;
    });

    try {
      // Determine meal type from user selection or pre-selected
      // Priority: user-selected categories > pre-selected dateTyyp
      String? mealTypValue;
      String mainOrSidesValue = 'Main';

      debugPrint('🔵 SAVING RECIPE - selectedCategories: ${_model.selectedCategories}');
      if (_model.selectedCategories.isNotEmpty) {
        // Check for Side separately since it goes in main_or_sides field
        if (_model.selectedCategories.contains('Side')) {
          mainOrSidesValue = 'Side';
          debugPrint('🔵 Set mainOrSides to: Side');
        }
        // Build mealTyp in canonical order: Breakfast, Lunch, Dinner, Snacks, Dessert, then dietary
        final canonicalOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Dessert', 'Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Vegetarian', 'Vegan'];
        final mealAndDietaryCategories = canonicalOrder
            .where((c) => _model.selectedCategories.contains(c))
            .toList();
        if (mealAndDietaryCategories.isNotEmpty) {
          mealTypValue = mealAndDietaryCategories.join(',');
          debugPrint('🔵 Set mealTyp to: $mealTypValue');
        }
      } else if (widget.dateTyyp != null) {
        mealTypValue = widget.dateTyyp!.name;
        debugPrint('🔵 Using widget.dateTyyp: $mealTypValue');
      }
      debugPrint('🔵 Final values - mealTyp: $mealTypValue, mainOrSides: $mainOrSidesValue');

      // Convert selectedRecipeType string to RecipeType enum. If the user
      // skipped the chip entirely, default to Entree — matches the
      // creation page behavior and keeps autofill happy (recipes without a
      // type land in the "Main" bucket, not null).
      RecipeType recipeTypeEnum;
      switch (_model.selectedRecipeType) {
        case 'Side':
          recipeTypeEnum = RecipeType.Side;
          break;
        case 'Snack':
          recipeTypeEnum = RecipeType.Snack;
          break;
        case 'Dessert':
          recipeTypeEnum = RecipeType.Dessert;
          break;
        case 'Entree':
        default:
          recipeTypeEnum = RecipeType.Entree;
      }
      debugPrint('🔵 Recipe type: ${_model.selectedRecipeType} -> $recipeTypeEnum');

      // Create the meal record
      var mealRecordReference = MealRecord.collection.doc();
      await mealRecordReference.set({
        ...createMealRecordData(
          imageUrl: _model.mealImage ?? '',
          recipeName: _model.recipeName,
          mealTyp: mealTypValue,
          mainOrSides: mainOrSidesValue,
          userRef: currentUserReference,
          prepareTime: _model.prepTime.toDouble(),
          cookingTime: _model.cookTime.toDouble(),
          sourceUrl: _model.sourceUrl,
          recipeType: recipeTypeEnum,
          estimatedCost: _model.estimatedCost,
        ),
        ...mapToFirestore({
          'ingredients': _model.ingredientsList,
          'CookingInstructions': _model.cookingInsturction,
        }),
      });

      _model.createdMeal = MealRecord.getDocumentFromData({
        ...createMealRecordData(
          imageUrl: _model.mealImage ?? '',
          recipeName: _model.recipeName,
          mealTyp: mealTypValue,
          mainOrSides: mainOrSidesValue,
          userRef: currentUserReference,
          prepareTime: _model.prepTime.toDouble(),
          cookingTime: _model.cookTime.toDouble(),
          sourceUrl: _model.sourceUrl,
          recipeType: recipeTypeEnum,
          estimatedCost: _model.estimatedCost,
        ),
        ...mapToFirestore({
          'ingredients': _model.ingredientsList,
          'CookingInstructions': _model.cookingInsturction,
        }),
      }, mealRecordReference);

      // Determine date and meal type to use (pre-selected or user-selected)
      final DateTime? mealDate = widget.weekData ?? _model.selectedDate;
      final MealTyp? mealType = widget.dateTyyp ?? _model.selectedMealType;

      // Add to meal plan if checkbox is checked and we have date/type
      final bool addingToMealPlan = _model.addToMealPlan && mealDate != null && mealType != null;

      if (addingToMealPlan) {
        if (widget.isReplceItem?.reference != null) {
          // Update existing meal plan entry
          await widget.isReplceItem!.reference.update(
            createMealPlanRecordData(
              date: mealDate,
              typ: mealType,
              userRef: currentUserReference,
              userFirebasemeal: mealRecordReference,
              mealId: mealRecordReference.id,
            ),
          );
        } else {
          // Create new meal plan entry
          await MealPlanRecord.collection.doc().set(
            createMealPlanRecordData(
              date: mealDate,
              typ: mealType,
              mealId: mealRecordReference.id,
              userRef: currentUserReference,
              userFirebasemeal: mealRecordReference,
            ),
          );
        }

        FFAppState().MealCashtearm = true;
      }

      setState(() {
        _model.isLoading = false;
      });

      // Show success dialog
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: const AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(dialogContext).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: CongForANewMealWidget(
                isMealPlan: addingToMealPlan,
                isGenrateForm: widget.isGenrateForm,
                showNavigationOptions: true,
              ),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _model.isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save recipe. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Back button
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.safePop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                    // Title
                    Align(
                      alignment: const AlignmentDirectional(0.0, -1.0),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Text(
                          'Import Recipe',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 24.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                    // Mode toggle tabs
                    if (!_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (_model.isPasteMode) {
                                      setState(() {
                                        _model.isPasteMode = false;
                                        _model.errorMessage = null;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: !_model.isPasteMode ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: !_model.isPasteMode
                                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4.0)]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.link, size: 16.0,
                                          color: !_model.isPasteMode
                                              ? FlutterFlowTheme.of(context).primary
                                              : const Color(0xFF999999)),
                                        const SizedBox(width: 6.0),
                                        Text('From Link',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 13.0,
                                                fontWeight: !_model.isPasteMode ? FontWeight.w600 : FontWeight.normal,
                                                color: !_model.isPasteMode
                                                    ? FlutterFlowTheme.of(context).primaryText
                                                    : const Color(0xFF999999),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (!_model.isPasteMode) {
                                      setState(() {
                                        _model.isPasteMode = true;
                                        _model.errorMessage = null;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: _model.isPasteMode ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: _model.isPasteMode
                                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4.0)]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.content_paste, size: 16.0,
                                          color: _model.isPasteMode
                                              ? FlutterFlowTheme.of(context).primary
                                              : const Color(0xFF999999)),
                                        const SizedBox(width: 6.0),
                                        Text('Paste Recipe',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 13.0,
                                                fontWeight: _model.isPasteMode ? FontWeight.w600 : FontWeight.normal,
                                                color: _model.isPasteMode
                                                    ? FlutterFlowTheme.of(context).primaryText
                                                    : const Color(0xFF999999),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Subtitle - contextual based on mode
                    if (!_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                        child: Text(
                          _model.isPasteMode
                              ? 'Copy a recipe from any website or message and paste it here — we will organize it for you'
                              : "Works with recipe blogs and TikTok video links. For Instagram, screenshot the recipe and use 'Import from photo' below.",
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: const Color(0x801B1F26),
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    // "Instagram coming soon" pill — sets expectation upfront
                    // so users don't try pasting an Instagram URL and bounce
                    // off the "doesn't work yet" error. Shown only on the
                    // link tab (paste tab works fine with copied IG captions).
                    if (!_model.hasExtracted && !_model.isPasteMode)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E1),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFFFB89A),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14.0,
                                color: Color(0xFF8B5A3C),
                              ),
                              const SizedBox(width: 6.0),
                              Flexible(
                                child: Text(
                                  'Instagram link import coming soon. Screenshot Instagram posts for now.',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0xFF8B5A3C),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // "Import from photo" CTA — wires the existing
                    // scanCookbookWithClaude OCR into this page so users have
                    // a path for Instagram (no public API) and anything else
                    // whose URL doesn't expose recipe data.
                    if (!_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 0.0),
                        child: InkWell(
                          onTap: _isScanning ? null : _importFromPhoto,
                          borderRadius: BorderRadius.circular(14.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: _isScanning
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            color: FlutterFlowTheme.of(context).primary,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt_outlined,
                                          color: FlutterFlowTheme.of(context).primary,
                                          size: 18.0,
                                        ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isScanning
                                            ? 'Reading the recipe...'
                                            : 'Import from photo',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                              color: FlutterFlowTheme.of(context).primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      const SizedBox(height: 1.0),
                                      Text(
                                        'Works for Instagram, Pinterest, cookbooks, handwritten notes',
                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontSize: 11.0,
                                              color: const Color(0x801B1F26),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isScanning)
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 20.0,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Visual share flow - show when URL field is empty and not extracted (URL mode only)
                    if (!_model.isPasteMode && !_model.hasExtracted && (_model.urlTextFieldTextController?.text.isEmpty ?? true))
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Share icon (user action)
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF999999).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Color(0xFF666666),
                                size: 24.0,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(Icons.arrow_forward, size: 18.0, color: Color(0xFF999999)),
                            ),
                            // MomRise app logo
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14.0),
                                child: Image.asset(
                                  'assets/images/image_22.png',
                                  width: 44.0,
                                  height: 44.0,
                                  fit: BoxFit.cover,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(Icons.arrow_forward, size: 18.0, color: Color(0xFF999999)),
                            ),
                            // Recipe saved icon
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9B8AA0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Color(0xFF9B8AA0),
                                size: 24.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // URL Input (link mode)
                    if (!_model.isPasteMode)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).prim30,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: const Color(0xFFCBE3E0),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _model.urlTextFieldTextController,
                                  focusNode: _model.urlTextFieldFocusNode,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Paste your recipe URL here',
                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        letterSpacing: 0.0,
                                      ),
                                  cursorColor: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: (_model.isLoading || _model.hasExtracted) ? null : _extractRecipe,
                                  text: _model.hasExtracted ? 'Extracted' : 'Extract',
                                  options: FFButtonOptions(
                                    height: 36.0,
                                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(14.0),
                                    disabledColor: const Color(0xFFCCCCCC),
                                    disabledTextColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Paste text area (paste mode)
                    if (_model.isPasteMode && !_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).prim30,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: const Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                              ),
                              child: TextFormField(
                                controller: _model.pasteTextFieldTextController,
                                focusNode: _model.pasteTextFieldFocusNode,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  hintText: 'Paste your recipe here...\n\nInclude the name, ingredients, and instructions',
                                  hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0x801B1F26),
                                        letterSpacing: 0.0,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            SizedBox(
                              width: double.infinity,
                              child: FFButtonWidget(
                                onPressed: _model.isLoading ? null : _extractFromText,
                                text: 'Import Recipe',
                                icon: const Icon(Icons.auto_awesome, size: 18.0, color: Colors.white),
                                options: FFButtonOptions(
                                  height: 44.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(14.0),
                                  disabledColor: const Color(0xFFCCCCCC),
                                  disabledTextColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Error/Warning message
                    if (_model.errorMessage != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: _model.hasExtracted
                                ? const Color(0xFFFFF3E0)  // Light amber for warnings
                                : const Color(0xFFFFEBEE), // Light red for errors
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _model.hasExtracted ? Icons.info_outline : Icons.error_outline,
                                size: 18.0,
                                color: _model.hasExtracted
                                    ? const Color(0xFFE65100)  // Amber
                                    : FlutterFlowTheme.of(context).error,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _model.errorMessage!,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: _model.hasExtracted
                                            ? const Color(0xFFE65100)
                                            : FlutterFlowTheme.of(context).error,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Default tip (shown when no error and not loading and not extracted)
                    if (_model.errorMessage == null && !_model.isLoading && !_model.hasExtracted && !_model.isPasteMode)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'Pinterest pins with a website link work best.',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    // Loading indicator
                    if (_model.isLoading)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                              child: Text(
                                _model.isPasteMode ? 'Reading your recipe...' : 'Extracting recipe...',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Extracted recipe content
                    if (_model.hasExtracted && !_model.isLoading) ...[
                      // Recipe image
                      if (_model.mealImage != null && _model.mealImage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.0),
                            child: Image.network(
                              _model.mealImage!,
                              width: double.infinity,
                              height: 200.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200.0,
                                  color: FlutterFlowTheme.of(context).prim30,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 64.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      // Recipe name (editable)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 0.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 24.0), // Balance for the edit icon on the right
                            Expanded(
                              child: TextFormField(
                                controller: _model.recipeNameTextFieldTextController,
                                focusNode: _model.recipeNameTextFieldFocusNode,
                                onChanged: (value) {
                                  _model.recipeName = value;
                                },
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Recipe Name',
                                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0x801B1F26),
                                        letterSpacing: 0.0,
                                      ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary.withOpacity(0.3), width: 1.0),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _model.recipeNameTextFieldFocusNode?.requestFocus();
                              },
                              child: Icon(
                                Icons.edit,
                                size: 20.0,
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Recipe description
                      if (_model.recipeDescription != null && _model.recipeDescription!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 0.0),
                          child: Text(
                            _model.recipeDescription!,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xB71B1F26),
                                  fontSize: 13.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      // View original recipe link
                      if (_model.sourceUrl != null && _model.sourceUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                          child: InkWell(
                            onTap: () async {
                              await launchURL(_model.sourceUrl!);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.open_in_new, size: 14.0, color: FlutterFlowTheme.of(context).primary),
                                const SizedBox(width: 4.0),
                                Text(
                                  'View original recipe',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: FlutterFlowTheme.of(context).primary,
                                        decoration: TextDecoration.underline,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Times and servings
                      if (_model.prepTime > 0 || _model.cookTime > 0 || _model.servings.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_model.prepTime > 0)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Prep: ${_model.prepTime} min',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: const Color(0xB71B1F26),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              if (_model.cookTime > 0)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Cook: ${_model.cookTime} min',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: const Color(0xB71B1F26),
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              if (_model.servings.isNotEmpty)
                                Text(
                                  'Serves: ${_model.servings}',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0xB71B1F26),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _editImportCost(),
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _model.estimatedCost != null && _model.estimatedCost! > 0
                                          ? 'Est. cost: \$${_formatImportCost(_model.estimatedCost!)}'
                                          : 'Add est. cost',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: const Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit, size: 12, color: const Color(0xFF2E7D32).withOpacity(0.6)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ingredients section
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).prim30,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: const Color(0xFFCBE3E0), width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 8.0),
                                child: Text(
                                  'Ingredients (${_model.ingredientsList.length})',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              ..._model.ingredientsList.asMap().entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 16.0, color: FlutterFlowTheme.of(context).primary),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _model.removeAtIndexFromIngredientsList(entry.key);
                                          });
                                        },
                                        child: Icon(Icons.close, size: 18.0, color: FlutterFlowTheme.of(context).error),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // Add ingredient field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.ingredientTextFieldTextController,
                                        focusNode: _model.ingredientTextFieldFocusNode,
                                        onFieldSubmitted: (_) {
                                          final text = _model.ingredientTextFieldTextController?.text.trim() ?? '';
                                          if (text.isNotEmpty) {
                                            setState(() {
                                              _model.addToIngredientsList(text);
                                              _model.ingredientTextFieldTextController?.clear();
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Add ingredient...',
                                          hintStyle: FlutterFlowTheme.of(context).bodySmall,
                                          border: InputBorder.none,
                                        ),
                                        style: FlutterFlowTheme.of(context).bodySmall,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        final text = _model.ingredientTextFieldTextController?.text.trim() ?? '';
                                        if (text.isNotEmpty) {
                                          setState(() {
                                            _model.addToIngredientsList(text);
                                            _model.ingredientTextFieldTextController?.clear();
                                          });
                                        }
                                      },
                                      child: Icon(Icons.add_circle, size: 24.0, color: FlutterFlowTheme.of(context).primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Instructions section
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).prim30,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: const Color(0xFFCBE3E0), width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 8.0),
                                child: Text(
                                  'Instructions (${_model.cookingInsturction.length} steps)',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                              ..._model.cookingInsturction.asMap().entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _model.removeAtIndexFromCookingInsturction(entry.key);
                                          });
                                        },
                                        child: Icon(Icons.close, size: 18.0, color: FlutterFlowTheme.of(context).error),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              // Add instruction field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _model.instructionTextFieldTextController,
                                        focusNode: _model.instructionTextFieldFocusNode,
                                        onFieldSubmitted: (_) {
                                          final text = _model.instructionTextFieldTextController?.text.trim() ?? '';
                                          if (text.isNotEmpty) {
                                            setState(() {
                                              _model.addToCookingInsturction(text);
                                              _model.instructionTextFieldTextController?.clear();
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Add step...',
                                          hintStyle: FlutterFlowTheme.of(context).bodySmall,
                                          border: InputBorder.none,
                                        ),
                                        style: FlutterFlowTheme.of(context).bodySmall,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        final text = _model.instructionTextFieldTextController?.text.trim() ?? '';
                                        if (text.isNotEmpty) {
                                          setState(() {
                                            _model.addToCookingInsturction(text);
                                            _model.instructionTextFieldTextController?.clear();
                                          });
                                        }
                                      },
                                      child: Icon(Icons.add_circle, size: 24.0, color: FlutterFlowTheme.of(context).primary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Category selection (always show when extracted)
                    if (_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What kind of recipe is this?',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((mealType) {
                                final isSelected = _model.selectedCategories.contains(mealType);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _model.selectedCategories.remove(mealType);
                                      } else {
                                        _model.selectedCategories.add(mealType);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: isSelected
                                            ? FlutterFlowTheme.of(context).primary
                                            : FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      mealType,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primary,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Dietary & Allergen Info
                            Text(
                              'Dietary & Allergen Info (optional)',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                {'label': 'Gluten-Free', 'emoji': '🌾'},
                                {'label': 'Dairy-Free', 'emoji': '🥛'},
                                {'label': 'Nut-Free', 'emoji': '🥜'},
                                {'label': 'Vegetarian', 'emoji': '🥕'},
                                {'label': 'Vegan', 'emoji': '🌱'},
                              ].map((dietary) {
                                final label = dietary['label']!;
                                final emoji = dietary['emoji']!;
                                final isSelected = _model.selectedCategories.contains(label);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _model.selectedCategories.remove(label);
                                      } else {
                                        _model.selectedCategories.add(label);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF52A097)
                                          : const Color(0xFF52A097).withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF52A097)
                                            : const Color(0xFF52A097).withValues(alpha: 0.3),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF52A097).withValues(alpha: 0.3),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      '$emoji $label',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: isSelected ? Colors.white : const Color(0xFF52A097),
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Recipe Type (Entree/Side/Dessert)
                            Text(
                              'What type of dish is this?',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                {'label': 'Entree', 'emoji': '🍖'},
                                {'label': 'Side', 'emoji': '🥗'},
                                {'label': 'Snack', 'emoji': '🍿'},
                                {'label': 'Dessert', 'emoji': '🍰'},
                              ].map((recipeType) {
                                final label = recipeType['label']!;
                                final emoji = recipeType['emoji']!;
                                final isSelected = _model.selectedRecipeType == label;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _model.selectedRecipeType = label;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).secondary
                                          : FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: isSelected
                                            ? FlutterFlowTheme.of(context).secondary
                                            : FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.3),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: FlutterFlowTheme.of(context).secondary.withValues(alpha: 0.3),
                                                blurRadius: 8.0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      '$emoji $label',
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).secondary,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    // Meal plan section (always show when extracted)
                    if (_model.hasExtracted)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // If meal plan was pre-selected, show checkbox to toggle
                            if (widget.weekData != null && widget.dateTyyp != null)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _model.addToMealPlan = !_model.addToMealPlan;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        color: _model.addToMealPlan
                                            ? FlutterFlowTheme.of(context).primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).primary,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: _model.addToMealPlan
                                          ? const Icon(Icons.check, size: 18.0, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Text(
                                        'Add to meal plan for ${widget.dateTyyp?.name ?? 'today'}',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // If no meal plan pre-selected, show option to select one
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Checkbox to enable meal plan selection
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _model.addToMealPlan = !_model.addToMealPlan;
                                        if (_model.addToMealPlan && _model.selectedDate == null) {
                                          _model.selectedDate = DateTime.now();
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24.0,
                                          height: 24.0,
                                          decoration: BoxDecoration(
                                            color: _model.addToMealPlan
                                                ? FlutterFlowTheme.of(context).primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context).primary,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: _model.addToMealPlan
                                              ? const Icon(Icons.check, size: 18.0, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Text(
                                            'When do you want to plan your meal?',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Show date and meal type selectors when checked
                                  if (_model.addToMealPlan) ...[
                                    const SizedBox(height: 12.0),
                                    // Day chips from meal planner's selected days (fallback to next 7 days)
                                    Builder(
                                      builder: (context) {
                                        final plannerDates = FFAppState().mealPlanSelectedDates;
                                        final dates = (plannerDates != null && plannerDates.isNotEmpty)
                                            ? (List<DateTime>.from(plannerDates)..sort())
                                            : List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
                                        return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(dates.length, (index) {
                                          final date = dates[index];
                                          final isSelected = _model.selectedDate != null &&
                                              _model.selectedDate!.year == date.year &&
                                              _model.selectedDate!.month == date.month &&
                                              _model.selectedDate!.day == date.day;
                                          final dayName = DateFormat('E').format(date);
                                          final dayNum = date.day.toString();

                                          return Padding(
                                            padding: EdgeInsets.only(right: index < 6 ? 8.0 : 0.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _model.selectedDate = date;
                                                });
                                              },
                                              child: Container(
                                                width: 48.0,
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? FlutterFlowTheme.of(context).primary
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? FlutterFlowTheme.of(context).primary
                                                        : const Color(0xFFCCCCCC),
                                                  ),
                                                  borderRadius: BorderRadius.circular(14.0),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      dayName,
                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                            fontFamily: FFAppState().currentFontFamily,
                                                            color: isSelected ? Colors.white : const Color(0xFF666666),
                                                            fontSize: 11.0,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      dayNum,
                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: FFAppState().currentFontFamily,
                                                            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                      },
                                    ),
                                    const SizedBox(height: 12.0),
                                    // Meal type selector
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: MealTyp.values.map((mealType) {
                                        final isSelected = _model.selectedMealType == mealType;
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _model.selectedMealType = mealType;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? FlutterFlowTheme.of(context).primary
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isSelected
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : const Color(0xFFCCCCCC),
                                              ),
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                            child: Text(
                                              mealType.name,
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                    // Action buttons
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () async {
                                context.safePop();
                              },
                              text: 'Cancel',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: (_model.hasExtracted && !_model.isLoading) ? _saveRecipe : null,
                              text: (_model.addToMealPlan &&
                                     ((widget.weekData != null && widget.dateTyyp != null) ||
                                      (_model.selectedDate != null && _model.selectedMealType != null)))
                                  ? 'Save & Add to Plan'
                                  : 'Save to Cookbook',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(14.0),
                                disabledColor: const Color(0xFFCCCCCC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Footer note (dynamic based on selection)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                      child: Text(
                        (_model.addToMealPlan &&
                         ((widget.weekData != null && widget.dateTyyp != null) ||
                          (_model.selectedDate != null && _model.selectedMealType != null)))
                            ? 'Recipe will be saved to your cookbook and added to your meal plan'
                            : 'Recipe will be saved to your cookbook',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0x991B1F26),
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
