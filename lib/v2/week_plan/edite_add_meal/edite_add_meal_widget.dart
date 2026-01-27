import 'dart:convert';
import 'dart:typed_data';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/enums/enums.dart';
import 'package:http/http.dart' as http;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/components/animated_press_widget.dart';
import '/v2/cong_for_a_new_meal/cong_for_a_new_meal_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edite_add_meal_model.dart';
export 'edite_add_meal_model.dart';

class EditeAddMealWidget extends StatefulWidget {
  const EditeAddMealWidget({
    super.key,
    this.weekData,
    required this.dateTyyp,
    bool? isGenrateForm,
    this.isReplceItem,
    this.editCookingMeal,
    bool? isCreatingSide,
  }) : this.isGenrateForm = isGenrateForm ?? true,
       this.isCreatingSide = isCreatingSide ?? false;

  final DateTime? weekData;
  final MealTyp? dateTyyp;
  final bool isGenrateForm;
  final MealPlanRecord? isReplceItem;
  final MealRecord? editCookingMeal;
  /// If true, the recipe is being created as a side dish
  final bool isCreatingSide;

  static String routeName = 'EditeAddMeal';
  static String routePath = '/editeAddMeal';

  @override
  State<EditeAddMealWidget> createState() => _EditeAddMealWidgetState();
}

class _EditeAddMealWidgetState extends State<EditeAddMealWidget> {
  late EditeAddMealModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditeAddMealModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return; // Prevent setState after dispose
      if (widget!.editCookingMeal != null) {
        _model.mealImage = widget!.editCookingMeal?.imageUrl;
        _model.ingredientsList =
            widget!.editCookingMeal!.ingredients.toList().cast<String>();
        _model.cookingInsturction = widget!.editCookingMeal!.cookingInstructions
            .toList()
            .cast<String>();

        // Initialize selectedCategories from existing meal data
        if (widget!.editCookingMeal!.mainOrSides == 'Side') {
          _model.selectedCategories.add('Side');
        }
        // Parse mealTyp (comma-separated) into categories
        if (widget!.editCookingMeal!.mealTyp.isNotEmpty) {
          final mealTypes = widget!.editCookingMeal!.mealTyp.split(',');
          for (final type in mealTypes) {
            final trimmed = type.trim();
            if (['Breakfast', 'Lunch', 'Dinner', 'Snacks'].contains(trimmed)) {
              _model.selectedCategories.add(trimmed);
            }
          }
        }

        safeSetState(() {});
      } else {
        // For new recipes, initialize with default category based on meal type context
        if (widget!.dateTyyp != null) {
          switch (widget!.dateTyyp) {
            case MealTyp.Breakfast:
              _model.selectedCategories.add('Breakfast');
              break;
            case MealTyp.Lunch:
              _model.selectedCategories.add('Lunch');
              break;
            case MealTyp.Dinner:
              _model.selectedCategories.add('Dinner');
              break;
            case MealTyp.Snacks:
              _model.selectedCategories.add('Snacks');
              break;
            default:
              break;
          }
          safeSetState(() {});
        }
      }
    });

    _model.textController1 ??=
        TextEditingController(text: widget!.editCookingMeal?.recipeName);
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: widget!.editCookingMeal?.cost?.toString());
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController(
        text: widget!.editCookingMeal?.cookingTime?.toString());
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController(
        text: widget!.editCookingMeal?.prepareTime?.toString());
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.ingredientsTextFieldTextController ??= TextEditingController();
    _model.ingredientsTextFieldFocusNode ??= FocusNode();

    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // Palette colors for placeholder backgrounds
  static const List<Color> _placeholderColors = [
    Color(0xFF52A097), // primary teal
    Color(0xFF39D2C0), // secondary turquoise
    Color(0xFFEE8B60), // tertiary coral
    Color(0xFF2A6F67), // dark teal
    Color(0xFF7BC4BB), // light teal
    Color(0xFFE8A87C), // soft peach
  ];

  // Get a consistent color based on meal name
  Color _getPlaceholderColor(String? mealName) {
    if (mealName == null || mealName.isEmpty) {
      return _placeholderColors[0];
    }
    final index = mealName.hashCode.abs() % _placeholderColors.length;
    return _placeholderColors[index];
  }

  // Check if URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'file:///' || url == 'file://' || url.startsWith('file:///')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
    return true;
  }

  // Build colored placeholder with icon for the Add Photo area
  Widget _buildColoredPlaceholder() {
    return Container(
      color: _getPlaceholderColor(_model.textController1?.text),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48.0,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  /// Get contextual title based on whether editing or creating
  String _getTitle() {
    if (widget.editCookingMeal != null) {
      return 'Edit Recipe';
    }
    if (widget.isCreatingSide) {
      return 'Create New Side';
    }
    return 'Create New Recipe';
  }

  /// Get contextual subtitle showing what meal slot is being filled
  String _getSubtitle() {
    if (widget.weekData == null || widget.dateTyyp == null) {
      return 'This will be saved to your cookbook';
    }
    final dayName = _getDayName(widget.weekData!);
    final mealType = widget.dateTyyp!.name;
    return 'For $dayName\'s $mealType';
  }

  /// Get day name from date
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    }
  }

  /// Get contextual button text based on whether adding to meal plan
  String _getButtonText() {
    if (widget.weekData != null && widget.dateTyyp != null) {
      return 'Add to Meal Plan';
    }
    return 'Save Recipe';
  }

  /// State for cookbook scanning
  bool _isScanning = false;

  /// Scan a cookbook page and extract recipe using AI
  Future<void> _scanCookbookPage() async {
    // Show custom bottom sheet for image source selection
    final mediaSource = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
                Text(
                  'Choose Photo Source',
                  style: TextStyle(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(sheetContext).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt, color: FlutterFlowTheme.of(sheetContext).primary),
                  ),
                  title: Text('Take Photo', style: TextStyle(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w500)),
                  subtitle: Text('Use camera to capture cookbook page', style: TextStyle(fontFamily: 'Andika New Basic', fontSize: 12, color: Colors.grey)),
                  onTap: () => Navigator.pop(sheetContext, 'camera'),
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(sheetContext).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library, color: FlutterFlowTheme.of(sheetContext).primary),
                  ),
                  title: Text('Choose from Gallery', style: TextStyle(fontFamily: 'Andika New Basic', fontWeight: FontWeight.w500)),
                  subtitle: Text('Select an existing photo', style: TextStyle(fontFamily: 'Andika New Basic', fontSize: 12, color: Colors.grey)),
                  onTap: () => Navigator.pop(sheetContext, 'gallery'),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    if (mediaSource == null) return;

    // Pick image based on selection
    final selectedMedia = await selectMedia(
      maxWidth: 2000.00,
      maxHeight: 2000.00,
      mediaSource: mediaSource == 'camera' ? MediaSource.camera : MediaSource.photoGallery,
    );

    if (selectedMedia == null || selectedMedia.isEmpty) return;

    setState(() => _isScanning = true);

    try {
      final media = selectedMedia.first;
      final imageBytes = media.bytes;

      // Convert image to base64 for Claude API
      final imageBase64 = base64Encode(imageBytes);

      // Call Claude via cloud function
      const projectRegion = 'us-central1';
      const projectId = 'parenting-plus-7szrif';
      final url = 'https://$projectRegion-$projectId.cloudfunctions.net/scanCookbookWithClaude';

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
        throw Exception(resultData['error'] ?? 'Failed to extract recipe');
      }

      final recipeData = resultData['recipe'] as Map<String, dynamic>;

      // Fill in the form fields with extracted data
      if (recipeData['name'] != null) {
        _model.textController1?.text = recipeData['name'].toString();
      }
      if (recipeData['prepTime'] != null && recipeData['prepTime'] != 0) {
        _model.textController4?.text = recipeData['prepTime'].toString();
      }
      if (recipeData['cookTime'] != null && recipeData['cookTime'] != 0) {
        _model.textController3?.text = recipeData['cookTime'].toString();
      }
      if (recipeData['ingredients'] != null && recipeData['ingredients'] is List) {
        _model.ingredientsList = List<String>.from(recipeData['ingredients']);
      }
      if (recipeData['instructions'] != null && recipeData['instructions'] is List) {
        _model.cookingInsturction = List<String>.from(recipeData['instructions']);
      }

      // Upload image to storage for the recipe
      final downloadUrl = await uploadData(media.storagePath, media.bytes);
      if (downloadUrl != null) {
        _model.mealImage = downloadUrl;
        _model.isImageUploaded = true;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.0),
              SizedBox(width: 8.0),
              Expanded(child: Text('Recipe extracted! Review and edit as needed.')),
            ],
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

    } catch (e) {
      debugPrint('Error scanning cookbook: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20.0),
              SizedBox(width: 8.0),
              Expanded(child: Text('Could not extract recipe: ${e.toString().replaceAll('Exception:', '').trim()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  /// Build a section header for form organization
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Andika New Basic',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primary,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground, // White background
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
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
                    Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTitle(),
                              style:
                                  FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 24.0,
                                        letterSpacing: 0.0,
                                      ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                              child: Text(
                                _getSubtitle(),
                                style:
                                    FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: Color(0xB71B1F26),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                              ),
                            ),
                            // Scan Cookbook button - only show when creating new recipe
                            if (widget.editCookingMeal == null)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: AnimatedPress(
                                  onTap: _isScanning ? null : _scanCookbookPage,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF52A097), Color(0xFF39D2C0)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF52A097).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_isScanning)
                                          SizedBox(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          _isScanning ? 'Scanning...' : 'Scan Cookbook Page',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.0,
                                            fontFamily: 'Andika New Basic',
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
                    // Show uploaded image if available
                    if (_model.mealImage != null && _model.mealImage != '')
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Container(
                            width: 266.84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: _isValidImageUrl(_model.mealImage)
                                      ? Image.network(
                                          _model.mealImage!,
                                          width: double.infinity,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: double.infinity,
                                              height: 200.0,
                                              child: _buildColoredPlaceholder(),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 200.0,
                                          child: _buildColoredPlaceholder(),
                                        ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 16.0, 16.0, 0.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await FirebaseStorage.instance
                                            .refFromURL(_model.mealImage!)
                                            .delete();
                                        _model.mealImage = null;
                                        safeSetState(() {});
                                      },
                                      child: Icon(
                                        Icons.delete_outlined,
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 29.0, 0.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final selectedMedia =
                              await selectMediaWithSourceBottomSheet(
                            context: context,
                            maxWidth: 100000.00,
                            maxHeight: 10000.00,
                            allowPhoto: true,
                          );
                          if (selectedMedia != null &&
                              selectedMedia.every((m) =>
                                  validateFileFormat(m.storagePath, context))) {
                            safeSetState(() =>
                                _model.isDataUploading_uploadData4iy = true);
                            var selectedUploadedFiles = <FFUploadedFile>[];

                            var downloadUrls = <String>[];
                            try {
                              selectedUploadedFiles = selectedMedia
                                  .map((m) => FFUploadedFile(
                                        name: m.storagePath.split('/').last,
                                        bytes: m.bytes,
                                        height: m.dimensions?.height,
                                        width: m.dimensions?.width,
                                        blurHash: m.blurHash,
                                        originalFilename: m.originalFilename,
                                      ))
                                  .toList();

                              downloadUrls = (await Future.wait(
                                selectedMedia.map(
                                  (m) async =>
                                      await uploadData(m.storagePath, m.bytes),
                                ),
                              ))
                                  .where((u) => u != null)
                                  .map((u) => u!)
                                  .toList();
                            } finally {
                              _model.isDataUploading_uploadData4iy = false;
                            }
                            if (selectedUploadedFiles.length ==
                                    selectedMedia.length &&
                                downloadUrls.length == selectedMedia.length) {
                              safeSetState(() {
                                _model.uploadedLocalFile_uploadData4iy =
                                    selectedUploadedFiles.first;
                                _model.uploadedFileUrl_uploadData4iy =
                                    downloadUrls.first;
                              });
                            } else {
                              safeSetState(() {});
                              return;
                            }
                          }

                          _model.mealImage =
                              _model.uploadedFileUrl_uploadData4iy;
                          _model.isImageUploaded = true;
                          safeSetState(() {});
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.66,
                          decoration: BoxDecoration(
                            color: Color(0x4D52A097),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 16.0, 0.0, 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 33.0,
                                  height: 33.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 0.0),
                                  child: Text(
                                    'Add Photo (Optional)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
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
                    // Section: Basic Info
                    _buildSectionHeader(context, 'Basic Info', Icons.restaurant_menu),
                    Container(
                      height: 65.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).prim30,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: Color(0xFFCBE3E0),
                          width: 1.0,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          onChanged: (_) => safeSetState(() {}),
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                  letterSpacing: 0.0,
                                ),
                            hintText: 'Recipe Name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            enableInteractiveSelection: true,
                            validator: _model.textController1Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                    // Category chips (multi-select)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category (select all that apply)',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 13.0,
                                  color: const Color(0xFF666666),
                                  letterSpacing: 0.0,
                                ),
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: ['Breakfast', 'Lunch', 'Dinner', 'Side', 'Snacks'].map((category) {
                              final isSelected = _model.selectedCategories.contains(category);
                              final displayText = category == 'Snacks' ? 'Snacks/Desserts' : category;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _model.selectedCategories.remove(category);
                                    } else {
                                      _model.selectedCategories.add(category);
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
                                    displayText,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: 'Andika New Basic',
                                          color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primary,
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
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              width: 200.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).prim30,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.textController3,
                                  focusNode: _model.textFieldFocusNode3,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'Cook time (optional)',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  enableInteractiveSelection: true,
                                  validator: _model.textController3Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 200.0,
                              height: 45.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).prim30,
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: Color(0xFFCBE3E0),
                                  width: 1.0,
                                ),
                              ),
                              child: Container(
                                width: 200.0,
                                child: TextFormField(
                                  controller: _model.textController4,
                                  focusNode: _model.textFieldFocusNode4,
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'Prep time (optional)',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  enableInteractiveSelection: true,
                                  validator: _model.textController4Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                    // Section: Ingredients
                    _buildSectionHeader(context, 'Ingredients', Icons.kitchen),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 56.0,
                              decoration: const BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _model
                                          .ingredientsTextFieldTextController,
                                      focusNode: _model
                                          .ingredientsTextFieldFocusNode,
                                      onFieldSubmitted: (_) async {
                                        if (_model.ingredientsTextFieldTextController.text.trim().isNotEmpty) {
                                          _model.addToIngredientsList(_model
                                              .ingredientsTextFieldTextController
                                              .text.trim());
                                          _model.isIntgredientsSeleted = true;
                                          safeSetState(() {
                                            _model
                                                .ingredientsTextFieldTextController
                                                ?.text = '';
                                          });
                                          // Keep focus on the text field for continuous entry
                                          _model.ingredientsTextFieldFocusNode?.requestFocus();
                                        }
                                      },
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: FlutterFlowTheme.of(
                                                context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                            ),
                                        hintText: 'e.g. 2 cups flour...',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                color: const Color(0xFF9E9E9E),
                                                letterSpacing: 0.0,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 5,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
                                        validator: _model
                                            .ingredientsTextFieldTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, -1.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 10.0, 12.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (_model.ingredientsTextFieldTextController.text.trim().isNotEmpty) {
                                            _model.addToIngredientsList(_model
                                                .ingredientsTextFieldTextController
                                                .text.trim());
                                            _model.isIntgredientsSeleted = true;
                                            safeSetState(() {
                                              _model
                                                  .ingredientsTextFieldTextController
                                                  ?.text = '';
                                            });
                                            // Keep focus on the text field for continuous entry
                                            _model.ingredientsTextFieldFocusNode?.requestFocus();
                                          }
                                        },
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 28.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 10.0),
                              child: Builder(
                                builder: (context) {
                                  final userInerdients =
                                      _model.ingredientsList.toList();

                                  return ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: userInerdients.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 8.0),
                                    itemBuilder:
                                        (context, userInerdientsIndex) {
                                      final userInerdientsItem =
                                          userInerdients[userInerdientsIndex];
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 8.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 8.0, 0.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      userInerdientsItem,
                                                      'Ingredients',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Andika New Basic',
                                                          letterSpacing: 0.0,
                                                        ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model
                                                    .removeAtIndexFromIngredientsList(
                                                        userInerdientsIndex);
                                                safeSetState(() {});
                                              },
                                              child: Icon(
                                                FFIcons.kfluentDelete28Regular,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                size: 24.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!_model.isIntgredientsSeleted)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'Please add at least one ingredient.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    // Section: Instructions
                    _buildSectionHeader(context, 'Instructions', Icons.format_list_numbered),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).prim30,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: Color(0xFFCBE3E0),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 56.0,
                              decoration: const BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                        controller: _model.textController6,
                                        focusNode: _model.textFieldFocusNode5,
                                      onFieldSubmitted: (_) async {
                                        if (_model.textController6.text.trim().isNotEmpty) {
                                          _model.addToCookingInsturction(
                                              _model.textController6.text.trim());
                                          _model.isCookingInsturctionSelected =
                                              true;
                                          safeSetState(() {
                                            _model.textController6?.text = '';
                                          });
                                          // Keep focus on the text field for continuous entry
                                          _model.textFieldFocusNode5?.requestFocus();
                                        }
                                      },
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: FlutterFlowTheme.of(
                                                context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                letterSpacing: 0.0,
                                              ),
                                          hintText: 'e.g. Preheat oven to 350°F...',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Andika New Basic',
                                                color: const Color(0xFF9E9E9E),
                                                letterSpacing: 0.0,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 5,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        enableInteractiveSelection: true,
                                        validator: _model
                                            .textController6Validator
                                            .asValidator(context),
                                      ),
                                    ),
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, -1.0),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 10.0, 12.0, 0.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          if (_model.textController6.text.trim().isNotEmpty) {
                                            _model.addToCookingInsturction(
                                                _model.textController6.text.trim());
                                            _model.isCookingInsturctionSelected =
                                                true;
                                            safeSetState(() {
                                              _model.textController6?.text = '';
                                            });
                                            // Keep focus on the text field for continuous entry
                                            _model.textFieldFocusNode5?.requestFocus();
                                          }
                                        },
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 28.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 10.0),
                              child: Builder(
                                builder: (context) {
                                  final userCookingInstructions =
                                      _model.cookingInsturction.toList();

                                  return ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: userCookingInstructions.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 8.0),
                                    itemBuilder: (context,
                                        userCookingInstructionsIndex) {
                                      final userCookingInstructionsItem =
                                          userCookingInstructions[
                                              userCookingInstructionsIndex];
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 8.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 8.0, 0.0),
                                                child: Text(
                                                  valueOrDefault<String>(
                                                    userCookingInstructionsItem,
                                                    'Cooking Instructions',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Andika New Basic',
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            // Edit icon
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                // Show dialog to edit instruction
                                                final controller = TextEditingController(
                                                  text: userCookingInstructionsItem,
                                                );
                                                final result = await showDialog<String>(
                                                  context: context,
                                                  builder: (dialogContext) => AlertDialog(
                                                    title: Text('Edit Instruction'),
                                                    content: TextField(
                                                      controller: controller,
                                                      maxLines: 3,
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter instruction',
                                                        border: OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(dialogContext),
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(dialogContext, controller.text),
                                                        child: Text('Save'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (result != null && result.isNotEmpty) {
                                                  _model.updateCookingInsturctionAtIndex(
                                                    userCookingInstructionsIndex,
                                                    (_) => result,
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 8.0, 0.0),
                                                child: Icon(
                                                  Icons.edit_outlined,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primary,
                                                  size: 22.0,
                                                ),
                                              ),
                                            ),
                                            // Delete icon
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model.removeAtIndexFromCookingInsturction(
                                                    userCookingInstructionsIndex);
                                                safeSetState(() {});
                                                safeSetState(() {
                                                  _model.textController6?.text =
                                                      '';
                                                });
                                              },
                                              child: Icon(
                                                FFIcons.kfluentDelete28Regular,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                size: 24.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!_model.isCookingInsturctionSelected)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'Please add at least one cooking instruction.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color:
                                          FlutterFlowTheme.of(context).primary,
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
                          Expanded(
                            child: Builder(
                              builder: (context) => FFButtonWidget(
                                onPressed: () async {
                                  if (_model.formKey.currentState == null ||
                                      !_model.formKey.currentState!
                                          .validate()) {
                                    return;
                                  }
                                  // Image is now optional
                                  if (_model.ingredientsList.isNotEmpty) {
                                    if (_model.cookingInsturction.isNotEmpty) {
                                        if (widget!
                                                .editCookingMeal?.reference !=
                                            null) {
                                          if (!(_model.dropDownValue2 != null &&
                                              _model.dropDownValue2 != '')) {
                                            safeSetState(() {
                                              _model.dropDownValueController2
                                                      ?.value =
                                                  widget!.editCookingMeal!
                                                      .mainOrSides;
                                              _model.dropDownValue2 = widget!
                                                  .editCookingMeal!.mainOrSides;
                                            });
                                          }
                                          // Compute mainOrSides and mealTyp from selectedCategories
                                          String? mainOrSidesValue = _model.dropDownValue2;
                                          String? mealTypValue;
                                          if (_model.selectedCategories.isNotEmpty) {
                                            if (_model.selectedCategories.contains('Side')) {
                                              mainOrSidesValue = 'Side';
                                            }
                                            final mealCategories = _model.selectedCategories.where((c) => c != 'Side').toList();
                                            if (mealCategories.isNotEmpty) {
                                              mealTypValue = mealCategories.join(',');
                                            }
                                          } else {
                                            // Keep existing value if no categories selected
                                            mealTypValue = widget!.editCookingMeal?.mealTyp;
                                          }

                                          await widget!
                                              .editCookingMeal!.reference
                                              .update({
                                            ...createMealRecordData(
                                              imageUrl: _model.mealImage,
                                              recipeName:
                                                  _model.textController1.text,
                                              cost: double.tryParse(_model
                                                  .textController2.text),
                                              mainOrSides: mainOrSidesValue,
                                              mealTyp: mealTypValue,
                                              userRef: currentUserReference,
                                              isCurated: false,
                                              prepareTime: double.tryParse(
                                                  _model
                                                      .textController4.text),
                                              cookingTime: double.tryParse(
                                                  _model
                                                      .textController3.text),
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'ingredients':
                                                    _model.ingredientsList,
                                                'CookingInstructions':
                                                    _model.cookingInsturction,
                                              },
                                            ),
                                          });

                                          if ((widget!.weekData != null) &&
                                              (widget!.dateTyyp != null)) {
                                            if (widget!
                                                    .isReplceItem?.reference !=
                                                null) {
                                              await widget!
                                                  .isReplceItem!.reference
                                                  .update(
                                                      createMealPlanRecordData(
                                                date: widget!.weekData,
                                                typ: widget!.dateTyyp,
                                                userRef: currentUserReference,
                                                userFirebasemeal: widget!
                                                    .editCookingMeal?.reference,
                                              ));
                                            } else {
                                              await MealPlanRecord.collection
                                                  .doc()
                                                  .set(createMealPlanRecordData(
                                                    date: widget!.weekData,
                                                    typ: widget!.dateTyyp,
                                                    mealId: widget!
                                                        .editCookingMeal
                                                        ?.reference
                                                        .id,
                                                    userRef:
                                                        currentUserReference,
                                                    userFirebasemeal: widget!
                                                        .editCookingMeal
                                                        ?.reference,
                                                  ));
                                            }
                                          } else {
                                            await showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(
                                                              dialogContext)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child:
                                                        CongForANewMealWidget(
                                                      isMealPlan: false,
                                                      isGenrateForm:
                                                          widget!.isGenrateForm,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        } else {
                                          // Compute mainOrSides and mealTyp from selectedCategories for new meal
                                          String? newMainOrSides;
                                          String? newMealTyp;
                                          if (_model.selectedCategories.isNotEmpty) {
                                            if (_model.selectedCategories.contains('Side')) {
                                              newMainOrSides = 'Side';
                                            }
                                            final mealCategories = _model.selectedCategories.where((c) => c != 'Side').toList();
                                            if (mealCategories.isNotEmpty) {
                                              newMealTyp = mealCategories.join(',');
                                            }
                                          }

                                          var mealRecordReference =
                                              MealRecord.collection.doc();
                                          await mealRecordReference.set({
                                            ...createMealRecordData(
                                              imageUrl: _model.mealImage,
                                              recipeName:
                                                  _model.textController1.text,
                                              mealTyp: newMealTyp,
                                              cost: double.tryParse(
                                                  _model.textController2.text),
                                              mainOrSides: newMainOrSides,
                                              userRef: currentUserReference,
                                              isCurated: false,
                                              prepareTime: double.tryParse(
                                                  _model.textController4.text),
                                              cookingTime: double.tryParse(
                                                  _model.textController3.text),
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'ingredients':
                                                    _model.ingredientsList,
                                                'CookingInstructions':
                                                    _model.cookingInsturction,
                                              },
                                            ),
                                          });
                                          _model.userMeal =
                                              MealRecord.getDocumentFromData({
                                            ...createMealRecordData(
                                              imageUrl: _model.mealImage,
                                              recipeName:
                                                  _model.textController1.text,
                                              mealTyp: newMealTyp,
                                              cost: double.tryParse(
                                                  _model.textController2.text),
                                              mainOrSides: newMainOrSides,
                                              userRef: currentUserReference,
                                              isCurated: false,
                                              prepareTime: double.tryParse(
                                                  _model.textController4.text),
                                              cookingTime: double.tryParse(
                                                  _model.textController3.text),
                                            ),
                                            ...mapToFirestore(
                                              {
                                                'ingredients':
                                                    _model.ingredientsList,
                                                'CookingInstructions':
                                                    _model.cookingInsturction,
                                              },
                                            ),
                                          }, mealRecordReference);
                                          if ((widget!.weekData != null) &&
                                              (widget!.dateTyyp != null)) {
                                            if (widget!
                                                    .isReplceItem?.reference !=
                                                null) {
                                              await widget!
                                                  .isReplceItem!.reference
                                                  .update(
                                                      createMealPlanRecordData(
                                                date: widget!.weekData,
                                                mealId: _model
                                                    .userMeal?.reference.id,
                                                typ: widget!.dateTyyp,
                                                userRef: currentUserReference,
                                                userFirebasemeal:
                                                    widget!.editCookingMeal !=
                                                            null
                                                        ? widget!
                                                            .editCookingMeal
                                                            ?.reference
                                                        : _model.userMeal
                                                            ?.reference,
                                              ));
                                            } else {
                                              await MealPlanRecord.collection
                                                  .doc()
                                                  .set(createMealPlanRecordData(
                                                    date: widget!.weekData,
                                                    typ: widget!.dateTyyp,
                                                    mealId: widget!
                                                        .editCookingMeal
                                                        ?.reference
                                                        .id,
                                                    userRef:
                                                        currentUserReference,
                                                    userFirebasemeal: widget!
                                                                .editCookingMeal !=
                                                            null
                                                        ? widget!
                                                            .editCookingMeal
                                                            ?.reference
                                                        : _model.userMeal
                                                            ?.reference,
                                                  ));
                                            }

                                            FFAppState().MealCashtearm = true;
                                            safeSetState(() {});
                                            await showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(
                                                              dialogContext)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child:
                                                        CongForANewMealWidget(
                                                      isMealPlan: true,
                                                      isGenrateForm:
                                                          widget!.isGenrateForm,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            await showDialog(
                                              context: context,
                                              builder: (dialogContext) {
                                                return Dialog(
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.zero,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  alignment:
                                                      AlignmentDirectional(
                                                              0.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(
                                                              dialogContext)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child:
                                                        CongForANewMealWidget(
                                                      isMealPlan: false,
                                                      isGenrateForm:
                                                          widget!.isGenrateForm,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        }
                                      } else {
                                        _model.isCookingInsturctionSelected =
                                            false;
                                        safeSetState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Please add at least one cooking instruction'),
                                            backgroundColor: Colors.red.shade400,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                  } else {
                                    _model.isIntgredientsSeleted = false;
                                    safeSetState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Please add at least one ingredient'),
                                        backgroundColor: Colors.red.shade400,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  }

                                  safeSetState(() {});
                                },
                                text: _getButtonText(),
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                      child: Text(
                        'This recipe will automatically be saved to your cookbook',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Andika New Basic',
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
