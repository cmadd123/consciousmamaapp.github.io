import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/custom_code/actions/index.dart' as actions;
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/share_content_bottom_sheet.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'fav_meal_page_model.dart';
export 'fav_meal_page_model.dart';

class FavMealPageWidget extends StatefulWidget {
  const FavMealPageWidget({
    super.key,
    this.mealTyp,
    this.date,
    this.mealPlan,
    bool? isFromGenrate,
    required this.mealRef,
  }) : isFromGenrate = isFromGenrate ?? false;

  final MealTyp? mealTyp;
  final DateTime? date;
  final DocumentReference? mealPlan;
  final bool isFromGenrate;
  final DocumentReference? mealRef;

  static String routeName = 'FavMealPage';
  static String routePath = '/favMealPage';

  @override
  State<FavMealPageWidget> createState() => _FavMealPageWidgetState();
}

class _FavMealPageWidgetState extends State<FavMealPageWidget> {
  late FavMealPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Recipe Shared Library (ported from phase2): the current user's creator
  // profile, if any. Non-null => show the per-recipe "share" toggles.
  CreatorsRecord? _creatorProfile;

  // Recipe Collections: the follower's active creator (for browsing that
  // creator's published collections). Null when the user has no active code.
  CreatorsRecord? _activeCreator;

  /// Upgrade Pinterest image URL to higher resolution
  /// Pinterest URLs follow pattern: i.pinimg.com/{size}/...
  /// Sizes: 236x (thumbnail), 474x (medium), 564x (large), originals (full)
  String _upgradePinterestImageUrl(String url) {
    if (url.contains('i.pinimg.com')) {
      // Upgrade to originals (full resolution) for best image quality
      return url
          .replaceFirst('/236x/', '/originals/')
          .replaceFirst('/474x/', '/originals/')
          .replaceFirst('/564x/', '/originals/');
    }
    return url;
  }

  // Palette colors for placeholder backgrounds (avoiding primary teal to not match heart)
  static const List<Color> _placeholderColors = [
    Color(0xFFEE8B60), // tertiary coral
    Color(0xFFE8A87C), // soft peach
    Color(0xFF9B8AA0), // lavender purple
    Color(0xFFFF9800), // orange
    Color(0xFF2196F3), // blue
    Color(0xFF4CAF50), // green
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

  // Build colored placeholder with icon
  Widget _buildRecipeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FFAppState().currentFontFamily,
          fontSize: 8.0,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.0,
        ),
      ),
    );
  }

  Widget _buildColoredPlaceholder(String? mealName) {
    return Container(
      color: _getPlaceholderColor(mealName),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 40.0,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavMealPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Check if we're in selection mode (coming from meal planner)
      debugPrint('FavMealPage: widget.date=${widget.date}, widget.mealTyp=${widget.mealTyp}, widget.mealPlan=${widget.mealPlan}');
      _model.isSelectionMode = widget.date != null || widget.mealTyp != null;
      debugPrint('FavMealPage: isSelectionMode=${_model.isSelectionMode}');

      // Load user recipes only
      debugPrint('FavMealPage: Starting query...');
      final allUserRecipes = await queryMealRecordOnce(
        queryBuilder: (mealRecord) => mealRecord.where(
          'user_ref',
          isEqualTo: currentUserReference,
        ),
      );
      debugPrint('FavMealPage: Loaded ${allUserRecipes.length} user recipes');
      _model.userMeal = allUserRecipes;
      _model.loadedAllRecipes = true;
      debugPrint('FavMealPage: Model updated, calling safeSetState');

      debugPrint('FavMealPage: Calling safeSetState - userMeal=${_model.userMeal.length}');
      safeSetState(() {});
      debugPrint('FavMealPage: safeSetState completed');

      // Shared Library: load creator profile (for the share toggles) and,
      // for followers, the active creator's shared recipes/templates.
      await _loadCreatorProfile();
      await _loadCreatorSharedRecipes();
    });
  }


  /// Re-fetch user recipes from Firestore so the cookbook reflects any edits.
  Future<void> _reloadUserRecipes() async {
    try {
      final freshRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );
      _model.userMeal = freshRecipes;
      if (mounted) safeSetState(() {});
    } catch (e) {
      debugPrint('Error reloading recipes: $e');
    }
  }

  /// Load the current user's creator profile (null if they aren't a creator).
  /// Creators get the per-recipe/template "share with followers" toggle.
  Future<void> _loadCreatorProfile() async {
    try {
      final profile = await actions.getCurrentUserCreatorProfile();
      if (mounted && profile != null) {
        safeSetState(() => _creatorProfile = profile);
      }
    } catch (e) {
      debugPrint('Error loading creator profile: $e');
    }
  }

  /// For followers: load the active creator's shared recipes/templates so the
  /// "Shared" cookbook mode can browse them. Matches on the creator's userRef.
  Future<void> _loadCreatorSharedRecipes() async {
    try {
      final creator = await actions.getActiveCreator();
      if (creator == null || !creator.hasUserRef()) {
        // No active creator (never set, or the code was removed) — clear any
        // previously-loaded creator content so it doesn't linger, and drop
        // back to the personal cookbook for non-creators.
        if (mounted) {
          setState(() {
            _activeCreator = null;
            _model.creatorSharedRecipes = [];
            _model.creatorSharedTemplates = [];
            _model.activeCreatorName = null;
            if (_creatorProfile == null) _model.cookbookMode = 'personal';
          });
        }
        return;
      }
      if (mounted) _activeCreator = creator;
      // If this user IS the creator, they browse their own shared items via
      // the in-memory filter on userMeal — no separate load needed.
      if (creator.userRef == currentUserReference) return;

      final sharedRecipes = await queryMealRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: creator.userRef)
            .where('shared_with_followers', isEqualTo: true),
      );
      final sharedTemplates = await queryMealComboRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: creator.userRef)
            .where('shared_with_followers', isEqualTo: true),
      );
      if (mounted) {
        _model.creatorSharedRecipes = sharedRecipes;
        _model.creatorSharedTemplates = sharedTemplates;
        _model.activeCreatorName = creator.name;
        safeSetState(() {});
      }
    } catch (e) {
      debugPrint('Error loading creator shared recipes: $e');
    }
  }

  // ── Recipe Collections ──────────────────────────────────────────────
  // Creators bundle recipes into a named group; followers add the whole set
  // to their cookbook in one tap. Shares the recipe_collections collection
  // with the web dashboard.

  void _openCollectionsSheet() {
    if (_creatorProfile != null) {
      _openCreatorCollectionsSheet();
    } else if (_activeCreator != null) {
      _openFollowerCollectionsSheet();
    }
  }

  /// Follower view: browse the active creator's published collections and add
  /// a whole collection to the personal cookbook.
  void _openFollowerCollectionsSheet() {
    final code = _activeCreator?.code ?? '';
    final creatorName = _activeCreator?.name ?? 'your creator';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            return FutureBuilder<List<RecipeCollectionRecord>>(
              future: actions.getCreatorRecipeCollections(code),
              builder: (ctx, snap) {
                final loading =
                    snap.connectionState == ConnectionState.waiting;
                final collections = snap.data ?? [];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📚 Collections from $creatorName',
                        style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: FlutterFlowTheme.of(ctx).primaryText,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Add a whole set to your cookbook — each recipe becomes a regular recipe you can plan any day.',
                        style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 13.0,
                          color: FlutterFlowTheme.of(ctx).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (collections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            '$creatorName hasn\'t shared any collections yet.',
                            style: TextStyle(
                              fontFamily: FFAppState().currentFontFamily,
                              color: FlutterFlowTheme.of(ctx).secondaryText,
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: collections.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10.0),
                            itemBuilder: (_, i) {
                              final c = collections[i];
                              return _collectionTile(
                                ctx: ctx,
                                title: c.name,
                                subtitle: c.description.isNotEmpty
                                    ? c.description
                                    : '${c.recipes.length} recipe${c.recipes.length == 1 ? '' : 's'}',
                                trailingLabel: 'Add',
                                onTrailing: () => _openCollectionActions(c),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Two ways to ingest a collection: save the recipes to the cookbook, or
  /// schedule them onto the calendar (which also saves them).
  void _openCollectionActions(RecipeCollectionRecord c) {
    final count = c.recipes.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        final theme = FlutterFlowTheme.of(sheetCtx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count recipe${count == 1 ? '' : 's'}',
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  color: theme.secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _actionButton(
                sheetCtx,
                icon: Icons.event_available,
                label: 'Add to meal plan',
                sub: 'Schedule them on consecutive days from a date you pick',
                filled: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _addCollectionToMealPlan(c);
                },
              ),
              const SizedBox(height: 10),
              _actionButton(
                sheetCtx,
                icon: Icons.bookmark_add_outlined,
                label: 'Add to my cookbook',
                sub: 'Save the recipes to use whenever you like',
                filled: false,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _addCollectionToLibrary(c);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String sub,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final theme = FlutterFlowTheme.of(ctx);
    final primary = theme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? primary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: filled ? Colors.white : primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: filled ? Colors.white : theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 12,
                      color: filled
                          ? Colors.white.withOpacity(0.85)
                          : theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCollectionToLibrary(RecipeCollectionRecord c) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Adding recipes…')));
    final count = await actions.importRecipeCollection(
      collection: c,
      creatorName: _activeCreator?.name,
    );
    if (!mounted) return;
    Navigator.of(context).maybePop(); // close the collections sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(count > 0
              ? 'Added $count recipe${count == 1 ? '' : 's'} to your cookbook!'
              : 'Nothing to add from this collection.')),
    );
    await _reloadUserRecipes();
  }

  Future<void> _addCollectionToMealPlan(RecipeCollectionRecord c) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Start this collection on…',
    );
    if (picked == null || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Scheduling recipes…')));
    final count = await actions.scheduleRecipeCollection(
      collection: c,
      startDate: picked,
      creatorName: _activeCreator?.name,
    );
    if (!mounted) return;
    Navigator.of(context).maybePop(); // close the collections sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(count > 0
              ? 'Scheduled $count recipe${count == 1 ? '' : 's'} starting ${_shortDate(picked)}!'
              : 'Nothing to schedule from this collection.')),
    );
    await _reloadUserRecipes();
  }

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  /// Single shared recipe (Creator Cookbook): save it or schedule it.
  void _openRecipeActions(MealRecord m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        final theme = FlutterFlowTheme.of(sheetCtx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.recipeName,
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 18),
              _actionButton(
                sheetCtx,
                icon: Icons.event_available,
                label: 'Add to meal plan',
                sub: 'Pick a date and meal slot',
                filled: true,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _scheduleSharedRecipe(m);
                },
              ),
              const SizedBox(height: 10),
              _actionButton(
                sheetCtx,
                icon: Icons.bookmark_add_outlined,
                label: 'Add to my cookbook',
                sub: 'Save it to use whenever you like',
                filled: false,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _addSharedRecipeToLibrary(m);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addSharedRecipeToLibrary(MealRecord m) async {
    final ref = await actions.copySharedRecipeToLibrary(
      m,
      creatorName: _activeCreator?.name,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ref != null
              ? 'Added “${m.recipeName}” to your cookbook!'
              : 'Couldn\'t add that recipe.')),
    );
    await _reloadUserRecipes();
  }

  Future<void> _scheduleSharedRecipe(MealRecord m) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Schedule this recipe on…',
    );
    if (picked == null || !mounted) return;
    final mealTyp = await _pickMealType();
    if (mealTyp == null || !mounted) return;
    final ok = await actions.scheduleSharedRecipe(
      m,
      date: picked,
      mealTyp: mealTyp,
      creatorName: _activeCreator?.name,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ok
              ? 'Scheduled “${m.recipeName}” for ${_shortDate(picked)}!'
              : 'Couldn\'t schedule that recipe.')),
    );
    await _reloadUserRecipes();
  }

  Future<MealTyp?> _pickMealType() {
    return showModalBottomSheet<MealTyp>(
      context: context,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        final theme = FlutterFlowTheme.of(ctx);
        const options = <MapEntry<String, MealTyp>>[
          MapEntry('Breakfast', MealTyp.Breakfast),
          MapEntry('Lunch', MealTyp.Lunch),
          MapEntry('Dinner', MealTyp.Dinner),
          MapEntry('Snack', MealTyp.Snacks),
        ];
        return Padding(
          padding: EdgeInsets.only(
            top: 12, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Which meal?',
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.primaryText,
                  ),
                ),
              ),
              for (final o in options)
                ListTile(
                  title: Text(
                    o.key,
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      color: theme.primaryText,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, o.value),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Creator view: list their collections and create new ones from their
  /// shared recipes.
  void _openCreatorCollectionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            Future<List<RecipeCollectionRecord>> future =
                actions.getMyRecipeCollections();
            return FutureBuilder<List<RecipeCollectionRecord>>(
              future: future,
              builder: (ctx, snap) {
                final loading =
                    snap.connectionState == ConnectionState.waiting;
                final collections = snap.data ?? [];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '📚 Your recipe collections',
                              style: TextStyle(
                                fontFamily: FFAppState().currentFontFamily,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: FlutterFlowTheme.of(ctx).primaryText,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final created =
                                  await _openCreateCollectionSheet();
                              if (created == true) setSheet(() {});
                            },
                            icon: const Icon(Icons.add, size: 18.0),
                            label: const Text('New'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Bundle recipes into a named group like “5 Crockpot Dinners.” Followers add the whole set in one tap.',
                        style: TextStyle(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 13.0,
                          color: FlutterFlowTheme.of(ctx).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      if (loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (collections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            'No collections yet. Tap “New” to bundle some of your shared recipes.',
                            style: TextStyle(
                              fontFamily: FFAppState().currentFontFamily,
                              color: FlutterFlowTheme.of(ctx).secondaryText,
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: collections.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10.0),
                            itemBuilder: (_, i) {
                              final c = collections[i];
                              return _collectionTile(
                                ctx: ctx,
                                title: c.name +
                                    (c.isActive ? '' : ' (hidden)'),
                                subtitle:
                                    '${c.recipes.length} recipe${c.recipes.length == 1 ? '' : 's'}',
                                trailingLabel: 'Delete',
                                trailingColor: FlutterFlowTheme.of(ctx).error,
                                onTrailing: () async {
                                  final ok = await showDialog<bool>(
                                    context: ctx,
                                    builder: (dCtx) => AlertDialog(
                                      title: Text('Delete “${c.name}”?'),
                                      content: const Text(
                                          'Followers will no longer see it. Recipes they already added stay in their cookbook.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dCtx, false),
                                            child: const Text('Cancel')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dCtx, true),
                                            child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await actions.deleteRecipeCollection(c);
                                    setSheet(() {});
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Creator flow to name a collection and pick from their shared recipes.
  /// Returns true if a collection was created.
  Future<bool?> _openCreateCollectionSheet() async {
    // Load the creator's own shared recipes to choose from.
    List<MealRecord> shared = [];
    try {
      shared = await queryMealRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('shared_with_followers', isEqualTo: true),
      );
    } catch (_) {}

    if (!mounted) return false;
    if (shared.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Share a few recipes with followers first, then bundle them into a collection.')),
      );
      return false;
    }

    final nameCtrl = TextEditingController();
    final selected = <String>{};

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New collection',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: FlutterFlowTheme.of(sheetCtx).primaryText,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. 5 Crockpot Dinners',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Pick recipes (${selected.length} selected)',
                    style: TextStyle(
                      fontFamily: FFAppState().currentFontFamily,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(sheetCtx).primaryText,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: shared.length,
                      itemBuilder: (_, i) {
                        final m = shared[i];
                        final id = m.reference.id;
                        final on = selected.contains(id);
                        return CheckboxListTile(
                          value: on,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            m.recipeName,
                            style: TextStyle(
                              fontFamily: FFAppState().currentFontFamily,
                              color:
                                  FlutterFlowTheme.of(sheetCtx).primaryText,
                            ),
                          ),
                          onChanged: (v) {
                            setSheet(() {
                              if (v == true) {
                                selected.add(id);
                              } else {
                                selected.remove(id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            const SnackBar(
                                content: Text('Give the collection a name')),
                          );
                          return;
                        }
                        if (selected.isEmpty) {
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            const SnackBar(
                                content: Text('Pick at least one recipe')),
                          );
                          return;
                        }
                        final recipes = shared
                            .where((m) => selected.contains(m.reference.id))
                            .map((m) => actions.recipeSnapshotFromMeal(m))
                            .toList();
                        await actions.saveRecipeCollection(
                          name: name,
                          recipes: recipes,
                        );
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx, true);
                      },
                      child: const Text('Publish collection'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _collectionTile({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required String trailingLabel,
    required VoidCallback onTrailing,
    Color? trailingColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(ctx).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(ctx).alternate),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                    color: FlutterFlowTheme.of(ctx).primaryText,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 12.0,
                    color: FlutterFlowTheme.of(ctx).secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          TextButton(
            onPressed: onTrailing,
            child: Text(
              trailingLabel,
              style: TextStyle(
                fontFamily: FFAppState().currentFontFamily,
                fontWeight: FontWeight.w600,
                color: trailingColor ?? FlutterFlowTheme.of(ctx).primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Load meal templates (user-created combos)
  Future<void> _loadMealTemplates() async {
    if (_model.loadedMealTemplates) return;

    try {
      final templates = await queryMealComboRecordOnce(
        queryBuilder: (comboRecord) => comboRecord.where(
          'user_ref',
          isEqualTo: currentUserReference,
        ),
      );
      debugPrint('Loaded ${templates.length} meal templates');
      _model.mealTemplates = templates;
      _model.loadedMealTemplates = true;
      safeSetState(() {});
    } catch (e) {
      debugPrint('Error loading meal templates: $e');
    }
  }

  /// Add meal template to meal plan
  Future<void> _addTemplateToMealPlan(MealComboRecord template) async {
    try {
      // If there's an existing meal plan, delete it first
      if (widget.mealPlan != null) {
        await widget.mealPlan!.delete();
      }

      // Create new meal plan with the template combo reference
      await MealPlanRecord.collection.add({
        'user_ref': currentUserReference,
        'date': widget.date,
        'typ': widget.mealTyp!.name,
        'meal_combo_ref': template.reference,
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} added to your meal plan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error adding template to meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding meal template: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show template details with "Add to Meal Plan" and edit options
  void _showTemplateDetails(MealComboRecord template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _TemplateDetailsSheet(
        template: template,
        onAddToMealPlan: () {
          Navigator.pop(context);
          _showAddTemplateToMealPlanSheet(template);
        },
        onEdit: () {
          Navigator.pop(context);
          _editTemplateFullly(template);
        },
        onRename: () {
          Navigator.pop(context);
          _renameTemplate(template);
        },
        onShare: () {
          Navigator.pop(context);
          _shareTemplate(template);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTemplate(template);
        },
      ),
    );
  }

  /// Show sheet to select date and meal type for adding template
  void _showAddTemplateToMealPlanSheet(MealComboRecord template) {
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    DateTime selectedDate = todayNormalized;
    MealTyp selectedMealType = template.mealTyp ?? MealTyp.Dinner;

    // Use custom selected dates if user has picked them, otherwise default 7 days
    final customDates = FFAppState().mealPlanSelectedDates;
    final days = (customDates != null && customDates.isNotEmpty)
        ? customDates
        : List.generate(7, (i) => now.add(Duration(days: i)));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title and template name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add to Meal Plan',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Template name as subtitle
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary, size: 16.0),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Text(
                          template.name,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Date picker
                  Text(
                    'Select Day',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  // Mini calendar matching the fill meal plan style — wraps when >7 days
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: List.generate(days.length, (i) {
                      final date = days[i];
                      final normalizedDate = DateTime(date.year, date.month, date.day);
                      final dayName = dateTimeFormat('E', date, locale: 'en').substring(0, 3);
                      final dayNum = date.day.toString();
                      final isToday = normalizedDate.isAtSameMomentAs(todayNormalized);
                      final isSelected = normalizedDate.isAtSameMomentAs(selectedDate);
                      final itemWidth = (MediaQuery.of(context).size.width - 40.0 - 36.0) / 7;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedDate = normalizedDate);
                        },
                        child: Container(
                          width: itemWidth,
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary
                                  : const Color(0xFFE0E0E0),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 10.0,
                                  color: isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : const Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday && isSelected
                                      ? FlutterFlowTheme.of(context).primary
                                      : isToday
                                          ? const Color(0xFFE0E0E0)
                                          : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  dayNum,
                                  style: TextStyle(
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontSize: 13.0,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isToday && isSelected
                                        ? Colors.white
                                        : isSelected
                                            ? FlutterFlowTheme.of(context).primary
                                            : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20.0),
                  // Meal type selector
                  Text(
                    'Select Meal Type',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      for (final mealType in [MealTyp.Breakfast, MealTyp.Lunch, MealTyp.Dinner, MealTyp.Snacks])
                        ChoiceChip(
                          label: Text(mealType.name),
                          selected: selectedMealType == mealType,
                          onSelected: (selected) {
                            if (selected) setState(() => selectedMealType = mealType);
                          },
                          selectedColor: FlutterFlowTheme.of(context).primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selectedMealType == mealType ? Colors.white : Colors.black87,
                            fontFamily: FFAppState().currentFontFamily,
                          ),
                          side: BorderSide(
                            color: selectedMealType == mealType ? FlutterFlowTheme.of(context).primary : const Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _addTemplateToMealPlanWithParams(template, selectedDate, selectedMealType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      child: const Text('Add to Meal Plan', style: TextStyle(fontSize: 16.0)),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Add template to meal plan with custom date and meal type
  Future<void> _addTemplateToMealPlanWithParams(MealComboRecord template, DateTime date, MealTyp mealType) async {
    try {
      // Check if there's already a meal plan for this date/type
      final existing = await queryMealPlanRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('date', isEqualTo: date)
            .where('typ', isEqualTo: mealType.name),
      );

      // Delete existing if present
      if (existing.isNotEmpty) {
        await existing.first.reference.delete();
      }

      // Create new meal plan with the template combo reference
      await MealPlanRecord.collection.add({
        'user_ref': currentUserReference,
        'date': date,
        'typ': mealType.name,
        'meal_combo_ref': template.reference,
      });

      // Signal meal planner to refresh
      FFAppState().MealCashtearm = true;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} added to ${mealType.name} on ${dateTimeFormat("MMM d", date, locale: 'en')}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding template to meal plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error adding meal template'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show template actions (edit/delete)
  void _showTemplateActions(MealComboRecord template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              // Header — clean style matching "Add to Meal Plan"
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Template',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu, color: FlutterFlowTheme.of(context).primary, size: 16.0),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            template.name,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              // Action buttons
              ListTile(
                leading: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary),
                title: const Text('Edit Meal Template'),
                subtitle: const Text('Change entrée, sides, and drink', style: TextStyle(fontSize: 12.0)),
                onTap: () {
                  Navigator.pop(context);
                  _editTemplateFullly(template);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_note, color: FlutterFlowTheme.of(context).primary),
                title: const Text('Rename Meal Template'),
                onTap: () {
                  Navigator.pop(context);
                  _renameTemplate(template);
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: FlutterFlowTheme.of(context).primary),
                title: const Text('Share Meal Template'),
                onTap: () {
                  Navigator.pop(context);
                  _shareTemplate(template);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Meal Template', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTemplate(template);
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Edit template fully (navigate to meal composer with existing data)
  void _editTemplateFullly(MealComboRecord template) async {
    // Navigate to meal composer with template ID so it can load and edit the combo
    await context.pushNamed(
      'MealComposer',
      queryParameters: {
        'editTemplateId': template.reference.id,
      }.withoutNulls,
      extra: <String, dynamic>{
        'date': DateTime.now(),
        'mealType': template.mealTyp ?? MealTyp.Dinner,
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
        ),
      },
    );

    // Reload templates after returning from composer
    _model.loadedMealTemplates = false;
    await _loadMealTemplates();
    safeSetState(() {});
  }

  /// Smart label for a set of ISO weekdays (1=Mon..7=Sun). Picks a
  /// concise phrase when the selection matches a common pattern,
  /// otherwise joins short day names.
  String? _weekdaysLabel(List<int> weekdays) {
    if (weekdays.isEmpty) return null;
    final sorted = (weekdays.toList()..sort());
    if (sorted.length == 7) return 'Every day';
    if (sorted.length == 5 && sorted.every((w) => w >= 1 && w <= 5)) return 'Weekdays';
    if (sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7) return 'Weekends';
    if (sorted.length == 1) {
      const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return names[sorted.first - 1];
    }
    const shortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return sorted.map((w) => shortNames[w - 1]).join(', ');
  }

  /// Edit a saved day group: rename all templates in the group + set the
  /// preferred weekdays. Updates every template sharing the day_template_group.
  Future<void> _editSavedDayGroup(List<MealComboRecord> templates) async {
    if (templates.isEmpty) return;

    final nameController = TextEditingController(text: templates.first.dayTemplateName);
    final Set<int> selectedWeekdays =
        templates.first.preferredWeekdays.toSet();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = FlutterFlowTheme.of(dialogContext);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: const Text('Edit Saved Day'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g., Taco Tuesday',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Preferred days (optional, tap any)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Autofill lands this Saved Day on any day you pick below '
                    '(regardless of name).',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _editWeekdayChip(theme, 'None',
                          selected: selectedWeekdays.isEmpty,
                          onTap: () => setDialogState(() => selectedWeekdays.clear())),
                      ...List.generate(7, (i) {
                        final weekday = i + 1;
                        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return _editWeekdayChip(theme, labels[i],
                            selected: selectedWeekdays.contains(weekday),
                            onTap: () => setDialogState(() {
                                  if (!selectedWeekdays.remove(weekday)) {
                                    selectedWeekdays.add(weekday);
                                  }
                                }));
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    final sortedWeekdays = selectedWeekdays.toList()..sort();

    try {
      // Update every template in the group. Preferred weekdays are group-
      // level, not per-meal — applied uniformly across all meals.
      for (final t in templates) {
        final updates = <String, dynamic>{'day_template_name': newName};
        if (sortedWeekdays.isEmpty) {
          updates['preferred_weekdays'] = FieldValue.delete();
          // Also scrub the legacy single-int field if present on old docs.
          updates['preferred_weekday'] = FieldValue.delete();
        } else {
          updates['preferred_weekdays'] = sortedWeekdays;
          updates['preferred_weekday'] = FieldValue.delete();
        }
        await t.reference.update(updates);
      }

      _model.loadedMealTemplates = false;
      await _loadMealTemplates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved Day updated!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error editing saved day: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating saved day'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _editWeekdayChip(
    FlutterFlowTheme theme,
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = theme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected ? primary : primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: selected ? primary : primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: FFAppState().currentFontFamily,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  /// Rename template
  void _renameTemplate(MealComboRecord template) {
    final nameController = TextEditingController(text: template.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: const Text('Rename Meal Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a new name:', style: FlutterFlowTheme.of(context).bodyMedium),
            const SizedBox(height: 8.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Taco Tuesday',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              Navigator.pop(dialogContext);

              try {
                await template.reference.update({'name': newName});

                // Reload templates
                _model.loadedMealTemplates = false;
                await _loadMealTemplates();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal Template renamed!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error renaming template: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error renaming meal template'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: FlutterFlowTheme.of(context).primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Delete template
  void _deleteTemplate(MealComboRecord template) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12.0),
            Text('Delete Template?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This cannot be undone.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await template.reference.delete();

                // Remove from local list
                _model.mealTemplates.removeWhere((t) => t.reference.path == template.reference.path);
                safeSetState(() {});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal Template deleted'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error deleting template: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting meal template'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Share template using existing combo sharing infrastructure
  void _shareTemplate(MealComboRecord template) async {
    try {
      // Load all meals: entree + sides + desserts + snacks
      List<MealRecord> comboMeals = [];

      // Load entree
      if (template.entreeRef != null) {
        try {
          final entree = await MealRecord.getDocumentOnce(template.entreeRef!);
          comboMeals.add(entree);
        } catch (e) {
          debugPrint('_shareTemplate: Could not load entree: $e');
        }
      }

      // Load sides
      for (final sideRef in template.sideRefs) {
        try {
          final side = await MealRecord.getDocumentOnce(sideRef);
          comboMeals.add(side);
        } catch (e) {
          debugPrint('_shareTemplate: Could not load side: $e');
        }
      }

      // Load desserts
      for (final dessertRef in template.dessertRefs) {
        try {
          final dessert = await MealRecord.getDocumentOnce(dessertRef);
          comboMeals.add(dessert);
        } catch (e) {
          debugPrint('_shareTemplate: Could not load dessert: $e');
        }
      }

      // Load snacks from snapshot data
      final snackRefs = template.snapshotData['snack_refs'] as List<dynamic>?;
      if (snackRefs != null) {
        for (final ref in snackRefs) {
          if (ref is DocumentReference) {
            try {
              final snack = await MealRecord.getDocumentOnce(ref);
              comboMeals.add(snack);
            } catch (e) {
              debugPrint('_shareTemplate: Could not load snack: $e');
            }
          }
        }
      }

      if (comboMeals.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No meals found in "${template.name}"'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // Use existing combo sharing functionality
      showShareComboBottomSheet(
        context: context,
        combo: template,
        comboMeals: comboMeals,
      );
    } catch (e) {
      debugPrint('Error sharing template: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sharing meal template'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Get contextual title for selection mode
  String _getSelectionTitle() {
    if (widget.mealPlan != null) {
      return 'Replace';
    }
    return 'Select';
  }

  /// Get subtitle showing what meal slot
  String _getSelectionSubtitle() {
    if (widget.date == null || widget.mealTyp == null) return '';
    final dayName = _getDayName(widget.date!);
    final mealType = widget.mealTyp!.name;
    final action = widget.mealPlan != null ? 'Replacing' : 'Adding';
    return '$action $dayName\'s $mealType';
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

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Auto-tag a recipe based on its name
  /// Returns (mealTyp, recipeType) tuple
  (String?, RecipeType?) _guessTagsFromName(String? name) {
    if (name == null || name.isEmpty) return (null, null);

    final lower = name.toLowerCase();

    // Guess meal type
    String? mealTyp;
    if (lower.contains('breakfast') || lower.contains('pancake') ||
        lower.contains('waffle') || lower.contains('oatmeal') ||
        lower.contains('egg') || lower.contains('toast') ||
        lower.contains('muffin') || lower.contains('smoothie bowl') ||
        lower.contains('french toast') || lower.contains('cereal')) {
      mealTyp = 'Breakfast';
    } else if (lower.contains('lunch') || lower.contains('sandwich') ||
        lower.contains('wrap') || lower.contains('salad') && !lower.contains('dinner')) {
      mealTyp = 'Lunch';
    } else if (lower.contains('dinner') || lower.contains('roast') ||
        lower.contains('steak') || lower.contains('pasta') ||
        lower.contains('casserole') || lower.contains('stir fry') ||
        lower.contains('chicken') || lower.contains('beef') ||
        lower.contains('pork') || lower.contains('fish') ||
        lower.contains('salmon') || lower.contains('shrimp')) {
      mealTyp = 'Dinner';
    } else if (lower.contains('snack') || lower.contains('cookie') ||
        lower.contains('brownie') || lower.contains('bar') ||
        lower.contains('bite') || lower.contains('ball') ||
        lower.contains('dip') || lower.contains('chips')) {
      mealTyp = 'Snacks';
    }

    // Guess recipe type
    RecipeType? recipeType;
    if (lower.contains('side') || lower.contains('fries') ||
        lower.contains('rice') || lower.contains('vegetable') ||
        lower.contains('salad') || lower.contains('coleslaw') ||
        lower.contains('bread') || lower.contains('roll') ||
        lower.contains('mashed') || lower.contains('roasted')) {
      recipeType = RecipeType.Side;
    } else if (lower.contains('dessert') || lower.contains('cake') ||
        lower.contains('cookie') || lower.contains('pie') ||
        lower.contains('brownie') || lower.contains('pudding') ||
        lower.contains('ice cream') || lower.contains('fruit')) {
      recipeType = RecipeType.Dessert;
    } else {
      // Default to Entree for main dishes
      recipeType = RecipeType.Entree;
    }

    return (mealTyp, recipeType);
  }

  /// Show bulk delete dialog with options
  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bulk Delete (Temporary)', style: TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Choose what to delete:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAllMealTemplates();
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Delete ALL Saved Days'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAllMyRecipes();
                },
                icon: const Icon(Icons.book),
                label: const Text('Delete ALL My Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Delete all meal templates
  Future<void> _deleteAllMealTemplates() async {
    try {
      final templates = await queryMealComboRecordOnce(
        queryBuilder: (q) => q.where('user_ref', isEqualTo: currentUserReference),
      );

      for (final template in templates) {
        await template.reference.delete();
      }

      _model.mealTemplates = [];
      _model.loadedMealTemplates = false;
      safeSetState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${templates.length} meal templates'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting templates: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete all user recipes
  Future<void> _deleteAllMyRecipes() async {
    try {
      final recipes = await queryMealRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference),
      );

      for (final recipe in recipes) {
        await recipe.reference.delete();
      }

      _model.userMeal = [];
      _model.loadedAllRecipes = false;
      safeSetState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${recipes.length} my recipes'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting my recipes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFE8F5F3), // Light teal to match Cookbook button
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.meals),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.sizeOf(context).height * 0.9,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x33000000),
                                offset: Offset(
                                  0.0,
                                  4.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFF999999),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 0.0, 0.0, 0.0),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              // safePop() falls back to go('/') which is the
                                              // unauthenticated WelcomeEnhanced page — sends an
                                              // authenticated user into the walkthrough and the
                                              // next-step arrow there logs them out. Route to
                                              // HomeHybrid instead when there's nothing to pop.
                                              if (context.canPop()) {
                                                context.pop();
                                              } else {
                                                context.goNamed(HomeHybridWidget.routeName);
                                              }
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 0.0,
                                        height: 0.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Shared Library: cookbook mode pill — only for
                                // creators, or followers with an active creator.
                                if (_creatorProfile != null ||
                                    _model.activeCreatorName != null)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 0.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              _model.cookbookMode = 'personal';
                                              _model.categoryFilter = 'All';
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: _model.cookbookMode ==
                                                        'personal'
                                                    ? FlutterFlowTheme.of(context)
                                                        .primary
                                                    : FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Text(
                                                'My Cookbook',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FFAppState()
                                                      .currentFontFamily,
                                                  color: _model.cookbookMode ==
                                                          'personal'
                                                      ? Colors.white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              _model.cookbookMode = 'creator';
                                              _model.categoryFilter = 'All';
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: _model.cookbookMode ==
                                                        'creator'
                                                    ? FlutterFlowTheme.of(context)
                                                        .primary
                                                    : FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Text(
                                                _creatorProfile != null
                                                    ? 'Creator Cookbook'
                                                    : (_model.activeCreatorName !=
                                                            null
                                                        ? '${_model.activeCreatorName}’s Cookbook'
                                                        : 'Creator Cookbook'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: FFAppState()
                                                      .currentFontFamily,
                                                  color: _model.cookbookMode ==
                                                          'creator'
                                                      ? Colors.white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Recipe Collections: entry point. Creators
                                // manage their own; followers browse the active
                                // creator's published collections.
                                if (_creatorProfile != null ||
                                    _activeCreator != null)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 0.0),
                                    child: GestureDetector(
                                      onTap: _openCollectionsSheet,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 10.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .primary
                                                .withOpacity(0.35),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Text('📚',
                                                style: TextStyle(fontSize: 18.0)),
                                            const SizedBox(width: 10.0),
                                            Expanded(
                                              child: Text(
                                                _creatorProfile != null
                                                    ? 'Recipe Collections — bundle & share'
                                                    : 'Recipe Collections from ${_activeCreator?.name ?? 'your creator'}',
                                                style: TextStyle(
                                                  fontFamily: FFAppState()
                                                      .currentFontFamily,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .primaryText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: FlutterFlowTheme.of(context)
                                                  .primary,
                                              size: 22.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                // Selection mode banner
                                if (_model.isSelectionMode)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: widget.mealPlan != null
                                          ? const Color(0xFFFF9800).withOpacity(0.15)
                                          : FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: widget.mealPlan != null
                                            ? const Color(0xFFFF9800)
                                            : FlutterFlowTheme.of(context).primary,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          widget.mealPlan != null ? Icons.swap_horiz : Icons.add_circle_outline,
                                          color: widget.mealPlan != null ? const Color(0xFFFF9800) : FlutterFlowTheme.of(context).primary,
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            _getSelectionSubtitle(),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color: widget.mealPlan != null ? const Color(0xFFE65100) : FlutterFlowTheme.of(context).primary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          'Select a recipe',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: const Color(0xFF666666),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // My Recipes / Templates / Saved Days tab toggle
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8.0, 12.0, 8.0, 12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _model.recipeSourceTab = 'my';
                                              _model.categoryFilter = 'All';
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'my'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Recipes',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: _model.recipeSourceTab == 'my'
                                                      ? Colors.white
                                                      : const Color(0xFF666666),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _model.recipeSourceTab = 'templates';
                                              _model.categoryFilter = 'All';
                                              // Always reload templates to pick up newly saved ones
                                              _model.loadedMealTemplates = false;
                                              _loadMealTemplates();
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'templates'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Templates',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: _model.recipeSourceTab == 'templates'
                                                      ? Colors.white
                                                      : const Color(0xFF666666),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              _model.recipeSourceTab = 'savedDays';
                                              _model.categoryFilter = 'All';
                                              _model.loadedMealTemplates = false;
                                              _loadMealTemplates();
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: _model.recipeSourceTab == 'savedDays'
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Text(
                                                'Saved Days',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  color: _model.recipeSourceTab == 'savedDays'
                                                      ? Colors.white
                                                      : const Color(0xFF666666),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Search bar
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: TextField(
                                      controller: _model.searchController,
                                      onChanged: (value) {
                                        _model.searchQuery = value;
                                        safeSetState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search recipes...',
                                        hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: const Color(0xFF999999),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Color(0xFF999999),
                                          size: 20.0,
                                        ),
                                        suffixIcon: _model.searchQuery.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  _model.searchController?.clear();
                                                  _model.searchQuery = '';
                                                  safeSetState(() {});
                                                },
                                                child: const Icon(
                                                  Icons.clear,
                                                  color: Color(0xFF999999),
                                                  size: 20.0,
                                                ),
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Filter chips - grouped by category (show for My Recipes and Templates, not Saved Days)
                                if (_model.recipeSourceTab != 'savedDays')
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 8.0, 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Section 1: Meal Types
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Meal Times',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: const Color(0xFF666666),
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('🍳 Filter recipes by when they are typically eaten'),
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                              child: const Icon(Icons.help_outline, size: 14.0, color: Color(0xFF999999)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'All', 'emoji': ''},
                                            {'label': 'Breakfast', 'emoji': '🌅'},
                                            {'label': 'Lunch', 'emoji': '🌞'},
                                            {'label': 'Dinner', 'emoji': '🌙'},
                                            {'label': 'Snacks', 'emoji': '🍪'},
                                          ].map((mealType) {
                                            final label = mealType['label']!;
                                            final emoji = mealType['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? FlutterFlowTheme.of(context).primary
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme.of(context).primary,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    emoji.isNotEmpty ? '$emoji $label' : label,
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : FlutterFlowTheme.of(context).primary,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      // Recipe Types (only for My Recipes tab)
                                      if (_model.recipeSourceTab == 'my') ...[
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 8.0),
                                        child: Text(
                                          'Recipe Types',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: FFAppState().currentFontFamily,
                                            color: const Color(0xFF666666),
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'Entree', 'emoji': '🍽️'},
                                            {'label': 'Side', 'emoji': '🥗'},
                                            {'label': 'Snack', 'emoji': '🍿'},
                                            {'label': 'Dessert', 'emoji': '🍰'},
                                          ].map((recipeType) {
                                            final label = recipeType['label']!;
                                            final emoji = recipeType['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(0xFF9B8AA0)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.0),
                                                    border: Border.all(
                                                      color: const Color(0xFF9B8AA0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$emoji $label',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(0xFF9B8AA0),
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      ],
                                      // Dietary & Allergen Info
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Dietary & Allergen Info',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                fontFamily: FFAppState().currentFontFamily,
                                                color: const Color(0xFF666666),
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            InkWell(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('🌾 Filter recipes by dietary restrictions or allergen information'),
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              },
                                              child: const Icon(Icons.help_outline, size: 14.0, color: Color(0xFF999999)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            {'label': 'Gluten-Free', 'emoji': '🌾'},
                                            {'label': 'Dairy-Free', 'emoji': '🥛'},
                                            {'label': 'Nut-Free', 'emoji': '🥜'},
                                            {'label': 'Vegetarian', 'emoji': '🥕'},
                                            {'label': 'Vegan', 'emoji': '🌱'},
                                          ].map((dietary) {
                                            final label = dietary['label']!;
                                            final emoji = dietary['emoji']!;
                                            final isSelected = _model.categoryFilter == label;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  _model.categoryFilter = label;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(0xFF52A097)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(16.0),
                                                    border: Border.all(
                                                      color: const Color(0xFF52A097),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$emoji $label',
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(0xFF52A097),
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  key: ValueKey('recipe_container_${_model.userMeal.length}_${_model.recipeSourceTab}'),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Builder(
                                  builder: (context) {
                                    // Handle templates tab separately
                                    if (_model.recipeSourceTab == 'templates') {
                                      return _buildTemplatesView(context);
                                    }

                                    // Handle meal templates tab
                                    if (_model.recipeSourceTab == 'savedDays') {
                                      return _buildSavedDaysView(context);
                                    }

                                    // Get the active recipe list based on selected tab
                                    // Get active recipes based on selected tab
                                    debugPrint('FavMealPage Builder: recipeSourceTab=${_model.recipeSourceTab}, userMeal=${_model.userMeal.length}');
                                    // Shared Library: in 'creator' mode, a
                                    // creator sees their own shared recipes;
                                    // a follower sees the active creator's.
                                    final activeRecipes = _model.cookbookMode ==
                                            'creator'
                                        ? (_creatorProfile != null
                                            ? _model.userMeal
                                                .where((r) =>
                                                    r.sharedWithFollowers)
                                                .toList()
                                            : _model.creatorSharedRecipes)
                                        : _model.userMeal;
                                    debugPrint('FavMealPage Builder: activeRecipes=${activeRecipes.length}');

                                    if (activeRecipes.isEmpty) {
                                      // Empty state for My Recipes
                                      if (_model.recipeSourceTab == 'my') {
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.menu_book_outlined,
                                                size: 64.0,
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'No recipes yet',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              Text(
                                                'To add recipes, share from Pinterest or the web:',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      color: const Color(0x991B1F26),
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              // Visual share flow: Share → Conscious Mama (house) → Recipe saved
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Share icon (user action)
                                                  Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF999999).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.share,
                                                      color: Color(0xFF666666),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(Icons.arrow_forward, size: 16.0, color: Color(0xFF999999)),
                                                  ),
                                                  // Conscious Mama app logo
                                                  Container(
                                                    width: 36.0,
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(6.0),
                                                      child: Image.asset(
                                                        'assets/images/image_22.png',
                                                        width: 36.0,
                                                        height: 36.0,
                                                        fit: BoxFit.cover,
                                                        color: FlutterFlowTheme.of(context).primary,
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Icon(Icons.arrow_forward, size: 16.0, color: Color(0xFF999999)),
                                                  ),
                                                  // Recipe saved icon
                                                  Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF9B8AA0).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.restaurant_menu,
                                                      color: Color(0xFF9B8AA0),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        // Discover tab empty (shouldn't happen normally)
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.explore_outlined,
                                                size: 64.0,
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'No recipes available',
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }

                                    return Align(
                                      alignment:
                                          const AlignmentDirectional(0.0, -1.0),
                                      child: Builder(
                                        builder: (context) {
                                          final containerVar = () {
                                            // First apply category filter based on selected tab
                                            debugPrint('FavMealPage Filter: categoryFilter=${_model.categoryFilter}, activeRecipes=${activeRecipes.length}');
                                            List<MealRecord> filtered;
                                            if (_model.categoryFilter == 'All') {
                                              filtered = activeRecipes;
                                            } else if (_model.categoryFilter == 'Entree') {
                                              // Recipe Type: Entree
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Main' ||
                                                      e.recipeType == RecipeType.Entree ||
                                                      (e.mainOrSides.isEmpty && e.recipeType != RecipeType.Side && e.recipeType != RecipeType.Snack && e.recipeType != RecipeType.Dessert))
                                                  .toList();
                                            } else if (_model.categoryFilter == 'Side') {
                                              // Recipe Type: Side
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Side' ||
                                                      e.recipeType == RecipeType.Side)
                                                  .toList();
                                            } else if (_model.categoryFilter == 'Snack') {
                                              // Recipe Type: Snack
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Snack' ||
                                                      e.recipeType == RecipeType.Snack)
                                                  .toList();
                                            } else if (_model.categoryFilter == 'Dessert') {
                                              // Recipe Type: Dessert
                                              filtered = activeRecipes
                                                  .where((e) =>
                                                      e.mainOrSides == 'Dessert' ||
                                                      e.recipeType == RecipeType.Dessert)
                                                  .toList();
                                            } else if (['Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Vegetarian', 'Vegan'].contains(_model.categoryFilter)) {
                                              // Dietary tags: Check if meal_typ contains this dietary tag
                                              final filterLower = _model.categoryFilter.toLowerCase();
                                              filtered = activeRecipes
                                                  .where((e) {
                                                    final tags = e.mealTyp.toLowerCase().split(',');
                                                    return tags.any((t) => t.trim() == filterLower);
                                                  })
                                                  .toList();
                                            } else {
                                              // Meal types: Breakfast, Lunch, Dinner, Snacks
                                              // meal_typ may contain comma-separated categories (e.g., "Lunch,Dinner,Gluten-Free")
                                              final filterLower = _model.categoryFilter.toLowerCase();
                                              filtered = activeRecipes
                                                  .where((e) {
                                                    final tags = e.mealTyp.toLowerCase().split(',');
                                                    return tags.any((t) => t.trim() == filterLower);
                                                  })
                                                  .toList();
                                            }
                                            // Then apply search filter
                                            if (_model.searchQuery.isNotEmpty) {
                                              final query = _model.searchQuery.toLowerCase();
                                              filtered = filtered
                                                  .where((e) =>
                                                      e.recipeName.toLowerCase().contains(query))
                                                  .toList();
                                            }
                                            debugPrint('FavMealPage Filter: after filtering=${filtered.length}');
                                            return filtered;
                                          }()
                                              .toList();

                                          debugPrint('FavMealPage: Rendering Wrap with ${containerVar.length} recipes, isSelectionMode=${_model.isSelectionMode}');

                                          // Show a message if no recipes after filtering
                                          if (containerVar.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(40.0),
                                                child: Text(
                                                  'No recipes match the current filter',
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                ),
                                              ),
                                            );
                                          }

                                          return Wrap(
                                            spacing: 7.0,
                                            runSpacing: 10.0,
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            direction: Axis.horizontal,
                                            runAlignment: WrapAlignment.start,
                                            verticalDirection:
                                                VerticalDirection.down,
                                            clipBehavior: Clip.none,
                                            children: List.generate(
                                                containerVar.length,
                                                (containerVarIndex) {
                                              final containerVarItem =
                                                  containerVar[
                                                      containerVarIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                // Creator Cookbook: long-press a
                                                // creator's shared recipe to add
                                                // it to your library or plan.
                                                onLongPress: (_model.cookbookMode ==
                                                            'creator' &&
                                                        _activeCreator != null &&
                                                        containerVarItem.userRef !=
                                                            currentUserReference)
                                                    ? () => _openRecipeActions(
                                                        containerVarItem)
                                                    : null,
                                                onTap: () async {
                                                  // Always navigate to recipe detail page
                                                  // Pass selection params if in selection mode
                                                  context.pushNamed(
                                                    CategoryDetailsLocalProducWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'itemDetails':
                                                          serializeParam(
                                                        containerVarItem,
                                                        ParamType.Document,
                                                      ),
                                                      if (widget.date != null)
                                                        'selectionDate':
                                                            serializeParam(
                                                          widget.date,
                                                          ParamType.DateTime,
                                                        ),
                                                      if (widget.mealTyp != null)
                                                        'selectionMealTyp':
                                                            serializeParam(
                                                          widget.mealTyp,
                                                          ParamType.Enum,
                                                        ),
                                                      if (widget.mealPlan != null)
                                                        'selectionMealPlan':
                                                            serializeParam(
                                                          widget.mealPlan,
                                                          ParamType.DocumentReference,
                                                        ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      'itemDetails':
                                                          containerVarItem,
                                                    },
                                                  ).then((_) {
                                                    if (mounted) _reloadUserRecipes();
                                                  });
                                                },
                                                child: Builder(
                                                  builder: (context) {
                                                    final screenWidth = MediaQuery.of(context).size.width;
                                                    final cols = screenWidth >= 900 ? 4 : screenWidth >= 600 ? 3 : 2;
                                                    final cardWidth = _model.recipeSourceTab == 'my'
                                                        ? (screenWidth - 40) / cols - 5
                                                        : screenWidth >= 600 ? 180.0 : 160.0;
                                                    return Container(
                                                  width: cardWidth,
                                                  height: 210.0,
                                                  decoration: const BoxDecoration(),
                                                  child: Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            1.0, -1.0),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(5.0),
                                                          child: Container(
                                                            width: double.infinity,
                                                            height: 208.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius.circular(5.0),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child: _isValidImageUrl(containerVarItem.imageUrl)
                                                                  ? Image.network(
                                                                      _upgradePinterestImageUrl(containerVarItem.imageUrl),
                                                                      width: double.infinity,
                                                                      height: double.infinity,
                                                                      fit: BoxFit.cover,
                                                                      filterQuality: FilterQuality.high,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        return _buildColoredPlaceholder(containerVarItem.recipeName);
                                                                      },
                                                                    )
                                                                  : _buildColoredPlaceholder(containerVarItem.recipeName),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  0.0, 1.0),
                                                          child: ClipRRect(
                                                            borderRadius: const BorderRadius.only(
                                                              bottomLeft: Radius.circular(5.0),
                                                              bottomRight: Radius.circular(5.0),
                                                            ),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Color(
                                                                    0xCCFFFFFF),
                                                              ),
                                                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      containerVarItem
                                                                          .recipeName,
                                                                      'Meal Name',
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily: FFAppState().currentFontFamily,
                                                                          fontSize:
                                                                              11.0,
                                                                          fontWeight: FontWeight.w600,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  if (FFAppState().showMealCosts && containerVarItem.hasEstimatedCost())
                                                                    Text(
                                                                      '\$${containerVarItem.estimatedCost.round()}',
                                                                      style: TextStyle(
                                                                        fontFamily: FFAppState().currentFontFamily,
                                                                        fontSize: 11.0,
                                                                        color: Color(0xFF2E7D32),
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  const SizedBox(height: 3.0),
                                                                  Builder(
                                                                    builder: (context) {
                                                                      final mealTypeChips = <Widget>[];
                                                                      final recipeTypeChips = <Widget>[];
                                                                      final dietaryChips = <Widget>[];

                                                                      // Parse mealTyp for meal types and dietary tags
                                                                      if (containerVarItem.mealTyp.isNotEmpty) {
                                                                        final tags = containerVarItem.mealTyp.split(',');
                                                                        final mealTypeOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
                                                                        final foundMealTypes = <String>[];
                                                                        for (final tag in tags) {
                                                                          final t = tag.trim();
                                                                          if (t.isEmpty) continue;
                                                                          if (mealTypeOrder.contains(t)) {
                                                                            foundMealTypes.add(t);
                                                                          } else {
                                                                            final abbr = t.replaceAll('-Free', '-F');
                                                                            dietaryChips.add(_buildRecipeChip(abbr, const Color(0xFFEE8B60)));
                                                                          }
                                                                        }
                                                                        // Sort meal types in canonical order
                                                                        foundMealTypes.sort((a, b) => mealTypeOrder.indexOf(a).compareTo(mealTypeOrder.indexOf(b)));
                                                                        for (final mt in foundMealTypes) {
                                                                          mealTypeChips.add(_buildRecipeChip(mt, const Color(0xFF52A097)));
                                                                        }
                                                                      }

                                                                      // Recipe type chip
                                                                      if (containerVarItem.recipeType == RecipeType.Side || containerVarItem.mainOrSides == 'Side') {
                                                                        recipeTypeChips.add(_buildRecipeChip('Side', Color(0xFF4A90D9)));
                                                                      } else if (containerVarItem.recipeType == RecipeType.Snack || containerVarItem.mainOrSides == 'Snack') {
                                                                        recipeTypeChips.add(_buildRecipeChip('Snack', Color(0xFFFF9800)));
                                                                      } else if (containerVarItem.recipeType == RecipeType.Dessert || containerVarItem.mainOrSides == 'Dessert') {
                                                                        recipeTypeChips.add(_buildRecipeChip('Dessert', const Color(0xFFE91E63)));
                                                                      }

                                                                      // Order: meal type → recipe type → dietary
                                                                      final chips = [...mealTypeChips, ...recipeTypeChips, ...dietaryChips];
                                                                      if (chips.isEmpty) return const SizedBox.shrink();
                                                                      return Wrap(
                                                                        spacing: 3.0,
                                                                        runSpacing: 2.0,
                                                                        alignment: WrapAlignment.center,
                                                                        children: chips,
                                                                      );
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              const AlignmentDirectional(
                                                                  1.0, -1.0),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        16.0,
                                                                        16.0,
                                                                        0.0),
                                                            child: StreamBuilder<
                                                                List<
                                                                    FavouritMealRecord>>(
                                                              stream:
                                                                  queryFavouritMealRecord(
                                                                queryBuilder:
                                                                    (favouritMealRecord) =>
                                                                        favouritMealRecord
                                                                            .where(
                                                                              'user_ref',
                                                                              isEqualTo: currentUserReference,
                                                                            )
                                                                            .where(
                                                                              'meal_ref',
                                                                              isEqualTo: containerVarItem.reference,
                                                                            ),
                                                                singleRecord:
                                                                    true,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                List<FavouritMealRecord>
                                                                    containerFavouritMealRecordList =
                                                                    snapshot
                                                                        .data!;
                                                                final containerFavouritMealRecord =
                                                                    containerFavouritMealRecordList
                                                                            .isNotEmpty
                                                                        ? containerFavouritMealRecordList
                                                                            .first
                                                                        : null;

                                                                return Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (containerFavouritMealRecord
                                                                              ?.reference ==
                                                                          null) {
                                                                        return InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            await FavouritMealRecord.collection.doc().set(createFavouritMealRecordData(
                                                                                  userRef: currentUserReference,
                                                                                  mealRef: containerVarItem.reference,
                                                                                ));
                                                                            FFAppState().favMealCash =
                                                                                true;
                                                                            safeSetState(() {});
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.favorite_border,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            // Only delete the favorite record, NOT the recipe
                                                                            await containerFavouritMealRecord!.reference.delete();
                                                                            FFAppState().favMealCash =
                                                                                true;
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.favorite,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        // Shared Library: creator
                                                        // share toggle (top-left).
                                                        if (_creatorProfile !=
                                                                null &&
                                                            _model.cookbookMode ==
                                                                'personal')
                                                          Positioned(
                                                            top: 8.0,
                                                            left: 8.0,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                final isShared =
                                                                    containerVarItem
                                                                        .sharedWithFollowers;
                                                                await containerVarItem
                                                                    .reference
                                                                    .update({
                                                                  'shared_with_followers':
                                                                      !isShared
                                                                });
                                                                if (mounted) {
                                                                  _reloadUserRecipes();
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                          SnackBar(
                                                                    content: Text(isShared
                                                                        ? 'Removed from Shared'
                                                                        : 'Shared with followers'),
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10)),
                                                                    margin: const EdgeInsets
                                                                        .all(16),
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            2),
                                                                  ));
                                                                }
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: containerVarItem
                                                                          .sharedWithFollowers
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary
                                                                      : Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.4),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  containerVarItem
                                                                          .sharedWithFollowers
                                                                      ? Icons
                                                                          .people
                                                                      : Icons
                                                                          .people_outline,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 14.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                  }),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 8.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(5.0),
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
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add button
            if (_model.recipeSourceTab == 'my' || _model.recipeSourceTab == 'templates' || _model.recipeSourceTab == 'savedDays')
              FloatingActionButton(
                heroTag: 'add_recipe',
                onPressed: () {
                  if (_model.recipeSourceTab == 'savedDays') {
                    // Open create day template flow
                    _showCreateDayTemplateSheet(context);
                  } else if (_model.recipeSourceTab == 'templates') {
                    // Navigate to meal composer in template creation mode
                    context.pushNamed(
                      'MealComposer',
                      queryParameters: {
                        'editTemplateId': 'new', // Special value to indicate creating new template
                      },
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.bottomToTop,
                        ),
                      },
                    );
                  } else {
                    // Navigate to create recipe page for My Recipes
                    context.pushNamed(
                      'EditeAddMeal',
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.bottomToTop,
                        ),
                      },
                    );
                  }
                },
                backgroundColor: FlutterFlowTheme.of(context).primary,
                elevation: 4.0,
                child: const Icon(Icons.add, color: Colors.white, size: 28.0),
              ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to name a Saved Day + pick preferred days, then let
  /// user build each meal via MealComposer.
  void _showCreateDayTemplateSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final Set<int> selectedDays = {};

    // Step 1: Ask for name + preferred days.
    final result = await showDialog<_CreateDayResult>(
      context: context,
      builder: (ctx) {
        final dialogTheme = FlutterFlowTheme.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Text(
              'Create Saved Day',
              style: dialogTheme.titleMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                letterSpacing: 0.0,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Give your saved day a name, then build each meal:',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: dialogTheme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'e.g., Taco Tuesday, Lazy Sunday',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    ),
                    style: dialogTheme.bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Preferred days (optional, tap any)',
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Autofill lands this saved day on any day you pick below.",
                    style: dialogTheme.bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      letterSpacing: 0.0,
                      color: dialogTheme.secondaryText,
                      fontSize: 11.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _editWeekdayChip(dialogTheme, 'None',
                          selected: selectedDays.isEmpty,
                          onTap: () => setDialogState(() => selectedDays.clear())),
                      ...List.generate(7, (i) {
                        final w = i + 1;
                        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return _editWeekdayChip(dialogTheme, labels[i],
                            selected: selectedDays.contains(w),
                            onTap: () => setDialogState(() {
                                  if (!selectedDays.remove(w)) selectedDays.add(w);
                                }));
                      }),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.pop(ctx, _CreateDayResult(name, selectedDays.toList()..sort()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: dialogTheme.primary),
                child: Text('Next'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null || result.name.isEmpty || !mounted) return;

    final dayName = result.name;
    final preferredDays = result.preferredDays;

    // Generate group ID for this day template
    final groupId = '${DateTime.now().millisecondsSinceEpoch}';

    // Step 2: Show bottom sheet with meal slots
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (sheetContext) => _DayTemplateBuilderSheet(
        dayName: dayName,
        groupId: groupId,
        onDone: () async {
          // Stamp every template in this group with the preferred days the
          // user picked in step 1. Done here so it fires regardless of how
          // many meals they built / in what order.
          if (preferredDays.isNotEmpty) {
            try {
              final snap = await MealComboRecord.collection
                  .where('day_template_group', isEqualTo: groupId)
                  .get();
              for (final doc in snap.docs) {
                await doc.reference.update({'preferred_weekdays': preferredDays});
              }
            } catch (e) {
              debugPrint('Error writing preferred_weekdays on create: $e');
            }
          }
          Navigator.pop(sheetContext);
          _model.loadedMealTemplates = false;
          _loadMealTemplates();
        },
        onNavigateToComposer: (MealTyp mealType, String? existingMealId) async {
          // Navigate to MealComposer to build/edit a meal for this day slot
          await context.pushNamed(
            MealComposerWidget.routeName,
            queryParameters: {
              'editTemplateId': existingMealId ?? 'new',
              'mealType': serializeParam(mealType, ParamType.Enum),
              'dayTemplateGroup': groupId,
              'dayTemplateName': dayName,
            },
          );
          // Reload parent's templates too
          _model.loadedMealTemplates = false;
          _loadMealTemplates();
        },
      ),
    );
  }

  /// Open the day template builder sheet for editing an existing meal template
  void _showEditDayTemplateSheet(BuildContext context, String groupId, String dayName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (sheetContext) => _DayTemplateBuilderSheet(
        dayName: dayName,
        groupId: groupId,
        onDone: () {
          Navigator.pop(sheetContext);
          _model.loadedMealTemplates = false;
          _loadMealTemplates();
        },
        onNavigateToComposer: (MealTyp mealType, String? existingMealId) async {
          await context.pushNamed(
            MealComposerWidget.routeName,
            queryParameters: {
              'editTemplateId': existingMealId ?? 'new',
              'mealType': serializeParam(mealType, ParamType.Enum),
              'dayTemplateGroup': groupId,
              'dayTemplateName': dayName,
            },
          );
          _model.loadedMealTemplates = false;
          _loadMealTemplates();
        },
      ),
    );
  }

  /// Apply a meal template's templates to a chosen date in the meal planner
  Future<void> _applyDayTemplateToDate(BuildContext context, List<MealComboRecord> templates, String groupName) async {
    // Get dates from meal planner calendar selector, fall back to next 7 days
    final plannerDates = FFAppState().mealPlanSelectedDates;
    final dates = (plannerDates != null && plannerDates.isNotEmpty)
        ? (List<DateTime>.from(plannerDates)..sort())
        : List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

    // Fetch existing meal plans for all dates to show planned indicators
    List<MealPlanRecord> allPlans = [];
    try {
      final earliest = DateTime(dates.first.year, dates.first.month, dates.first.day);
      final latest = DateTime(dates.last.year, dates.last.month, dates.last.day).add(const Duration(days: 1));
      allPlans = await queryMealPlanRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('date', isGreaterThanOrEqualTo: earliest)
            .where('date', isLessThan: latest),
      );
    } catch (_) {}

    if (!mounted) return;

    // Build a set of dates that already have meals
    final plannedDates = <String>{};
    for (final plan in allPlans) {
      if (plan.date != null) {
        plannedDates.add('${plan.date!.year}-${plan.date!.month}-${plan.date!.day}');
      }
    }

    // Show bottom sheet with day chips
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = FlutterFlowTheme.of(sheetContext);
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(sheetContext).padding.bottom + 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Apply "$groupName" to:',
                style: theme.titleSmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${templates.length} meal${templates.length > 1 ? 's' : ''} will be added',
                style: theme.bodySmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF999999),
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 16.0),
              // Day chips
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: dates.map((date) {
                  final normalized = DateTime(date.year, date.month, date.day);
                  final dateKey = '${normalized.year}-${normalized.month}-${normalized.day}';
                  final hasPlans = plannedDates.contains(dateKey);
                  final isToday = normalized.year == DateTime.now().year &&
                      normalized.month == DateTime.now().month &&
                      normalized.day == DateTime.now().day;

                  return InkWell(
                    onTap: () => Navigator.pop(sheetContext, normalized),
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isToday
                            ? theme.primary.withOpacity(0.1)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: isToday
                              ? theme.primary.withOpacity(0.4)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dateTimeFormat('E', normalized),
                            style: theme.bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              color: isToday ? theme.primary : const Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            dateTimeFormat('MMMd', normalized),
                            style: theme.bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                            ),
                          ),
                          if (hasPlans) ...[
                            const SizedBox(height: 4.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                'planned',
                                style: theme.bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 9.0,
                                  color: const Color(0xFFFF9800),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;

    final targetDate = picked;

    // Check existing meals on that specific day
    final existingPlans = allPlans.where((p) {
      if (p.date == null) return false;
      return p.date!.year == targetDate.year &&
             p.date!.month == targetDate.month &&
             p.date!.day == targetDate.day;
    }).toList();

    // If meals exist, ask to replace or skip
    bool replaceExisting = false;
    if (existingPlans.isNotEmpty) {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Day Already Has Meals'),
          content: Text(
            '${dateTimeFormat('EEEE, MMMd', targetDate)} already has ${existingPlans.length} meal${existingPlans.length > 1 ? 's' : ''} planned. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'skip'),
              child: const Text('Keep Existing'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'replace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(ctx).primary,
              ),
              child: const Text('Replace All'),
            ),
          ],
        ),
      );

      if (result == null || result == 'cancel' || !mounted) return;
      replaceExisting = result == 'replace';
    }

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        SizedBox(width: 12), Text('Applying meals...'),
      ]), duration: Duration(seconds: 10)),
    );

    try {
      // Delete existing meals if replacing
      if (replaceExisting) {
        for (final plan in existingPlans) {
          await plan.reference.delete();
        }
      }

      int addedCount = 0;
      final existingTypes = replaceExisting
          ? <String>{}
          : existingPlans.map((p) => p.typ?.name ?? '').toSet();

      for (final template in templates) {
        final mealType = template.mealTyp;
        if (mealType == null) continue;

        // Skip if keeping existing and this meal type already has a plan
        if (!replaceExisting && existingTypes.contains(mealType.name)) continue;

        // Create meal plan record referencing this template
        await MealPlanRecord.collection.add({
          'user_ref': currentUserReference,
          'date': targetDate,
          'typ': mealType.name,
          'meal_combo_ref': template.reference,
        });
        addedCount++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (addedCount > 0) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$addedCount meal${addedCount > 1 ? 's' : ''} added to ${dateTimeFormat('EEEE, MMMd', targetDate)}!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No new meals to add'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error applying meal template'), backgroundColor: Colors.red),
      );
    }
  }

  /// Build the Saved Days view — groups day templates by their shared group ID
  Future<double> _sumTemplateCost(List<MealComboRecord> templates) async {
    double total = 0;
    for (final t in templates) {
      final refs = <DocumentReference>[];
      if (t.entreeRef != null) refs.add(t.entreeRef!);
      refs.addAll(t.sideRefs);
      final snackRefs = t.snapshotData['snack_refs'] as List<dynamic>?;
      if (snackRefs != null) {
        for (final r in snackRefs) {
          if (r is DocumentReference) refs.add(r);
        }
      }
      for (final ref in refs) {
        try {
          final doc = await ref.get();
          if (doc.exists) {
            final meal = MealRecord.fromSnapshot(doc);
            if (meal.hasEstimatedCost()) total += meal.estimatedCost;
          }
        } catch (_) {}
      }
    }
    return total;
  }

  Widget _buildSavedDaysView(BuildContext context) {
    // Shared Library: source by cookbook mode (creator's own shared / active
    // creator's shared / all own), then keep only day-template groups.
    final dayTemplateSource = _model.cookbookMode == 'creator'
        ? (_creatorProfile != null
            ? _model.mealTemplates
                .where((t) => t.sharedWithFollowers)
                .toList()
            : _model.creatorSharedTemplates)
        : _model.mealTemplates;
    // Filter templates that have a day_template_group
    final dayTemplates = dayTemplateSource
        .where((t) => t.hasDayTemplateGroup())
        .toList();

    // Apply search filter
    final searchFiltered = _model.searchQuery.isEmpty
        ? dayTemplates
        : dayTemplates.where((t) {
            final query = _model.searchQuery.toLowerCase();
            return t.dayTemplateName.toLowerCase().contains(query) ||
                   t.name.toLowerCase().contains(query);
          }).toList();

    if (dayTemplates.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Saved Days Yet',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Save an entire day\'s meals from your meal planner using the "Save Day" button. They\'ll show up here for easy reuse!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    // Group by day_template_group
    final Map<String, List<MealComboRecord>> grouped = {};
    for (final t in searchFiltered) {
      grouped.putIfAbsent(t.dayTemplateGroup, () => []).add(t);
    }

    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.0, color: FlutterFlowTheme.of(context).primary.withOpacity(0.5)),
            const SizedBox(height: 16.0),
            Text(
              'No Results Found',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    // Sort groups by created time (most recent first)
    final sortedGroups = grouped.entries.toList()
      ..sort((a, b) {
        final aTime = a.value.first.createdTime ?? DateTime(2000);
        final bTime = b.value.first.createdTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        children: sortedGroups.map((entry) {
          final templates = entry.value;
          final groupName = templates.first.dayTemplateName.isNotEmpty
              ? templates.first.dayTemplateName
              : 'Meal Template';
          final createdDate = templates.first.createdTime;
          final weekdayLabel = _weekdaysLabel(templates.first.preferredWeekdays);

          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14.0),
                        topRight: Radius.circular(14.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18.0,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        const SizedBox(width: 8.0),
                        // Shared Library: share the whole saved day with followers.
                        if (_creatorProfile != null &&
                            _model.cookbookMode == 'personal')
                          GestureDetector(
                            onTap: () async {
                              final isShared =
                                  templates.first.sharedWithFollowers;
                              for (final t in templates) {
                                await t.reference.update(
                                    {'shared_with_followers': !isShared});
                              }
                              _model.loadedMealTemplates = false;
                              _loadMealTemplates();
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(isShared
                                      ? 'Removed from Shared'
                                      : 'Shared with followers'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                ));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                templates.first.sharedWithFollowers
                                    ? Icons.people
                                    : Icons.people_outline,
                                size: 18.0,
                                color: templates.first.sharedWithFollowers
                                    ? FlutterFlowTheme.of(context).primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupName,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              if (createdDate != null)
                                Text(
                                  weekdayLabel != null
                                      ? '$weekdayLabel · Saved ${dateTimeFormat('MMMd', createdDate)}'
                                      : 'Saved ${dateTimeFormat('MMMd', createdDate)}',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        color: const Color(0xFF999999),
                                        fontSize: 11.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${templates.length} meal${templates.length > 1 ? 's' : ''}',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            FutureBuilder<double>(
                              future: FFAppState().showMealCosts ? _sumTemplateCost(templates) : Future.value(0.0),
                              builder: (ctx, snap) {
                                final total = snap.data ?? 0;
                                if (total <= 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    '\$${total.round()}',
                                    style: TextStyle(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 12.0,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Edit saved day (name + preferred weekday)
                        IconButton(
                          tooltip: 'Edit Saved Day',
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 18.0,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                          onPressed: () => _editSavedDayGroup(templates),
                        ),
                      ],
                    ),
                  ),
                  // Individual meals in this day (sorted: Breakfast, Lunch, Dinner, Snacks)
                  ...(List<MealComboRecord>.from(templates)..sort((a, b) {
                    const order = {MealTyp.Breakfast: 0, MealTyp.Lunch: 1, MealTyp.Dinner: 2, MealTyp.Snacks: 3};
                    return (order[a.mealTyp] ?? 4).compareTo(order[b.mealTyp] ?? 4);
                  })).map((template) {
                    // For snacks, load first snack ref; for others, load entreeRef
                    final isSnackType = template.mealTyp == MealTyp.Snacks;
                    final snackRefs = template.snapshotData['snack_refs'] as List<dynamic>?;
                    final firstSnackRef = (snackRefs != null && snackRefs.isNotEmpty && snackRefs.first is DocumentReference)
                        ? snackRefs.first as DocumentReference
                        : null;
                    final recipeRef = template.entreeRef ?? firstSnackRef;

                    return FutureBuilder<MealRecord?>(
                      future: recipeRef != null
                          ? recipeRef.get().then((doc) =>
                              doc.exists ? MealRecord.fromSnapshot(doc) : null)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        final entree = snapshot.data;
                        final mealTypeName = template.mealTyp?.name ?? '';

                        // Check leftover flags
                        final hasLeftover =
                          template.snapshotData['is_leftover_entree'] == true ||
                          template.snapshotData['is_leftover_side'] == true ||
                          template.snapshotData['is_leftover_dessert'] == true ||
                          template.snapshotData['is_leftover_snack'] == true;

                        return InkWell(
                          onTap: () {
                            // Open in MealComposer for viewing/editing
                            context.pushNamed(
                              MealComposerWidget.routeName,
                              queryParameters: {
                                'date': serializeParam(DateTime.now(), ParamType.DateTime),
                                'mealType': serializeParam(template.mealTyp ?? MealTyp.Dinner, ParamType.Enum),
                                'editTemplateId': template.reference.id,
                                'dayTemplateGroup': entry.key,
                                'dayTemplateName': groupName,
                              },
                            ).then((_) {
                              // Reload templates after returning
                              _model.loadedMealTemplates = false;
                              _loadMealTemplates();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            child: Row(
                              children: [
                                // Meal image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    width: 44.0,
                                    height: 44.0,
                                    color: const Color(0xFFE0E0E0),
                                    child: entree != null && entree.imageUrl.isNotEmpty
                                        ? Image.network(
                                            _upgradePinterestImageUrl(entree.imageUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.restaurant,
                                              color: Color(0xFF999999),
                                              size: 22.0,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.restaurant,
                                            color: Color(0xFF999999),
                                            size: 22.0,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                // Meal info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entree?.recipeName ?? template.name,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          if (mealTypeName.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4.0),
                                              ),
                                              child: Text(
                                                mealTypeName,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: FFAppState().currentFontFamily,
                                                      fontSize: 10.0,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ),
                                          if (hasLeftover) ...[
                                            const SizedBox(width: 5.0),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF9800).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4.0),
                                              ),
                                              child: Text(
                                                'L',
                                                style: TextStyle(
                                                  fontFamily: FFAppState().currentFontFamily,
                                                  fontSize: 9.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFFFF9800),
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isSnackType && snackRefs != null && snackRefs.length > 1) ...[
                                            const SizedBox(width: 6.0),
                                            Text(
                                              '+${snackRefs.length - 1} more',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    fontSize: 10.0,
                                                    color: const Color(0xFF999999),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ] else if (!isSnackType && template.sideRefs.isNotEmpty) ...[
                                            const SizedBox(width: 6.0),
                                            Text(
                                              '+${template.sideRefs.length} side${template.sideRefs.length > 1 ? 's' : ''}',
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    fontSize: 10.0,
                                                    color: const Color(0xFF999999),
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                          ],
                                          if (FFAppState().showMealCosts && entree != null && entree.hasEstimatedCost()) ...[
                                            Spacer(),
                                            Text(
                                              '\$${entree.estimatedCost.round()}',
                                              style: TextStyle(
                                                fontFamily: FFAppState().currentFontFamily,
                                                fontSize: 11.0,
                                                color: Color(0xFF2E7D32),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 20.0,
                                  color: Color(0xFFCCCCCC),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 6.0),
                  // Action buttons row
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 10.0),
                    child: Row(
                      children: [
                        // Apply to Day button
                        Expanded(
                          child: InkWell(
                            onTap: () => _applyDayTemplateToDate(context, templates, groupName),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 15.0, color: FlutterFlowTheme.of(context).primary),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'Apply to Day',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                          fontFamily: FFAppState().currentFontFamily,
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Share meal template button
                        InkWell(
                          onTap: () async {
                            // Gather all meal refs from the templates
                            final mealRefs = <DocumentReference>{};
                            for (final t in templates) {
                              if (t.entreeRef != null) mealRefs.add(t.entreeRef!);
                              for (final ref in t.sideRefs) {
                                mealRefs.add(ref);
                              }
                              for (final ref in t.dessertRefs) {
                                mealRefs.add(ref);
                              }
                              final snackRefs = t.snapshotData['snack_refs'] as List<dynamic>?;
                              if (snackRefs != null) {
                                for (final ref in snackRefs) {
                                  if (ref is DocumentReference) mealRefs.add(ref);
                                }
                              }
                            }
                            // Load all referenced meals
                            final allMeals = <MealRecord>[];
                            for (final ref in mealRefs) {
                              final doc = await ref.get();
                              if (doc.exists) {
                                allMeals.add(MealRecord.fromSnapshot(doc));
                              }
                            }
                            if (mounted) {
                              showShareDayTemplateBottomSheet(
                                context: context,
                                dayTemplateName: groupName,
                                templates: templates,
                                allMeals: allMeals,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(Icons.share_outlined, size: 16.0, color: FlutterFlowTheme.of(context).primary),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Edit meal template button
                        InkWell(
                          onTap: () => _showEditDayTemplateSheet(context, entry.key, groupName),
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(Icons.edit_outlined, size: 16.0, color: FlutterFlowTheme.of(context).secondary),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Delete meal template button
                        InkWell(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                                title: Text('Delete "$groupName"?'),
                                content: Text('This will delete all ${templates.length} templates in this meal template.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              for (final t in templates) {
                                await t.reference.delete();
                              }
                              _model.loadedMealTemplates = false;
                              await _loadMealTemplates();
                            }
                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(Icons.delete_outline, size: 16.0, color: Colors.red.withOpacity(0.6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build the Saved Days view
  Widget _buildTemplatesView(BuildContext context) {
    // Shared Library: source by cookbook mode — creator sees their own shared
    // templates, a follower sees the active creator's, else all own.
    final templateSource = _model.cookbookMode == 'creator'
        ? (_creatorProfile != null
            ? _model.mealTemplates
                .where((t) => t.sharedWithFollowers)
                .toList()
            : _model.creatorSharedTemplates)
        : _model.mealTemplates;
    // Exclude day templates — those show in the Saved Days tab
    final regularTemplates = templateSource
        .where((t) => !t.hasDayTemplateGroup())
        .toList();

    // Apply category filter
    final dietaryFilters = ['Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Vegetarian', 'Vegan'];
    final filteredTemplates = _model.categoryFilter == 'All'
        ? regularTemplates
        : dietaryFilters.contains(_model.categoryFilter)
            ? regularTemplates.where((template) {
                // For dietary filters, require ALL recipes in the template to match
                final filterLower = _model.categoryFilter.toLowerCase();
                final allRefs = <DocumentReference>[
                  if (template.entreeRef != null) template.entreeRef!,
                  ...template.sideRefs,
                  ...template.dessertRefs,
                ];
                if (allRefs.isEmpty) return false;
                // Check that every recipe has the matching dietary tag
                for (final ref in allRefs) {
                  final matchingRecipe = _model.userMeal.where((r) => r.reference.path == ref.path).firstOrNull;
                  if (matchingRecipe == null) return false;
                  final tags = matchingRecipe.mealTyp.toLowerCase().split(',');
                  if (!tags.any((t) => t.trim() == filterLower)) return false;
                }
                return true;
              }).toList()
            : regularTemplates.where((template) {
                // Meal type filter (Breakfast, Lunch, Dinner, Snacks)
                if (template.mealTyp == null) return false;
                final mealTypName = template.mealTyp!.name;
                return mealTypName == _model.categoryFilter;
              }).toList();

    // Apply search filter
    final searchFiltered = _model.searchQuery.isEmpty
        ? filteredTemplates
        : filteredTemplates.where((template) {
            final query = _model.searchQuery.toLowerCase();
            return template.name.toLowerCase().contains(query);
          }).toList();

    if (regularTemplates.isEmpty) {
      // Empty state - no templates at all
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Templates Yet',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Templates are reusable combinations of entrée, sides, and drinks that you can save from the meal planner and quickly add to your meal plan.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Save your favorite meal combinations from the calendar to create templates!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    if (searchFiltered.isEmpty) {
      // Empty state - filtered out all templates
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 40.0, 16.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.0,
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No Templates Found',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              _model.categoryFilter != 'All'
                  ? 'No ${_model.categoryFilter} templates yet'
                  : 'No templates match your search',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFF666666),
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    // Display filtered meal templates
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        children: [
          // Templates list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchFiltered.length,
            itemBuilder: (context, index) {
              final template = searchFiltered[index];
              return _buildTemplateCard(context, template);
            },
          ),
        ],
      ),
    );
  }

  /// Build a meal template card
  Widget _buildTemplateCard(BuildContext context, MealComboRecord template) {
    return FutureBuilder<MealRecord?>(
      future: template.entreeRef != null
          ? template.entreeRef!.get().then((doc) =>
              doc.exists ? MealRecord.fromSnapshot(doc) : null)
          : Future.value(null),
      builder: (context, snapshot) {
        final entree = snapshot.data;

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
          child: InkWell(
            onTap: () async {
              if (_model.isSelectionMode && widget.date != null && widget.mealTyp != null) {
                // Add template to meal plan
                await _addTemplateToMealPlan(template);
              } else {
                // Show template details or navigate to meal composer with template
                _showTemplateDetails(template);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Template image with badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 72.0,
                          height: 72.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                          ),
                          child: entree != null && _isValidImageUrl(entree.imageUrl)
                              ? Image.network(
                                  _upgradePinterestImageUrl(entree.imageUrl),
                                  width: 72.0,
                                  height: 72.0,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildColoredPlaceholder(template.name),
                                )
                              : _buildColoredPlaceholder(template.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14.0),
                  // Template info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Leftover badge (reads from raw Firestore data)
                            if (template.snapshotData['is_leftover_entree'] == true ||
                                template.snapshotData['is_leftover_side'] == true ||
                                template.snapshotData['is_leftover_dessert'] == true ||
                                template.snapshotData['is_leftover_snack'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                margin: const EdgeInsets.only(right: 6.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(color: const Color(0xFFFF9800), width: 1.0),
                                ),
                                child: Text(
                                  'Leftover',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF9800),
                                    fontFamily: FFAppState().currentFontFamily,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                template.name.isNotEmpty ? template.name : (entree?.recipeName ?? 'Meal Template'),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (template.mealTyp != null) ...[
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  template.mealTyp!.name,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontFamily: FFAppState().currentFontFamily,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            // Shared Library: share this template with followers.
                            if (_creatorProfile != null &&
                                _model.cookbookMode == 'personal')
                              GestureDetector(
                                onTap: () async {
                                  final isShared =
                                      template.sharedWithFollowers;
                                  await template.reference.update(
                                      {'shared_with_followers': !isShared});
                                  _model.loadedMealTemplates = false;
                                  _loadMealTemplates();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(isShared
                                          ? 'Removed from Shared'
                                          : 'Shared with followers'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 2),
                                    ));
                                  }
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    template.sharedWithFollowers
                                        ? Icons.people
                                        : Icons.people_outline,
                                    size: 18.0,
                                    color: template.sharedWithFollowers
                                        ? FlutterFlowTheme.of(context)
                                            .primary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        // Components
                        Row(
                          children: [
                            // Entrée icon
                            const Icon(Icons.restaurant, size: 12.0, color: Color(0xFFFF9800)),
                            const SizedBox(width: 2.0),
                            Flexible(
                              child: Text(
                                entree?.recipeName ?? 'Entrée',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: const Color(0xFF666666),
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Sides count
                            if (template.sideRefs.isNotEmpty) ...[
                              const SizedBox(width: 8.0),
                              const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.eco, size: 12.0, color: Color(0xFF4CAF50)),
                              const SizedBox(width: 2.0),
                              Text(
                                '${template.sideRefs.length}',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                            // Dessert count
                            if (template.dessertRefs.isNotEmpty) ...[
                              const SizedBox(width: 8.0),
                              const Icon(Icons.add, size: 10.0, color: Color(0xFFAAAAAA)),
                              const SizedBox(width: 4.0),
                              const Icon(Icons.cake, size: 12.0, color: Color(0xFFE91E63)),
                              const SizedBox(width: 2.0),
                              Text(
                                '${template.dessertRefs.length}',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Cost
                  FutureBuilder<double>(
                    future: FFAppState().showMealCosts ? _sumTemplateCost([template]) : Future.value(0.0),
                    builder: (ctx, snap) {
                      final cost = snap.data ?? 0;
                      if (cost <= 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          '\$${cost.round()}',
                          style: TextStyle(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 12.0,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  // Arrow icon
                  const Icon(
                    Icons.chevron_right,
                    size: 20.0,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Day Template Builder — shows meal slots, each navigates to MealComposer
class _DayTemplateBuilderSheet extends StatefulWidget {
  final String dayName;
  final String groupId;
  final VoidCallback onDone;
  final Future<void> Function(MealTyp mealType, String? existingMealId) onNavigateToComposer;

  const _DayTemplateBuilderSheet({
    required this.dayName,
    required this.groupId,
    required this.onDone,
    required this.onNavigateToComposer,
  });

  @override
  State<_DayTemplateBuilderSheet> createState() => _DayTemplateBuilderSheetState();
}

class _DayTemplateBuilderSheetState extends State<_DayTemplateBuilderSheet> {
  List<MealComboRecord> _dayMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDayMeals();
  }

  Future<void> _loadDayMeals() async {
    try {
      final results = await queryMealComboRecordOnce(
        queryBuilder: (q) => q
            .where('user_ref', isEqualTo: currentUserReference)
            .where('day_template_group', isEqualTo: widget.groupId),
      );
      if (mounted) {
        setState(() {
          _dayMeals = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading day template meals: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final filledTypes = _dayMeals.map((t) => t.mealTyp).whereType<MealTyp>().toSet();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, MediaQuery.of(context).padding.bottom + 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dayName,
                      style: theme.titleSmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      'Tap a meal to add it',
                      style: theme.bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: const Color(0xFF999999),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (filledTypes.isNotEmpty)
                Text(
                  '${filledTypes.length}/4 meals',
                  style: theme.bodySmall.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )),
          // 4 meal slots — tap goes straight to MealComposer
          if (!_isLoading)
            ...MealTyp.values.map((mealType) {
              final isFilled = filledTypes.contains(mealType);
              final meal = _dayMeals.where((t) => t.mealTyp == mealType).firstOrNull;

              // Check leftover flags from raw snapshot data
              final hasLeftover = meal != null && (
                meal.snapshotData['is_leftover_entree'] == true ||
                meal.snapshotData['is_leftover_side'] == true ||
                meal.snapshotData['is_leftover_dessert'] == true ||
                meal.snapshotData['is_leftover_snack'] == true
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () async {
                    await widget.onNavigateToComposer(mealType, meal?.reference.id);
                    // Reload after user returns from MealComposer
                    if (mounted) _loadDayMeals();
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? theme.primary.withOpacity(0.05)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isFilled
                            ? theme.primary.withOpacity(0.3)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Show entree/snack thumbnail when filled, add icon when empty
                        if (isFilled && (meal?.entreeRef != null || (meal?.snapshotData['snack_refs'] as List<dynamic>?)?.isNotEmpty == true))
                          Builder(
                            builder: (context) {
                              final snackRefsList = meal!.snapshotData['snack_refs'] as List<dynamic>?;
                              final imageRef = meal.entreeRef
                                  ?? ((snackRefsList != null && snackRefsList.isNotEmpty && snackRefsList.first is DocumentReference)
                                      ? snackRefsList.first as DocumentReference : null);
                              if (imageRef == null) {
                                return Container(
                                  width: 36.0, height: 36.0,
                                  decoration: BoxDecoration(
                                    color: theme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(Icons.restaurant, size: 16.0, color: theme.primary),
                                );
                              }
                              return FutureBuilder<DocumentSnapshot>(
                                future: imageRef.get(),
                            builder: (context, snapshot) {
                              final imageUrl = (snapshot.data?.data() as Map<String, dynamic>?)?['image_url'] as String?;
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 36.0,
                                    height: 36.0,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 36.0, height: 36.0,
                                      decoration: BoxDecoration(
                                        color: theme.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Icon(Icons.restaurant, size: 16.0, color: theme.primary),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 36.0, height: 36.0,
                                      decoration: BoxDecoration(
                                        color: theme.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Icon(Icons.restaurant, size: 16.0, color: theme.primary),
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                width: 36.0, height: 36.0,
                                decoration: BoxDecoration(
                                  color: theme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(Icons.restaurant, size: 16.0, color: theme.primary),
                              );
                            },
                              );
                            },
                          )
                        else
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? theme.primary.withOpacity(0.15)
                                  : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              isFilled ? Icons.restaurant : Icons.add,
                              size: 18.0,
                              color: isFilled ? theme.primary : const Color(0xFF999999),
                            ),
                          ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    mealType.name,
                                    style: theme.bodyMedium.override(
                                      fontFamily: FFAppState().currentFontFamily,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  if (hasLeftover) ...[
                                    const SizedBox(width: 6.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        'L',
                                        style: TextStyle(
                                          fontFamily: FFAppState().currentFontFamily,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFF9800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                isFilled
                                    ? meal?.name ?? 'Meal added'
                                    : 'Tap to add',
                                style: theme.bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  fontSize: 11.0,
                                  color: isFilled ? theme.primary : const Color(0xFF999999),
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20.0,
                          color: Color(0xFFCCCCCC),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 8.0),
          // Done button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: filledTypes.isEmpty ? null : () => widget.onDone(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
              ),
              child: Text(
                filledTypes.isEmpty
                    ? 'Add at least one meal'
                    : 'Done',
                style: TextStyle(
                  fontFamily: FFAppState().currentFontFamily,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Template Details Bottom Sheet Widget
class _TemplateDetailsSheet extends StatelessWidget {
  final MealComboRecord template;
  final VoidCallback onAddToMealPlan;
  final VoidCallback? onEdit;
  final VoidCallback? onRename;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const _TemplateDetailsSheet({
    required this.template,
    required this.onAddToMealPlan,
    this.onEdit,
    this.onRename,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MealRecord>>(
      future: _loadTemplateRecipes(),
      builder: (context, snapshot) {
        final recipes = snapshot.data ?? [];
        final entree = recipes.isNotEmpty ? recipes.first : null;
        final sides = recipes.length > 1 ? recipes.sublist(1) : <MealRecord>[];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2.0)),
                    ),
                  ),
                  // Header — show template name or fallback
                  Text(
                    template.name.isNotEmpty
                        ? template.name
                        : (snapshot.connectionState == ConnectionState.done && entree != null
                            ? entree.recipeName ?? 'Meal Template'
                            : 'Meal Template'),
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 16.0),
                  // Template contents
                  if (entree != null) ...[
                    Text(
                      'Entrée:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      entree.recipeName ?? 'Unknown',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (sides.isNotEmpty) ...[
                    Text(
                      'Sides:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    ...sides.map((side) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${side.recipeName ?? 'Unknown'}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        )),
                    const SizedBox(height: 12.0),
                  ],
                  if (template.drinkType != null || (template.drinkCustom.isNotEmpty ?? false)) ...[
                    Text(
                      'Drink:',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFF666666),
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      template.drinkCustom.isNotEmpty ?? false ? template.drinkCustom : template.drinkType!.name,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  const SizedBox(height: 8.0),
                  // Add to meal plan button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAddToMealPlan,
                      icon: const Icon(Icons.add_circle_outline, size: 20.0),
                      label: const Text('Add to Meal Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ),
                  // Edit actions
                  if (onEdit != null || onRename != null || onShare != null || onDelete != null) ...[
                    const SizedBox(height: 12.0),
                    const Divider(height: 1),
                    const SizedBox(height: 4.0),
                    if (onEdit != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.edit, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: const Text('Edit Meal Template', style: TextStyle(fontSize: 14.0)),
                        onTap: onEdit,
                      ),
                    if (onRename != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_note, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: const Text('Rename', style: TextStyle(fontSize: 14.0)),
                        onTap: onRename,
                      ),
                    if (onShare != null)
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.ios_share, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                        title: const Text('Share', style: TextStyle(fontSize: 14.0)),
                        onTap: onShare,
                      ),
                    if (onDelete != null)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.delete, color: Colors.red, size: 20.0),
                        title: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14.0)),
                        onTap: onDelete,
                      ),
                  ],
                  const SizedBox(height: 8.0),
                  // Close button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<MealRecord>> _loadTemplateRecipes() async {
    final recipes = <MealRecord>[];

    // Load entree
    if (template.entreeRef != null) {
      final entreeDoc = await template.entreeRef!.get();
      if (entreeDoc.exists) {
        recipes.add(MealRecord.fromSnapshot(entreeDoc));
      }
    }

    // Load sides
    for (final sideRef in template.sideRefs) {
      final sideDoc = await sideRef.get();
      if (sideDoc.exists) {
        recipes.add(MealRecord.fromSnapshot(sideDoc));
      }
    }

    return recipes;
  }
}

/// Tiny return holder for the Create Saved Day dialog.
class _CreateDayResult {
  final String name;
  final List<int> preferredDays;
  const _CreateDayResult(this.name, this.preferredDays);
}
