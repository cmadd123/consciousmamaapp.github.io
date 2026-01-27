import 'dart:math';
import 'package:collection/collection.dart';
import 'package:share_plus/share_plus.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Service for sharing content between users
class SharingService {
  // MomRise custom domain for universal sharing (works in all messaging apps)
  // This URL redirects to the app via the landing page at s/index.html
  static const String _baseUrl = 'https://momrise.app/s';

  /// Generate a random 8-character share code
  static String _generateShareCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Share a week's worth of meal plans
  /// Now supports meal combos (entree + sides + drink) and personal notes
  static Future<String?> shareMealPlan({
    required DateTime weekStart,
    required List<MealPlanRecord> mealPlans,
    required List<MealRecord> meals,
    List<MealComboRecord>? combos,
    String? customTitle,
    String? personalNote,
  }) async {
    try {
      // Generate unique share code
      String shareCode;
      bool codeExists = true;

      // Keep generating until we get a unique code
      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      // Build the content data - serialize meal plans and their recipes/combos
      final List<Map<String, dynamic>> mealsData = [];

      for (final mealPlan in mealPlans) {
        Map<String, dynamic> mealData = {
          'date_offset': mealPlan.date?.difference(weekStart).inDays ?? 0,
          'meal_type': mealPlan.typ?.name ?? 'Dinner',
          'notes': mealPlan.notes,
        };

        // Check if this meal plan uses a combo
        if (mealPlan.mealComboRef != null && combos != null) {
          final combo = combos.firstWhereOrNull(
            (c) => c.reference == mealPlan.mealComboRef,
          );

          if (combo != null) {
            // Find the entree
            MealRecord? entree;
            if (combo.entreeRef != null) {
              entree = meals.firstWhereOrNull((m) => m.reference == combo.entreeRef);
            }

            // Find the sides
            List<Map<String, dynamic>> sidesData = [];
            for (final sideRef in combo.sideRefs) {
              final side = meals.firstWhereOrNull((m) => m.reference == sideRef);
              if (side != null) {
                sidesData.add(_serializeMeal(side));
              }
            }

            mealData['combo'] = {
              'name': combo.name,
              'entree': entree != null ? _serializeMeal(entree) : null,
              'sides': sidesData,
              'drink_type': combo.drinkType?.name,
              'drink_custom': combo.drinkCustom,
              'meal_typ': combo.mealTyp?.name,
            };
          }
        }
        // Fall back to single meal reference
        else if (mealPlan.userFirebasemeal != null) {
          final meal = meals.firstWhereOrNull(
            (m) => m.reference == mealPlan.userFirebasemeal,
          );
          if (meal != null) {
            mealData['recipe'] = _serializeMeal(meal);
          }
        }

        mealsData.add(mealData);
      }

      final contentData = {
        'week_start': weekStart.toIso8601String(),
        'meals': mealsData,
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      // Get user display name
      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      // Determine title
      final title = customTitle ??
          'Week of ${_formatDate(weekStart)} Meal Plan';

      // Find a preview image from one of the meals
      String? previewImage;
      for (final meal in meals) {
        if (meal.imageUrl.isNotEmpty) {
          previewImage = meal.imageUrl;
          break;
        }
      }

      // Create the shared content record
      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.mealPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: title,
        description: '${mealPlans.length} meals planned for the week',
        previewImage: previewImage,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Share created successfully with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing meal plan: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a single day's meals from the meal plan
  static Future<String?> shareSingleDay({
    required DateTime date,
    required List<MealPlanRecord> mealPlans,
    required List<MealRecord> meals,
    List<MealComboRecord>? combos,
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      // Build the content data for this single day
      final List<Map<String, dynamic>> mealsData = [];

      for (final mealPlan in mealPlans) {
        Map<String, dynamic> mealData = {
          'date_offset': 0, // Single day is always offset 0
          'meal_type': mealPlan.typ?.name ?? 'Dinner',
          'notes': mealPlan.notes,
        };

        // Check if this meal plan uses a combo
        if (mealPlan.mealComboRef != null && combos != null) {
          final combo = combos.firstWhereOrNull(
            (c) => c.reference == mealPlan.mealComboRef,
          );

          if (combo != null) {
            MealRecord? entree;
            if (combo.entreeRef != null) {
              entree = meals.firstWhereOrNull((m) => m.reference == combo.entreeRef);
            }

            List<Map<String, dynamic>> sidesData = [];
            for (final sideRef in combo.sideRefs) {
              final side = meals.firstWhereOrNull((m) => m.reference == sideRef);
              if (side != null) {
                sidesData.add(_serializeMeal(side));
              }
            }

            mealData['combo'] = {
              'name': combo.name,
              'entree': entree != null ? _serializeMeal(entree) : null,
              'sides': sidesData,
              'drink_type': combo.drinkType?.name,
              'drink_custom': combo.drinkCustom,
              'meal_typ': combo.mealTyp?.name,
            };
          }
        } else if (mealPlan.userFirebasemeal != null) {
          final meal = meals.firstWhereOrNull(
            (m) => m.reference == mealPlan.userFirebasemeal,
          );
          if (meal != null) {
            mealData['recipe'] = _serializeMeal(meal);
          }
        }

        mealsData.add(mealData);
      }

      final contentData = {
        'day_date': date.toIso8601String(),
        'meals': mealsData,
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      final title = '${_formatDate(date)} Meals';

      String? previewImage;
      for (final meal in meals) {
        if (meal.imageUrl.isNotEmpty) {
          previewImage = meal.imageUrl;
          break;
        }
      }

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.mealPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: title,
        description: '${mealPlans.length} meal${mealPlans.length == 1 ? '' : 's'} for ${_formatDate(date)}',
        previewImage: previewImage,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Single day share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing single day: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a single meal (one meal plan entry)
  static Future<String?> shareSingleMeal({
    required MealPlanRecord mealPlan,
    required MealRecord? meal,
    MealComboRecord? combo,
    List<MealRecord>? comboMeals, // For combo sides
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      Map<String, dynamic> mealData = {
        'date_offset': 0,
        'meal_type': mealPlan.typ?.name ?? 'Dinner',
        'notes': mealPlan.notes,
      };

      String recipeName = 'Meal';
      String? previewImage;

      // Handle combo
      if (combo != null && comboMeals != null) {
        MealRecord? entree;
        if (combo.entreeRef != null) {
          entree = comboMeals.firstWhereOrNull((m) => m.reference == combo.entreeRef);
        }

        List<Map<String, dynamic>> sidesData = [];
        for (final sideRef in combo.sideRefs) {
          final side = comboMeals.firstWhereOrNull((m) => m.reference == sideRef);
          if (side != null) {
            sidesData.add(_serializeMeal(side));
          }
        }

        mealData['combo'] = {
          'name': combo.name,
          'entree': entree != null ? _serializeMeal(entree) : null,
          'sides': sidesData,
          'drink_type': combo.drinkType?.name,
          'drink_custom': combo.drinkCustom,
          'meal_typ': combo.mealTyp?.name,
        };

        recipeName = combo.name ?? entree?.recipeName ?? 'Meal Template';
        previewImage = entree?.imageUrl;
      }
      // Handle single meal
      else if (meal != null) {
        mealData['recipe'] = _serializeMeal(meal);
        recipeName = meal.recipeName ?? 'Meal';
        previewImage = meal.imageUrl;
      }

      final contentData = {
        'meals': [mealData],
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      final mealType = mealPlan.typ?.name ?? 'Meal';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.mealPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: recipeName,
        description: '$mealType recipe',
        previewImage: previewImage,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Single meal share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing single meal: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a single recipe (from cookbook, not meal plan)
  static Future<String?> shareSingleRecipe({
    required MealRecord recipe,
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      final mealData = {
        'date_offset': 0,
        'meal_type': recipe.mealTyp ?? 'Dinner',
        'recipe': _serializeMeal(recipe),
      };

      final contentData = {
        'meals': [mealData],
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.mealPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: recipe.recipeName ?? 'Recipe',
        description: '${recipe.mealTyp ?? 'Meal'} recipe',
        previewImage: recipe.imageUrl,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Single recipe share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing single recipe: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a single combo (from cookbook)
  static Future<String?> shareSingleCombo({
    required MealComboRecord combo,
    required List<MealRecord> comboMeals, // Entree and sides
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      MealRecord? entree;
      if (combo.entreeRef != null) {
        entree = comboMeals.firstWhereOrNull((m) => m.reference == combo.entreeRef);
      }

      List<Map<String, dynamic>> sidesData = [];
      for (final sideRef in combo.sideRefs) {
        final side = comboMeals.firstWhereOrNull((m) => m.reference == sideRef);
        if (side != null) {
          sidesData.add(_serializeMeal(side));
        }
      }

      final mealData = {
        'date_offset': 0,
        'meal_type': combo.mealTyp?.name ?? 'Dinner',
        'combo': {
          'name': combo.name,
          'entree': entree != null ? _serializeMeal(entree) : null,
          'sides': sidesData,
          'drink_type': combo.drinkType?.name,
          'drink_custom': combo.drinkCustom,
          'meal_typ': combo.mealTyp?.name,
        },
      };

      final contentData = {
        'meals': [mealData],
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      final comboName = combo.name ?? entree?.recipeName ?? 'Meal Template';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.mealPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: comboName,
        description: '${combo.mealTyp?.name ?? 'Meal'} template',
        previewImage: entree?.imageUrl,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Single combo share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing single combo: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a learning path
  static Future<String?> shareLearningPath({
    required LearningPathRecord learningPath,
    required List<LearningPathTasksRecord> tasks,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      // Serialize the learning path and tasks
      final List<Map<String, dynamic>> tasksData = tasks.map((task) => {
        'title': task.title,
        'description': task.description,
        'duration': task.duration,
      }).toList();

      final contentData = {
        'title': learningPath.title,
        'description': learningPath.description,
        'puzzle_theme': learningPath.puzzleTheme,
        'tasks': tasksData,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.learningPath,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: learningPath.title,
        description: learningPath.description,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      return shareCode;
    } catch (e) {
      debugPrint('Error sharing learning path: $e');
      return null;
    }
  }

  /// Share a user-created activity
  static Future<String?> shareActivity({
    required UserActivityRecord activity,
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      // Debug: Log the activity fields before serialization
      debugPrint('=== SHARE ACTIVITY DEBUG ===');
      debugPrint('Activity title: "${activity.title}"');
      debugPrint('Activity description: "${activity.description}"');
      debugPrint('Activity thingsNeeded: "${activity.thingsNeeded}"');
      debugPrint('Activity timeDuration: "${activity.timeDuration}"');
      debugPrint('Activity parentProximity: "${activity.parentProximity}"');
      debugPrint('Activity setupTime: "${activity.setupTime}"');
      debugPrint('Activity cleanupDifficulty: "${activity.cleanupDifficulty}"');
      debugPrint('Activity safetyNote: "${activity.safetyNote}"');
      debugPrint('Activity iconEmoji: "${activity.iconEmoji}"');

      // Serialize the activity data
      final contentData = {
        'title': activity.title,
        'description': activity.description,
        'location': activity.location,
        'energy': activity.energy,
        'things_needed': activity.thingsNeeded,
        'time_duration': activity.timeDuration,
        'parent_proximity': activity.parentProximity,
        'setup_time': activity.setupTime,
        'cleanup_difficulty': activity.cleanupDifficulty,
        'icon_emoji': activity.iconEmoji,
        'icon_code_point': activity.iconCodePoint,
        'icon_color': activity.iconColor,
        'safety_note': activity.safetyNote,
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      debugPrint('ContentData being saved: $contentData');

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.activity,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: activity.title,
        description: activity.description,
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Activity share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing activity: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Share a week's worth of activities (Activity Plan)
  static Future<String?> shareActivityPlan({
    required DateTime weekStart,
    required List<EventAndTaskRecord> activities,
    String? planTitle,
    String? personalNote,
  }) async {
    try {
      String shareCode;
      bool codeExists = true;

      do {
        shareCode = _generateShareCode();
        final existing = await SharedContentRecord.getByShareCode(shareCode);
        codeExists = existing != null;
      } while (codeExists);

      // Use weekStart as the reference point (should be "today" from caller)
      // This way day_offset 0 = today, 1 = tomorrow, etc.
      final normalizedStart = DateTime(weekStart.year, weekStart.month, weekStart.day);

      // Serialize activities with day offset from today (not Monday)
      final List<Map<String, dynamic>> activitiesData = activities.map((activity) {
        final activityDate = activity.date;
        int dayOffset = 0;
        if (activityDate != null) {
          final normalizedActivityDate = DateTime(activityDate.year, activityDate.month, activityDate.day);
          dayOffset = normalizedActivityDate.difference(normalizedStart).inDays;
        }

        return {
          'name': activity.name,
          'description': activity.description,
          'day_offset': dayOffset,
          'assigned_to_mom': activity.assignedToMom,
          'assigned_to_dad': activity.assignedToDad,
          'is_recurring': activity.isrecurring,
          'typ': activity.typ,
          // Include all activity detail fields
          'things_needed': activity.thingsNeeded,
          'time_duration': activity.timeDuration,
          'parent_proximity': activity.parentProximity,
          'setup_time': activity.setupTime,
          'cleanup_difficulty': activity.cleanupDifficulty,
          'icon_emoji': activity.iconEmoji,
          'icon_code_point': activity.iconCodePoint,
          'icon_color': activity.iconColor,
          'safety_note': activity.safetyNote,
        };
      }).toList();

      final contentData = {
        'plan_title': planTitle ?? 'Activity Plan',
        'activities': activitiesData,
        'activity_count': activities.length,
        if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      };

      final userName = currentUserDisplayName.isNotEmpty
          ? currentUserDisplayName
          : 'A MomRise User';

      await SharedContentRecord.collection.add(createSharedContentRecordData(
        shareCode: shareCode,
        contentType: SharedContentType.activityPlan,
        sharedByUser: currentUserReference,
        sharedByName: userName,
        title: planTitle ?? 'Activity Plan',
        description: '${activities.length} activities for the week',
        contentData: contentData,
        createdAt: DateTime.now(),
        viewCount: 0,
        importCount: 0,
        isActive: true,
      ));

      debugPrint('Activity plan share created with code: $shareCode');
      return shareCode;
    } catch (e, stackTrace) {
      debugPrint('Error sharing activity plan: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get the full shareable URL from a share code
  static String getShareUrl(String shareCode) {
    return '$_baseUrl/$shareCode';
  }

  /// Extract share code from a URL
  static String? extractShareCode(String url) {
    // Handle various URL formats
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Check if it's our custom domain (momrise.app/s/code)
    if (uri.host == 'momrise.app' && uri.pathSegments.length >= 2) {
      if (uri.pathSegments[0] == 's') {
        return uri.pathSegments[1];
      }
      // Also support legacy /shared/ path
      if (uri.pathSegments[0] == 'shared') {
        return uri.pathSegments[1];
      }
    }

    // Support GitHub Pages URLs (cmadd123.github.io/s/code or /shared/code)
    if (uri.host == 'cmadd123.github.io' && uri.pathSegments.length >= 2) {
      if (uri.pathSegments[0] == 's' || uri.pathSegments[0] == 'shared') {
        return uri.pathSegments[1];
      }
    }

    // Also handle direct codes
    if (url.length == 8 && RegExp(r'^[a-z0-9]+$').hasMatch(url)) {
      return url;
    }

    return null;
  }

  /// Preview what will be imported - returns lists of meals to add vs skip
  static Future<MealPlanImportPreview> previewMealPlanImport({
    required SharedContentRecord sharedContent,
    required DateTime targetWeekStart,
  }) async {
    final toImport = <MealPreviewItem>[];
    final toSkip = <MealPreviewItem>[];

    if (sharedContent.contentType != SharedContentType.mealPlan) {
      return MealPlanImportPreview(toImport: toImport, toSkip: toSkip);
    }

    final contentData = sharedContent.contentData;
    final meals = contentData['meals'] as List<dynamic>? ?? [];

    // Fetch the user's existing meal plans for the target week
    final weekEnd = targetWeekStart.add(const Duration(days: 7));
    final existingPlansSnapshot = await MealPlanRecord.collection
        .where('user_ref', isEqualTo: currentUserReference)
        .get();

    // Filter to the target week and create a set of occupied slots
    final existingPlans = existingPlansSnapshot.docs
        .map((doc) => MealPlanRecord.fromSnapshot(doc))
        .where((plan) {
          if (plan.date == null) return false;
          return plan.date!.isAfter(targetWeekStart.subtract(const Duration(days: 1))) &&
                 plan.date!.isBefore(weekEnd);
        })
        .toList();

    // Build a set of occupied slots: "dayOffset-mealType"
    final occupiedSlots = <String>{};
    for (final plan in existingPlans) {
      if (plan.date != null && plan.typ != null) {
        final dayOffset = plan.date!.difference(targetWeekStart).inDays;
        occupiedSlots.add('$dayOffset-${plan.typ!.name}');
      }
    }

    for (final mealData in meals) {
      final recipe = mealData['recipe'] as Map<String, dynamic>?;
      final combo = mealData['combo'] as Map<String, dynamic>?;
      final dateOffset = mealData['date_offset'] as int? ?? 0;
      final mealTypeStr = mealData['meal_type'] as String? ?? 'Dinner';
      final slotKey = '$dateOffset-$mealTypeStr';
      final mealDate = targetWeekStart.add(Duration(days: dateOffset));

      // Determine the display name - prefer combo name/entree, fall back to recipe
      String recipeName = 'Unknown';
      bool isCombo = false;
      if (combo != null) {
        isCombo = true;
        final comboName = combo['name'] as String?;
        final entree = combo['entree'] as Map<String, dynamic>?;
        if (comboName != null && comboName.isNotEmpty) {
          recipeName = comboName;
        } else if (entree != null) {
          recipeName = entree['recipe_name'] ?? 'Meal Template';
        }
      } else if (recipe != null) {
        recipeName = recipe['recipe_name'] ?? 'Unknown';
      }

      final item = MealPreviewItem(
        recipeName: recipeName,
        mealType: mealTypeStr,
        date: mealDate,
        isCombo: isCombo,
      );

      if (occupiedSlots.contains(slotKey)) {
        toSkip.add(item);
      } else {
        toImport.add(item);
      }
    }

    return MealPlanImportPreview(toImport: toImport, toSkip: toSkip);
  }

  /// Import a shared meal plan to the current user's account
  /// Only imports meals for slots that are empty (doesn't override existing meals)
  /// Returns MealPlanImportResult with counts of imported/skipped meals
  static Future<MealPlanImportResult> importMealPlan({
    required SharedContentRecord sharedContent,
    required DateTime targetWeekStart,
  }) async {
    try {
      if (sharedContent.contentType != SharedContentType.mealPlan) {
        return MealPlanImportResult(success: false, imported: 0, skipped: 0);
      }

      final contentData = sharedContent.contentData;
      final meals = contentData['meals'] as List<dynamic>? ?? [];

      // Fetch the user's existing meal plans for the target week
      final weekEnd = targetWeekStart.add(const Duration(days: 7));
      final existingPlansSnapshot = await MealPlanRecord.collection
          .where('user_ref', isEqualTo: currentUserReference)
          .get();

      // Filter to the target week and create a set of occupied slots (date + meal type)
      final existingPlans = existingPlansSnapshot.docs
          .map((doc) => MealPlanRecord.fromSnapshot(doc))
          .where((plan) {
            if (plan.date == null) return false;
            return plan.date!.isAfter(targetWeekStart.subtract(const Duration(days: 1))) &&
                   plan.date!.isBefore(weekEnd);
          })
          .toList();

      // Build a set of occupied slots: "dayOffset-mealType"
      final occupiedSlots = <String>{};
      for (final plan in existingPlans) {
        if (plan.date != null && plan.typ != null) {
          final dayOffset = plan.date!.difference(targetWeekStart).inDays;
          occupiedSlots.add('$dayOffset-${plan.typ!.name}');
        }
      }

      int importedCount = 0;
      int skippedCount = 0;

      for (final mealData in meals) {
        final recipe = mealData['recipe'] as Map<String, dynamic>?;
        final combo = mealData['combo'] as Map<String, dynamic>?;
        final dateOffset = mealData['date_offset'] as int? ?? 0;
        final mealTypeStr = mealData['meal_type'] as String?;
        final slotKey = '$dateOffset-$mealTypeStr';

        // Skip if slot is already occupied
        if (occupiedSlots.contains(slotKey)) {
          skippedCount++;
          debugPrint('Skipping import for slot $slotKey - already has a meal planned');
          continue;
        }

        // Calculate the date for this meal
        final mealDate = targetWeekStart.add(Duration(days: dateOffset));

        // Handle combo import (entree + sides + drink)
        if (combo != null) {
          DocumentReference? entreeRef;
          List<DocumentReference> sideRefs = [];

          // Create entree
          final entreeData = combo['entree'] as Map<String, dynamic>?;
          if (entreeData != null) {
            entreeRef = await _createMealFromData(entreeData);
          }

          // Create sides
          final sidesData = combo['sides'] as List<dynamic>? ?? [];
          for (final sideData in sidesData) {
            if (sideData is Map<String, dynamic>) {
              final sideRef = await _createMealFromData(sideData);
              sideRefs.add(sideRef);
            }
          }

          // Create the combo
          final comboRef = await MealComboRecord.collection.add(createMealComboRecordData(
            name: combo['name'] as String?,
            entreeRef: entreeRef,
            drinkType: _parseDrinkType(combo['drink_type'] as String?),
            drinkCustom: combo['drink_custom'] as String?,
            mealTyp: _parseMealType(combo['meal_typ'] as String?),
            userRef: currentUserReference,
            createdTime: DateTime.now(),
          ));

          // Add side refs to the combo
          if (sideRefs.isNotEmpty) {
            await comboRef.update({
              'side_refs': sideRefs,
            });
          }

          // Create the meal plan entry with combo reference
          await MealPlanRecord.collection.add(createMealPlanRecordData(
            date: mealDate,
            typ: _parseMealType(mealTypeStr),
            userRef: currentUserReference,
            mealComboRef: comboRef,
            notes: mealData['notes'] as String?,
          ));

          importedCount++;
        }
        // Handle single recipe import
        else if (recipe != null) {
          final mealRef = await _createMealFromData(recipe);

          // Create the meal plan entry
          await MealPlanRecord.collection.add(createMealPlanRecordData(
            date: mealDate,
            typ: _parseMealType(mealTypeStr),
            userRef: currentUserReference,
            userFirebasemeal: mealRef,
            notes: mealData['notes'] as String?,
          ));

          importedCount++;
        }
      }

      debugPrint('Import complete: $importedCount meals imported, $skippedCount skipped (slots occupied)');

      // Increment import count
      await sharedContent.reference.update({
        'import_count': FieldValue.increment(1),
      });

      return MealPlanImportResult(success: true, imported: importedCount, skipped: skippedCount);
    } catch (e) {
      debugPrint('Error importing meal plan: $e');
      return MealPlanImportResult(success: false, imported: 0, skipped: 0, error: e.toString());
    }
  }

  /// Import a shared learning path to the current user's account
  static Future<DocumentReference?> importLearningPath({
    required SharedContentRecord sharedContent,
    required DocumentReference childRef,
  }) async {
    try {
      if (sharedContent.contentType != SharedContentType.learningPath) {
        return null;
      }

      final contentData = sharedContent.contentData;

      // Create the learning path
      final pathRef = await LearningPathRecord.collection.add(
        createLearningPathRecordData(
          title: contentData['title'],
          description: contentData['description'],
          puzzleTheme: contentData['puzzle_theme'],
          userRef: currentUserReference,
          childRef: childRef,
          startDate: DateTime.now(),
          isCompleted: false,
        ),
      );

      // Create the tasks
      final tasks = contentData['tasks'] as List<dynamic>? ?? [];
      for (final taskData in tasks) {
        await LearningPathTasksRecord.collection.add(
          createLearningPathTasksRecordData(
            programRef: pathRef,
            title: taskData['title'],
            description: taskData['description'],
            duration: taskData['duration'],
            userRef: currentUserReference,
            childRef: childRef,
            isCompleted: false,
          ),
        );
      }

      // Increment import count
      await sharedContent.reference.update({
        'import_count': FieldValue.increment(1),
      });

      return pathRef;
    } catch (e) {
      debugPrint('Error importing learning path: $e');
      return null;
    }
  }

  /// Import a shared activity to the current user's account
  static Future<DocumentReference?> importActivity({
    required SharedContentRecord sharedContent,
  }) async {
    try {
      if (sharedContent.contentType != SharedContentType.activity) {
        return null;
      }

      final contentData = sharedContent.contentData;

      // Debug: Log what we received from Firestore
      debugPrint('=== IMPORT ACTIVITY DEBUG ===');
      debugPrint('ContentData received: $contentData');
      debugPrint('ContentData keys: ${contentData.keys.toList()}');
      debugPrint('title value: "${contentData['title']}" (type: ${contentData['title']?.runtimeType})');
      debugPrint('description value: "${contentData['description']}" (type: ${contentData['description']?.runtimeType})');
      debugPrint('things_needed value: "${contentData['things_needed']}" (type: ${contentData['things_needed']?.runtimeType})');
      debugPrint('time_duration value: "${contentData['time_duration']}" (type: ${contentData['time_duration']?.runtimeType})');
      debugPrint('parent_proximity value: "${contentData['parent_proximity']}" (type: ${contentData['parent_proximity']?.runtimeType})');
      debugPrint('setup_time value: "${contentData['setup_time']}" (type: ${contentData['setup_time']?.runtimeType})');
      debugPrint('cleanup_difficulty value: "${contentData['cleanup_difficulty']}" (type: ${contentData['cleanup_difficulty']?.runtimeType})');
      debugPrint('safety_note value: "${contentData['safety_note']}" (type: ${contentData['safety_note']?.runtimeType})');

      // Helper function to safely cast to int (handles both int and num types)
      int? safeInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      // Helper function to safely cast to String
      String? safeString(dynamic value) {
        if (value == null) return null;
        if (value is String && value.isEmpty) return null;
        return value.toString();
      }

      // Create the user activity with safe casting for all fields
      final activityRef = await UserActivityRecord.collection.add(
        createUserActivityRecordData(
          userRef: currentUserReference,
          title: safeString(contentData['title']),
          description: safeString(contentData['description']),
          location: safeString(contentData['location']),
          energy: safeString(contentData['energy']),
          thingsNeeded: safeString(contentData['things_needed']),
          timeDuration: safeString(contentData['time_duration']),
          parentProximity: safeString(contentData['parent_proximity']),
          setupTime: safeString(contentData['setup_time']),
          cleanupDifficulty: safeString(contentData['cleanup_difficulty']),
          iconEmoji: safeString(contentData['icon_emoji']),
          iconCodePoint: safeInt(contentData['icon_code_point']),
          iconColor: safeInt(contentData['icon_color']),
          safetyNote: safeString(contentData['safety_note']),
          isFavorite: false,
          createdTime: DateTime.now(),
          updatedTime: DateTime.now(),
          timesUsed: 0,
        ),
      );

      // Increment import count
      await sharedContent.reference.update({
        'import_count': FieldValue.increment(1),
      });

      debugPrint('Activity imported successfully with fields: title=${contentData['title']}, description=${contentData['description']}, thingsNeeded=${contentData['things_needed']}, timeDuration=${contentData['time_duration']}, parentProximity=${contentData['parent_proximity']}, setupTime=${contentData['setup_time']}, cleanupDifficulty=${contentData['cleanup_difficulty']}');
      return activityRef;
    } catch (e, stackTrace) {
      debugPrint('Error importing activity: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Import a shared activity plan to the current user's calendar
  static Future<int> importActivityPlan({
    required SharedContentRecord sharedContent,
    required DateTime targetWeekStart,
    List<DocumentReference>? assignToChildren,
    bool? assignToMom,
    bool? assignToDad,
  }) async {
    try {
      if (sharedContent.contentType != SharedContentType.activityPlan) {
        return 0;
      }

      final contentData = sharedContent.contentData;
      final activities = contentData['activities'] as List<dynamic>? ?? [];

      // Use targetWeekStart directly (should be "today" from the caller)
      // day_offset 0 = today, 1 = tomorrow, etc.
      final normalizedStart = DateTime(targetWeekStart.year, targetWeekStart.month, targetWeekStart.day);

      int importedCount = 0;

      for (final activityData in activities) {
        final dayOffset = activityData['day_offset'] as int? ?? 0;
        final targetDate = normalizedStart.add(Duration(days: dayOffset));

        // Only import activities within the week (0-6 days)
        if (dayOffset < 0 || dayOffset > 6) continue;

        // Helper to safely get int values
        int? safeInt(dynamic value) {
          if (value == null) return null;
          if (value is int) return value;
          if (value is num) return value.toInt();
          return null;
        }

        await EventAndTaskRecord.collection.add(
          createEventAndTaskRecordData(
            name: activityData['name'] as String?,
            description: activityData['description'] as String?,
            date: targetDate,
            typ: activityData['typ'] as String? ?? 'Task',
            isrecurring: activityData['is_recurring'] as bool? ?? false,
            isCompleted: false,
            userRef: currentUserReference,
            assignedToMom: assignToMom ?? (activityData['assigned_to_mom'] as bool? ?? false),
            assignedToDad: assignToDad ?? (activityData['assigned_to_dad'] as bool? ?? false),
            selectedChildren: assignToChildren ?? [],
            // Include all activity detail fields
            thingsNeeded: activityData['things_needed'] as String?,
            timeDuration: activityData['time_duration'] as String?,
            parentProximity: activityData['parent_proximity'] as String?,
            setupTime: activityData['setup_time'] as String?,
            cleanupDifficulty: activityData['cleanup_difficulty'] as String?,
            iconEmoji: activityData['icon_emoji'] as String?,
            iconCodePoint: safeInt(activityData['icon_code_point']),
            iconColor: safeInt(activityData['icon_color']),
            safetyNote: activityData['safety_note'] as String?,
          ),
        );
        importedCount++;
      }

      // Increment import count
      await sharedContent.reference.update({
        'import_count': FieldValue.increment(1),
      });

      debugPrint('Imported $importedCount activities from activity plan');
      return importedCount;
    } catch (e) {
      debugPrint('Error importing activity plan: $e');
      return 0;
    }
  }

  /// Trigger native share dialog
  static Future<void> shareViaSystem({
    required String shareCode,
    required String title,
    String? description,
  }) async {
    final url = getShareUrl(shareCode);
    final text = description != null
        ? '$title\n\n$description\n\n$url'
        : '$title\n\n$url';

    await Share.share(
      text,
      subject: title,
    );
  }

  /// Increment view count when someone opens a shared link
  static Future<void> incrementViewCount(SharedContentRecord sharedContent) async {
    await sharedContent.reference.update({
      'view_count': FieldValue.increment(1),
    });
  }

  static String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  static MealTyp? _parseMealType(String? type) {
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealTyp.Breakfast;
      case 'lunch':
        return MealTyp.Lunch;
      case 'dinner':
        return MealTyp.Dinner;
      case 'snacks':
      case 'snack':
        return MealTyp.Snacks;
      default:
        return MealTyp.Dinner;
    }
  }

  static DrinkType? _parseDrinkType(String? type) {
    if (type == null) return null;
    switch (type.toLowerCase()) {
      case 'water':
        return DrinkType.Water;
      case 'milk':
        return DrinkType.Milk;
      case 'juice':
        return DrinkType.Juice;
      case 'smoothie':
        return DrinkType.Smoothie;
      case 'other':
        return DrinkType.Other;
      default:
        return DrinkType.Water;
    }
  }

  /// Helper to create a meal record from serialized data
  static Future<DocumentReference> _createMealFromData(Map<String, dynamic> data) async {
    final mealRef = await MealRecord.collection.add(createMealRecordData(
      recipeName: data['recipe_name'] as String?,
      imageUrl: data['image_url'] as String?,
      prepareTime: (data['prepare_time'] as num?)?.toDouble(),
      cookingTime: (data['cooking_time'] as num?)?.toDouble(),
      mealTyp: data['meal_typ'] as String?,
      userRef: currentUserReference,
    ));

    // Update ingredients and cooking instructions (arrays)
    await mealRef.update({
      'ingredients': data['ingredients'] ?? [],
      'CookingInstructions': data['cooking_instructions'] ?? [],
    });

    return mealRef;
  }

  /// Helper to serialize a meal record to a map
  static Map<String, dynamic> _serializeMeal(MealRecord meal) {
    return {
      'recipe_name': meal.recipeName,
      'image_url': meal.imageUrl,
      'ingredients': meal.ingredients,
      'cooking_instructions': meal.cookingInstructions,
      'prepare_time': meal.prepareTime,
      'cooking_time': meal.cookingTime,
      'meal_typ': meal.mealTyp,
      'recipe_type': meal.recipeType?.name,
    };
  }
}

// Helper for debug printing
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}

/// Result of a meal plan import operation
class MealPlanImportResult {
  final bool success;
  final int imported;
  final int skipped;
  final String? error;

  MealPlanImportResult({
    required this.success,
    required this.imported,
    required this.skipped,
    this.error,
  });
}

/// Preview of what will be imported
class MealPlanImportPreview {
  final List<MealPreviewItem> toImport;
  final List<MealPreviewItem> toSkip;

  MealPlanImportPreview({
    required this.toImport,
    required this.toSkip,
  });

  int get totalToImport => toImport.length;
  int get totalToSkip => toSkip.length;
  int get total => toImport.length + toSkip.length;
}

/// Individual meal item for preview
class MealPreviewItem {
  final String recipeName;
  final String mealType;
  final DateTime date;
  final bool isCombo;

  MealPreviewItem({
    required this.recipeName,
    required this.mealType,
    required this.date,
    this.isCombo = false,
  });
}
