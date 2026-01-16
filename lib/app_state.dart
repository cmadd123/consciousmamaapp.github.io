import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _selectedChildForMilestone =
          prefs.getString('ff_selectedChildForMilestone')?.ref ??
              _selectedChildForMilestone;
    });
    _safeInit(() {
      _listOfchildrenthreetimes = prefs
              .getStringList('ff_listOfchildrenthreetimes')
              ?.map((path) => path.ref)
              .toList() ??
          _listOfchildrenthreetimes;
    });
    _safeInit(() {
      _activities = prefs
              .getStringList('ff_activities')
              ?.map((path) => path.ref)
              .toList() ??
          _activities;
    });
    _safeInit(() {
      _HomeActivityModel = prefs
              .getStringList('ff_HomeActivityModel')
              ?.map((x) {
                try {
                  return HomeActivtyModelStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _HomeActivityModel;
    });
    // Comfort mode disabled - always use standard mode
    // _safeInit(() {
    //   _isComfortMode = prefs.getBool('ff_isComfortMode') ?? _isComfortMode;
    // });
    _safeInit(() {
      _favoriteActivities = prefs
              .getStringList('ff_favoriteActivities')
              ?.map((path) => path.ref)
              .toList() ??
          _favoriteActivities;
    });
    _safeInit(() {
      _loadGroceryItems();
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<MessagesForSteamStruct> _messages = [];
  List<MessagesForSteamStruct> get messages => _messages;
  set messages(List<MessagesForSteamStruct> value) {
    _messages = value;
  }

  void addToMessages(MessagesForSteamStruct value) {
    messages.add(value);
  }

  void removeFromMessages(MessagesForSteamStruct value) {
    messages.remove(value);
  }

  void removeAtIndexFromMessages(int index) {
    messages.removeAt(index);
  }

  void updateMessagesAtIndex(
    int index,
    MessagesForSteamStruct Function(MessagesForSteamStruct) updateFn,
  ) {
    messages[index] = updateFn(_messages[index]);
  }

  void insertAtIndexInMessages(int index, MessagesForSteamStruct value) {
    messages.insert(index, value);
  }

  bool _editing = false;
  bool get editing => _editing;
  set editing(bool value) {
    _editing = value;
  }

  bool _isComfortMode = false;
  bool get isComfortMode => _isComfortMode;
  set isComfortMode(bool value) {
    _isComfortMode = value;
    prefs.setBool('ff_isComfortMode', value);
  }

  List<DocumentReference> _favoriteActivities = [];
  List<DocumentReference> get favoriteActivities => _favoriteActivities;
  set favoriteActivities(List<DocumentReference> value) {
    _favoriteActivities = value;
    prefs.setStringList('ff_favoriteActivities', value.map((x) => x.path).toList());
  }

  void addToFavoriteActivities(DocumentReference value) {
    favoriteActivities.add(value);
    prefs.setStringList(
        'ff_favoriteActivities', _favoriteActivities.map((x) => x.path).toList());
  }

  void removeFromFavoriteActivities(DocumentReference value) {
    favoriteActivities.remove(value);
    prefs.setStringList(
        'ff_favoriteActivities', _favoriteActivities.map((x) => x.path).toList());
  }

  bool isFavoriteActivity(DocumentReference value) {
    return _favoriteActivities.contains(value);
  }

  void toggleFavoriteActivity(DocumentReference value) {
    if (isFavoriteActivity(value)) {
      removeFromFavoriteActivities(value);
    } else {
      addToFavoriteActivities(value);
    }
  }

  DocumentReference? _selectedChildForMilestone;
  DocumentReference? get selectedChildForMilestone =>
      _selectedChildForMilestone;
  set selectedChildForMilestone(DocumentReference? value) {
    _selectedChildForMilestone = value;
    value != null
        ? prefs.setString('ff_selectedChildForMilestone', value.path)
        : prefs.remove('ff_selectedChildForMilestone');
  }

  List<DocumentReference> _listOfchildrenthreetimes = [];
  List<DocumentReference> get listOfchildrenthreetimes =>
      _listOfchildrenthreetimes;
  set listOfchildrenthreetimes(List<DocumentReference> value) {
    _listOfchildrenthreetimes = value;
    prefs.setStringList(
        'ff_listOfchildrenthreetimes', value.map((x) => x.path).toList());
  }

  void addToListOfchildrenthreetimes(DocumentReference value) {
    listOfchildrenthreetimes.add(value);
    prefs.setStringList('ff_listOfchildrenthreetimes',
        _listOfchildrenthreetimes.map((x) => x.path).toList());
  }

  void removeFromListOfchildrenthreetimes(DocumentReference value) {
    listOfchildrenthreetimes.remove(value);
    prefs.setStringList('ff_listOfchildrenthreetimes',
        _listOfchildrenthreetimes.map((x) => x.path).toList());
  }

  void removeAtIndexFromListOfchildrenthreetimes(int index) {
    listOfchildrenthreetimes.removeAt(index);
    prefs.setStringList('ff_listOfchildrenthreetimes',
        _listOfchildrenthreetimes.map((x) => x.path).toList());
  }

  void updateListOfchildrenthreetimesAtIndex(
    int index,
    DocumentReference Function(DocumentReference) updateFn,
  ) {
    listOfchildrenthreetimes[index] =
        updateFn(_listOfchildrenthreetimes[index]);
    prefs.setStringList('ff_listOfchildrenthreetimes',
        _listOfchildrenthreetimes.map((x) => x.path).toList());
  }

  void insertAtIndexInListOfchildrenthreetimes(
      int index, DocumentReference value) {
    listOfchildrenthreetimes.insert(index, value);
    prefs.setStringList('ff_listOfchildrenthreetimes',
        _listOfchildrenthreetimes.map((x) => x.path).toList());
  }

  List<DocumentReference> _activities = [];
  List<DocumentReference> get activities => _activities;
  set activities(List<DocumentReference> value) {
    _activities = value;
    prefs.setStringList('ff_activities', value.map((x) => x.path).toList());
  }

  void addToActivities(DocumentReference value) {
    activities.add(value);
    prefs.setStringList(
        'ff_activities', _activities.map((x) => x.path).toList());
  }

  void removeFromActivities(DocumentReference value) {
    activities.remove(value);
    prefs.setStringList(
        'ff_activities', _activities.map((x) => x.path).toList());
  }

  void removeAtIndexFromActivities(int index) {
    activities.removeAt(index);
    prefs.setStringList(
        'ff_activities', _activities.map((x) => x.path).toList());
  }

  void updateActivitiesAtIndex(
    int index,
    DocumentReference Function(DocumentReference) updateFn,
  ) {
    activities[index] = updateFn(_activities[index]);
    prefs.setStringList(
        'ff_activities', _activities.map((x) => x.path).toList());
  }

  void insertAtIndexInActivities(int index, DocumentReference value) {
    activities.insert(index, value);
    prefs.setStringList(
        'ff_activities', _activities.map((x) => x.path).toList());
  }

  List<ChildActivityStruct> _activityFinalModel = [];
  List<ChildActivityStruct> get activityFinalModel => _activityFinalModel;
  set activityFinalModel(List<ChildActivityStruct> value) {
    _activityFinalModel = value;
  }

  void addToActivityFinalModel(ChildActivityStruct value) {
    activityFinalModel.add(value);
  }

  void removeFromActivityFinalModel(ChildActivityStruct value) {
    activityFinalModel.remove(value);
  }

  void removeAtIndexFromActivityFinalModel(int index) {
    activityFinalModel.removeAt(index);
  }

  void updateActivityFinalModelAtIndex(
    int index,
    ChildActivityStruct Function(ChildActivityStruct) updateFn,
  ) {
    activityFinalModel[index] = updateFn(_activityFinalModel[index]);
  }

  void insertAtIndexInActivityFinalModel(int index, ChildActivityStruct value) {
    activityFinalModel.insert(index, value);
  }

  List<DocumentReference> _iniailRandomDataTwoGetTwoOnly = [];
  List<DocumentReference> get iniailRandomDataTwoGetTwoOnly =>
      _iniailRandomDataTwoGetTwoOnly;
  set iniailRandomDataTwoGetTwoOnly(List<DocumentReference> value) {
    _iniailRandomDataTwoGetTwoOnly = value;
  }

  void addToIniailRandomDataTwoGetTwoOnly(DocumentReference value) {
    iniailRandomDataTwoGetTwoOnly.add(value);
  }

  void removeFromIniailRandomDataTwoGetTwoOnly(DocumentReference value) {
    iniailRandomDataTwoGetTwoOnly.remove(value);
  }

  void removeAtIndexFromIniailRandomDataTwoGetTwoOnly(int index) {
    iniailRandomDataTwoGetTwoOnly.removeAt(index);
  }

  void updateIniailRandomDataTwoGetTwoOnlyAtIndex(
    int index,
    DocumentReference Function(DocumentReference) updateFn,
  ) {
    iniailRandomDataTwoGetTwoOnly[index] =
        updateFn(_iniailRandomDataTwoGetTwoOnly[index]);
  }

  void insertAtIndexInIniailRandomDataTwoGetTwoOnly(
      int index, DocumentReference value) {
    iniailRandomDataTwoGetTwoOnly.insert(index, value);
  }

  List<HomeActivtyModelStruct> _HomeActivityModel = [];
  List<HomeActivtyModelStruct> get HomeActivityModel => _HomeActivityModel;
  set HomeActivityModel(List<HomeActivtyModelStruct> value) {
    _HomeActivityModel = value;
    prefs.setStringList(
        'ff_HomeActivityModel', value.map((x) => x.serialize()).toList());
  }

  void addToHomeActivityModel(HomeActivtyModelStruct value) {
    HomeActivityModel.add(value);
    prefs.setStringList('ff_HomeActivityModel',
        _HomeActivityModel.map((x) => x.serialize()).toList());
  }

  void removeFromHomeActivityModel(HomeActivtyModelStruct value) {
    HomeActivityModel.remove(value);
    prefs.setStringList('ff_HomeActivityModel',
        _HomeActivityModel.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromHomeActivityModel(int index) {
    HomeActivityModel.removeAt(index);
    prefs.setStringList('ff_HomeActivityModel',
        _HomeActivityModel.map((x) => x.serialize()).toList());
  }

  void updateHomeActivityModelAtIndex(
    int index,
    HomeActivtyModelStruct Function(HomeActivtyModelStruct) updateFn,
  ) {
    HomeActivityModel[index] = updateFn(_HomeActivityModel[index]);
    prefs.setStringList('ff_HomeActivityModel',
        _HomeActivityModel.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInHomeActivityModel(
      int index, HomeActivtyModelStruct value) {
    HomeActivityModel.insert(index, value);
    prefs.setStringList('ff_HomeActivityModel',
        _HomeActivityModel.map((x) => x.serialize()).toList());
  }

  // ==================== GROCERY LIST ====================
  // New structured grocery list with quantity aggregation
  List<GroceryItemStruct> _groceryItems = [];
  List<GroceryItemStruct> get groceryItems => _groceryItems;
  set groceryItems(List<GroceryItemStruct> value) {
    _groceryItems = value;
    _persistGroceryItems();
  }

  // Legacy string-based list for backward compatibility
  // This now returns display strings from the structured items
  List<String> get userGroceryList =>
      _groceryItems.map((item) => item.displayText).toList();

  set userGroceryList(List<String> value) {
    // Convert strings to structured items
    _groceryItems = value.map((str) =>
        GroceryItemStruct.fromIngredientString(str)).toList();
    _persistGroceryItems();
  }

  /// Add an ingredient string with smart aggregation.
  /// If "2 cups flour" exists and you add "3 cups flour",
  /// the result will be "5 cups flour".
  void addToUserGroceryList(String value) {
    addGroceryItemWithAggregation(
        GroceryItemStruct.fromIngredientString(value));
  }

  /// Add a GroceryItemStruct with smart aggregation
  void addGroceryItemWithAggregation(GroceryItemStruct newItem) {
    // Look for an existing item with the same name and unit
    final existingIndex = _groceryItems.indexWhere(
        (item) => item.canAggregateWith(newItem));

    if (existingIndex != -1) {
      // Aggregate quantities
      final existing = _groceryItems[existingIndex];
      existing.quantity = existing.quantity + newItem.quantity;
      _groceryItems[existingIndex] = existing;
    } else {
      // Add as new item
      _groceryItems.add(newItem);
    }
    _persistGroceryItems();
  }

  /// Add multiple ingredients from a recipe with aggregation
  void addIngredientsFromRecipe(List<String> ingredients) {
    for (final ingredient in ingredients) {
      addToUserGroceryList(ingredient);
    }
  }

  void removeFromUserGroceryList(String value) {
    _groceryItems.removeWhere((item) => item.displayText == value);
    _persistGroceryItems();
  }

  void removeAtIndexFromUserGroceryList(int index) {
    if (index >= 0 && index < _groceryItems.length) {
      _groceryItems.removeAt(index);
      _persistGroceryItems();
    }
  }

  void updateUserGroceryListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    if (index >= 0 && index < _groceryItems.length) {
      final oldText = _groceryItems[index].displayText;
      final newText = updateFn(oldText);
      _groceryItems[index] = GroceryItemStruct.fromIngredientString(newText);
      _persistGroceryItems();
    }
  }

  void insertAtIndexInUserGroceryList(int index, String value) {
    final item = GroceryItemStruct.fromIngredientString(value);
    if (index >= 0 && index <= _groceryItems.length) {
      _groceryItems.insert(index, item);
      _persistGroceryItems();
    }
  }

  /// Toggle checked state for a grocery item
  void toggleGroceryItemChecked(int index) {
    if (index >= 0 && index < _groceryItems.length) {
      _groceryItems[index].isChecked = !_groceryItems[index].isChecked;
      _persistGroceryItems();
    }
  }

  /// Get grocery item at index
  GroceryItemStruct? getGroceryItemAt(int index) {
    if (index >= 0 && index < _groceryItems.length) {
      return _groceryItems[index];
    }
    return null;
  }

  /// Clear all checked items
  void clearCheckedGroceryItems() {
    _groceryItems.removeWhere((item) => item.isChecked);
    _persistGroceryItems();
  }

  /// Persist grocery items to SharedPreferences
  void _persistGroceryItems() {
    prefs.setStringList('ff_groceryItems',
        _groceryItems.map((x) => jsonEncode(x.toSerializableMap())).toList());
    notifyListeners(); // Notify UI to rebuild
  }

  /// Load grocery items from SharedPreferences (call in initializePersistedState)
  void _loadGroceryItems() {
    final stored = prefs.getStringList('ff_groceryItems');
    if (stored != null) {
      _groceryItems = stored.map((x) {
        try {
          return GroceryItemStruct.fromSerializableMap(jsonDecode(x));
        } catch (e) {
          print("Can't decode grocery item. Error: $e.");
          return null;
        }
      }).whereType<GroceryItemStruct>().toList();
    }
  }
  // ==================== END GROCERY LIST ====================

  // SECURITY: OpenAI key should be fetched from Firebase Remote Config
  // DO NOT hardcode API keys in production!
  String _openAiKey = '';
  String get openAiKey => _openAiKey;
  set openAiKey(String value) {
    _openAiKey = value;
  }

  /// Initialize OpenAI key from Firebase Remote Config
  /// Call this in main.dart after Firebase.initializeApp()
  Future<void> initializeOpenAiKey() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero, // Always fetch fresh for development
      ));
      final activated = await remoteConfig.fetchAndActivate();
      print('Remote Config fetch activated: $activated');
      _openAiKey = remoteConfig.getString('openai_api_key');
      if (_openAiKey.isEmpty) {
        print('WARNING: OpenAI API key not configured in Remote Config');
      } else {
        print('OpenAI key loaded successfully, length: ${_openAiKey.length}');
      }
    } catch (e) {
      print('Error fetching OpenAI key from Remote Config: $e');
    }
  }

  double _progress = 0.0;
  double get progress => _progress;
  set progress(double value) {
    _progress = value;
  }

  // Meal cache buster - setting to true triggers refresh via notifyListeners
  // The _mealCashVersion increments for unique ValueKeys
  bool _MealCashtearm = false;
  int _mealCashVersion = 0;
  bool get MealCashtearm => _MealCashtearm;
  int get mealCashVersion => _mealCashVersion;
  set MealCashtearm(bool value) {
    _MealCashtearm = value;
    if (value) {
      _mealCashVersion++;
      notifyListeners();
    }
  }

  bool _favMealCash = false;
  bool get favMealCash => _favMealCash;
  set favMealCash(bool value) {
    _favMealCash = value;
  }

  bool _leariningpathchashBool = false;
  bool get leariningpathchashBool => _leariningpathchashBool;
  set leariningpathchashBool(bool value) {
    _leariningpathchashBool = value;
  }

  bool _activityCash = false;
  bool get activityCash => _activityCash;
  set activityCash(bool value) {
    _activityCash = value;
  }

  bool _todocash = false;
  bool get todocash => _todocash;
  set todocash(bool value) {
    _todocash = value;
  }

  // Shared recipe URL from external apps (Pinterest, browser, etc.)
  String? _sharedRecipeUrl;
  String? get sharedRecipeUrl => _sharedRecipeUrl;
  set sharedRecipeUrl(String? value) {
    _sharedRecipeUrl = value;
  }

  /// Consume the shared URL (get and clear)
  String? consumeSharedRecipeUrl() {
    final url = _sharedRecipeUrl;
    _sharedRecipeUrl = null;
    return url;
  }

  final _childrenManager = StreamRequestManager<List<ChildernRecord>>();
  Stream<List<ChildernRecord>> children({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<ChildernRecord>> Function() requestFn,
  }) =>
      _childrenManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearChildrenCache() => _childrenManager.clear();
  void clearChildrenCacheKey(String? uniqueKey) =>
      _childrenManager.clearRequest(uniqueKey);

  final _mealCashManager = StreamRequestManager<List<MealRecord>>();
  Stream<List<MealRecord>> mealCash({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<MealRecord>> Function() requestFn,
  }) =>
      _mealCashManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearMealCashCache() => _mealCashManager.clear();
  void clearMealCashCacheKey(String? uniqueKey) =>
      _mealCashManager.clearRequest(uniqueKey);

  final _toListManager = StreamRequestManager<List<EventAndTaskRecord>>();
  Stream<List<EventAndTaskRecord>> toList({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<EventAndTaskRecord>> Function() requestFn,
  }) =>
      _toListManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearToListCache() => _toListManager.clear();
  void clearToListCacheKey(String? uniqueKey) =>
      _toListManager.clearRequest(uniqueKey);

  final _axtivitypathManager = StreamRequestManager<List<ActivityRecord>>();
  Stream<List<ActivityRecord>> axtivitypath({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<ActivityRecord>> Function() requestFn,
  }) =>
      _axtivitypathManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearAxtivitypathCache() => _axtivitypathManager.clear();
  void clearAxtivitypathCacheKey(String? uniqueKey) =>
      _axtivitypathManager.clearRequest(uniqueKey);

  final _todaylearningpathManager =
      StreamRequestManager<List<LearningPathTasksRecord>>();
  Stream<List<LearningPathTasksRecord>> todaylearningpath({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<LearningPathTasksRecord>> Function() requestFn,
  }) =>
      _todaylearningpathManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearTodaylearningpathCache() => _todaylearningpathManager.clear();
  void clearTodaylearningpathCacheKey(String? uniqueKey) =>
      _todaylearningpathManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
