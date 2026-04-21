import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/creator_service.dart';
import '/v2/creator/creator_theme_notifier.dart';
import '/v2/creator/creator_theme_wrapper.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

/// Routines page — view, create, edit, and run routines.
class RoutinesPageWidget extends StatefulWidget {
  const RoutinesPageWidget({super.key});

  static String routeName = 'RoutinesPage';
  static String routePath = '/routines';

  @override
  State<RoutinesPageWidget> createState() => _RoutinesPageWidgetState();
}

class _RoutinesPageWidgetState extends State<RoutinesPageWidget> {
  CreatorsRecord? _creatorProfile;

  /// Whether the follower has collapsed the "From {Creator}" section.
  /// Default expanded; collapse state is persisted per-creator (keyed by
  /// follower-uid:creator-code) so expanding/collapsing one creator
  /// doesn't affect another and the preference survives app restarts.
  bool _creatorSectionCollapsed = false;
  String? _loadedCollapseKey;
  static const _kCollapsePrefsKey = 'creator_routines_collapsed';

  @override
  void initState() {
    super.initState();
    _loadCreatorProfile();
  }

  String _collapseKey(CreatorsRecord creator) =>
      '${currentUserReference?.id ?? 'anon'}:${creator.code}';

  Future<void> _loadCollapsedStateFor(CreatorsRecord creator) async {
    final key = _collapseKey(creator);
    if (_loadedCollapseKey == key) return;
    final prefs = await SharedPreferences.getInstance();
    final collapsed = prefs.getStringList(_kCollapsePrefsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _loadedCollapseKey = key;
      // Default to EXPANDED for the first encounter with this creator.
      // Only collapse if the follower has explicitly collapsed before.
      _creatorSectionCollapsed = collapsed.contains(key);
    });
  }

  Future<void> _toggleCollapsed(CreatorsRecord creator) async {
    final key = _collapseKey(creator);
    final newValue = !_creatorSectionCollapsed;
    setState(() => _creatorSectionCollapsed = newValue);
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_kCollapsePrefsKey) ?? const <String>[]).toSet();
    if (newValue) {
      current.add(key);
    } else {
      current.remove(key);
    }
    await prefs.setStringList(_kCollapsePrefsKey, current.toList());
  }

  Future<void> _loadCreatorProfile() async {
    final profile = await getCurrentUserCreatorProfile();
    if (mounted && profile != null) {
      setState(() => _creatorProfile = profile);
    }
  }

  Future<void> _toggleShare(RoutinesRecord routine) async {
    final newValue = !routine.sharedWithFollowers;
    await routine.reference.update({'shared_with_followers': newValue});
    if (!mounted) return;
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newValue
          ? 'Shared "${routine.name}" with your followers'
          : 'Stopped sharing "${routine.name}"'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _copyCreatorRoutine(RoutinesRecord creatorRoutine, String creatorName) async {
    if (currentUserReference == null) return;
    HapticFeedback.mediumImpact();
    final data = createRoutinesRecordData(
      name: '${creatorRoutine.name} (by $creatorName)',
      emoji: creatorRoutine.emoji,
      steps: List<String>.from(creatorRoutine.steps),
      userRef: currentUserReference,
      createdAt: DateTime.now(),
      stepCompletions: List<bool>.filled(creatorRoutine.steps.length, false),
    );
    await RoutinesRecord.collection.add(data);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added "${creatorRoutine.name}" to your routines'),
      backgroundColor: FlutterFlowTheme.of(context).primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRoutineSheet(context),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CreatorThemedBackground(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: FlutterFlowTheme.of(context).primaryText),
                  ),
                  Text(
                    'Routines',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showCreateRoutineSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add_rounded, color: FlutterFlowTheme.of(context).primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Routines list — own routines, followed by creator-shared
            // routines (if the user has an active creator code).
            Expanded(
              child: StreamBuilder<List<RoutinesRecord>>(
                stream: queryRoutinesRecord(
                  queryBuilder: (q) => q
                      .where('user_ref', isEqualTo: currentUserReference),
                ),
                builder: (context, snapshot) {
                  final routines = snapshot.data ?? [];

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    children: [
                      if (routines.isEmpty)
                        _buildEmptyState()
                      else
                        ...routines.map(_buildRoutineCard),
                      _buildCreatorRoutinesSection(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Section shown to followers when they have an active creator code —
  /// lists the creator's routines where `shared_with_followers = true`
  /// and lets the follower copy any into their own routines.
  Widget _buildCreatorRoutinesSection() {
    return Consumer<CreatorThemeNotifier>(
      builder: (context, notifier, _) {
        final creator = notifier.activeCreator;
        if (creator == null || !creator.hasUserRef()) return const SizedBox.shrink();
        if (creator.userRef == currentUserReference) return const SizedBox.shrink();

        return StreamBuilder<List<RoutinesRecord>>(
          stream: queryRoutinesRecord(
            queryBuilder: (q) => q
                .where('user_ref', isEqualTo: creator.userRef)
                .where('shared_with_followers', isEqualTo: true),
          ),
          builder: (context, snapshot) {
            final shared = snapshot.data ?? [];
            if (shared.isEmpty) return const SizedBox.shrink();

            // Load persisted collapsed state the first time we see this
            // creator. Default = expanded; once the follower collapses it
            // once, it stays collapsed across restarts.
            _loadCollapsedStateFor(creator);

            final primary = FlutterFlowTheme.of(context).primary;
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tappable header — toggles collapse on the whole section.
                  InkWell(
                    onTap: () => _toggleCollapsed(creator),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.people, color: primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'From ${creator.name}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primary,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          Text(
                            '${shared.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: primary.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: _creatorSectionCollapsed ? 0 : 0.5,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(Icons.expand_more, color: primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          for (final r in shared) _buildSharedRoutineCard(r, creator),
                        ],
                      ),
                    ),
                    crossFadeState: _creatorSectionCollapsed
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSharedRoutineCard(RoutinesRecord routine, CreatorsRecord creator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FlutterFlowTheme.of(context).primary.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(routine.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${routine.steps.length} step${routine.steps.length == 1 ? '' : 's'}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FFAppState().currentFontFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _copyCreatorRoutine(routine, creator.name),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: FlutterFlowTheme.of(context).primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            // Dismiss (× button) — hides this routine from the
            // suggestions list without importing it. Persisted locally
            // so it stays hidden across app restarts.
            IconButton(
              tooltip: 'Hide',
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
              onPressed: () {
                HapticFeedback.selectionClick();
                _dismissCreatorRoutine(routine.reference.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No routines yet',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Routines are reusable checklists for things you do regularly. Create one and check off steps as you go.\n\nExamples:\n☀️ Morning Routine — Wake up, make bed, brush teeth, breakfast\n🍳 Cooking Routine — Prep, preheat, cook, plate, clean\n🌙 Bedtime Routine — Bath, PJs, story time, lights out',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FFAppState().currentFontFamily,
              color: const Color(0xFF999999),
              fontSize: 13,
              letterSpacing: 0,
              lineHeight: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FFButtonWidget(
            onPressed: () => _showCreateRoutineSheet(context),
            text: 'Create a Routine',
            options: FFButtonOptions(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: FFAppState().currentFontFamily,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(RoutinesRecord routine) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRunRoutineSheet(context, routine),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: emoji + name + play icon
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(routine.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      routine.name,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  // Creator-only: share with followers toggle. Placed with
                  // generous spacing on both sides so it can't be confused
                  // with the play button and doesn't crowd the title.
                  if (_creatorProfile != null) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleShare(routine),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          routine.sharedWithFollowers ? Icons.people : Icons.people_outline,
                          color: routine.sharedWithFollowers
                              ? FlutterFlowTheme.of(context).primary
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.play_circle_outline, color: FlutterFlowTheme.of(context).primary, size: 28),
                ],
              ),
              // Steps + edit/delete — aligned under the icon
              Padding(
                padding: const EdgeInsets.only(left: 58, top: 6),
                child: Row(
                  children: [
                    Builder(builder: (_) {
                      final today = _todayKey();
                      final isToday = routine.lastCompletedDate == today;
                      final done = isToday && routine.stepCompletions.length == routine.steps.length
                          ? routine.stepCompletions.where((c) => c).length
                          : 0;
                      final label = done > 0
                          ? '$done/${routine.steps.length} done today'
                          : '${routine.steps.length} step${routine.steps.length == 1 ? '' : 's'}';
                      return Text(label,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: done > 0 ? FlutterFlowTheme.of(context).primary : const Color(0xFF999999),
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    );
                    }),
                    const Spacer(),
                    // Edit button
                    GestureDetector(
                      onTap: () => _showCreateRoutineSheet(context, editing: routine),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Routine?'),
                            content: Text('Are you sure you want to delete "${routine.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) await routine.reference.delete();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Icon(Icons.delete_outline, size: 16, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoutineOptions(BuildContext context, RoutinesRecord routine) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: FlutterFlowTheme.of(context).primary),
              title: const Text('Edit Routine'),
              onTap: () {
                Navigator.pop(context);
                _showCreateRoutineSheet(context, editing: routine);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
              title: Text('Delete Routine', style: TextStyle(color: Colors.red.shade400)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Routine?'),
                    content: Text('Are you sure you want to delete "${routine.name}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await routine.reference.delete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Create or edit routine bottom sheet
  void _showCreateRoutineSheet(BuildContext context, {RoutinesRecord? editing}) {
    final nameController = TextEditingController(text: editing?.name ?? '');
    final stepControllers = (editing?.steps ?? []).map((s) => TextEditingController(text: s)).toList();
    String selectedEmoji = editing?.emoji ?? '📋';
    final emojis = ['📋', '☀️', '🌙', '🍳', '💪', '🧹', '📚', '🎯', '🏃', '🛁', '🎒', '✨'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void addStep() {
            setSheetState(() => stepControllers.add(TextEditingController()));
          }

          void removeStep(int index) {
            setSheetState(() {
              stepControllers[index].dispose();
              stepControllers.removeAt(index);
            });
          }

          Future<void> save() async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            final steps = stepControllers
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (steps.isEmpty) return;

            HapticFeedback.mediumImpact();

            if (editing != null) {
              await editing.reference.update({
                'name': name,
                'emoji': selectedEmoji,
                'steps': steps,
              });
            } else {
              await RoutinesRecord.collection.add(createRoutinesRecordData(
                name: name,
                emoji: selectedEmoji,
                steps: steps,
                userRef: currentUserReference,
                createdAt: DateTime.now(),
              ));
            }

            if (context.mounted) Navigator.pop(context);
          }

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),

                  // Title
                  Center(
                    child: Text(
                      editing != null ? 'Edit Routine' : 'New Routine',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: FFAppState().currentFontFamily, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Emoji picker
                  Text('Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojis.map((e) => GestureDetector(
                      onTap: () => setSheetState(() => selectedEmoji = e),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: selectedEmoji == e ? FlutterFlowTheme.of(context).primary.withOpacity(0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: selectedEmoji == e ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2) : null,
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text('Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FFAppState().currentFontFamily, fontSize: 16, letterSpacing: 0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Morning Routine',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Steps
                  Text('Steps', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  ...List.generate(stepControllers.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FlutterFlowTheme.of(context).primary)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stepControllers[i],
                            style: TextStyle(fontSize: 14, fontFamily: FFAppState().currentFontFamily),
                            decoration: InputDecoration(
                              hintText: 'Step ${i + 1}',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => removeStep(i),
                          child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )),

                  // Add step button
                  GestureDetector(
                    onTap: addStep,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, size: 20, color: FlutterFlowTheme.of(context).primary),
                          const SizedBox(width: 8),
                          Text('Add step', style: TextStyle(fontSize: 14, color: FlutterFlowTheme.of(context).primary, fontWeight: FontWeight.w500, fontFamily: FFAppState().currentFontFamily)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  FFButtonWidget(
                    onPressed: save,
                    text: editing != null ? 'Save Changes' : 'Create Routine',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: FFAppState().currentFontFamily, color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Run routine — checklist view with daily persistence and midnight reset.
  void _showRunRoutineSheet(BuildContext context, RoutinesRecord routine) {
    final today = _todayKey();
    final isToday = routine.lastCompletedDate == today;

    final checked = List<bool>.filled(routine.steps.length, false);
    if (isToday && routine.stepCompletions.length == routine.steps.length) {
      for (int i = 0; i < routine.steps.length; i++) {
        checked[i] = routine.stepCompletions[i];
      }
    }

    if (!isToday && routine.hasLastCompletedDate()) {
      routine.reference.update({
        'step_completions': checked,
        'last_completed_date': today,
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final completedCount = checked.where((c) => c).length;
          final progress = routine.steps.isEmpty ? 0.0 : completedCount / routine.steps.length;
          final allDone = completedCount == routine.steps.length && routine.steps.isNotEmpty;

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      Text(routine.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(routine.name, style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: FFAppState().currentFontFamily, fontWeight: FontWeight.w600, letterSpacing: 0,
                            )),
                            Text('$completedCount of ${routine.steps.length} steps', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontFamily: FFAppState().currentFontFamily)),
                          ],
                        ),
                      ),
                      if (allDone)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Done!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green.shade700, fontFamily: FFAppState().currentFontFamily)),
                        ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        allDone ? Colors.green : FlutterFlowTheme.of(context).primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Steps
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: routine.steps.length,
                    itemBuilder: (context, i) {
                      final isDone = checked[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setSheetState(() => checked[i] = !checked[i]);
                            routine.reference.update({
                              'step_completions': checked,
                              'last_completed_date': _todayKey(),
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDone ? FlutterFlowTheme.of(context).primary.withOpacity(0.06) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDone ? FlutterFlowTheme.of(context).primary.withOpacity(0.3) : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: isDone ? FlutterFlowTheme.of(context).primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: isDone ? FlutterFlowTheme.of(context).primary : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    routine.steps[i],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: FFAppState().currentFontFamily,
                                      color: isDone ? Colors.grey.shade500 : const Color(0xFF333333),
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Close button
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewPadding.bottom + 16),
                  child: FFButtonWidget(
                    onPressed: () => Navigator.pop(context),
                    text: allDone ? 'All Done! 🎉' : 'Close',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      color: allDone ? Colors.green : Colors.grey.shade200,
                      textStyle: TextStyle(
                        color: allDone ? Colors.white : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: FFAppState().currentFontFamily,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
