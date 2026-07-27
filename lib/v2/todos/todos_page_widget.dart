import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/home_nav_bar_widget.dart';
import '/components/parent_circle_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/recurrence_util.dart';
import '/components/page_animations.dart';
import '/v2/creator/creator_theme_wrapper.dart';
import 'package:flutter/material.dart';

/// Todos Page - Grocery-list style todo management
class TodosPageWidget extends StatefulWidget {
  const TodosPageWidget({super.key});

  static String routeName = 'TodosPage';
  static String routePath = '/todos';

  @override
  State<TodosPageWidget> createState() => _TodosPageWidgetState();
}

class _TodosPageWidgetState extends State<TodosPageWidget> with TickerProviderStateMixin, PageAnimationMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSaving = false;
  bool _isAdding = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Assignment state
  bool _assignToMom = false;
  bool _assignToDad = false;
  List<DocumentReference> _selectedChildren = [];
  List<ChildernRecord>? _userChildren;
  ParentDisplayInfo _parentInfo = ParentDisplayInfo.defaults();

  // Recurrence state for the add form (weekdays 1=Mon..7=Sun; empty = one-time).
  List<int> _recurDays = [];
  int _recurIntervalWeeks = 1;

  String get _todayYmd => ymdString(DateTime.now());

  /// A recurring todo counts as "done" only if it was completed today; on a
  /// new day it auto-resets to incomplete. One-time todos use is_completed.
  bool _effectiveCompleted(TodoRecord t) => t.hasRecurDays()
      ? (t.isCompleted && t.lastCompletedDate == _todayYmd)
      : t.isCompleted;

  @override
  void initState() {
    super.initState();
    _loadChildren();
    _loadParentInfo();
    initPageAnimations(itemCount: 1);
  }

  Future<void> _loadParentInfo() async {
    if (currentUserReference == null) return;
    final user = await UsersRecord.getDocumentOnce(currentUserReference!);
    if (mounted) {
      setState(() {
        _parentInfo = ParentDisplayInfo.fromUser(user);
      });
    }
  }

  Future<void> _loadChildren() async {
    final children = await queryChildernRecordOnce(
      queryBuilder: (childernRecord) => childernRecord.where(
        'userRef',
        isEqualTo: currentUserReference,
      ),
    );
    if (mounted) {
      setState(() {
        _userChildren = children;
      });
    }
  }

  @override
  void dispose() {
    disposePageAnimations();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _toggleTodo(TodoRecord todo) async {
    final nowDone = !_effectiveCompleted(todo);
    if (todo.hasRecurDays()) {
      // Recurring: stamp the completion date so it auto-resets tomorrow.
      await todo.reference.update({
        'is_completed': nowDone,
        'last_completed_date': nowDone ? _todayYmd : '',
      });
    } else {
      await todo.reference.update({'is_completed': nowDone});
    }
  }

  Future<void> _deleteTodo(TodoRecord todo) async {
    await todo.reference.delete();
  }

  Future<void> _clearCompleted() async {
    final completedTodos = await queryTodoRecordOnce(
      queryBuilder: (todoRecord) => todoRecord
          .where('user_ref', isEqualTo: currentUserReference)
          .where('is_completed', isEqualTo: true),
    );
    for (final todo in completedTodos) {
      await todo.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFFFF8F5),
        bottomNavigationBar: const HomeNavBarWidget(currentPage: HomeNavPage.homeSubpage),
        floatingActionButton: !_isAdding ? FloatingActionButton(
          onPressed: () {
            setState(() {
              _isAdding = true;
            });
            // Focus text field after setState completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _textFocusNode.requestFocus();
            });
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 4.0,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28.0,
          ),
        ) : null,
        body: CreatorThemedBackground(
          width: double.infinity,
          height: double.infinity,
          stops: const [0.0, 1.0],
          begin: const AlignmentDirectional(0.0, -1.0),
          end: const AlignmentDirectional(0, 1.0),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                animateItem(0, _buildHeader(context)),
                // Todo List
                Expanded(
                  child: _buildTodoList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => context.safePop(),
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF5D4E60),
                size: 24.0,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Title
          Text(
            'To-Dos',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              color: const Color(0xFF5D4E60),
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const Spacer(),
          // Clear completed button
          StreamBuilder<List<TodoRecord>>(
            stream: queryTodoRecord(
              queryBuilder: (todoRecord) => todoRecord
                  .where('user_ref', isEqualTo: currentUserReference)
                  .where('is_completed', isEqualTo: true),
            ),
            builder: (context, snapshot) {
              final completedCount = snapshot.data?.length ?? 0;
              if (completedCount == 0) return const SizedBox.shrink();

              return InkWell(
                onTap: _clearCompleted,
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_sweep_rounded,
                        color: Color(0xFF9B8A9E),
                        size: 18.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Clear done',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context) {
    return StreamBuilder<List<TodoRecord>>(
      stream: queryTodoRecord(
        queryBuilder: (todoRecord) => todoRecord
            .where('user_ref', isEqualTo: currentUserReference),
      ),
      builder: (context, snapshot) {
        // Show skeleton while initial data loads
        if (!snapshot.hasData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      PulsingPlaceholder(width: 24.0, height: 24.0, borderRadius: 12.0, durationMs: 1200 + (i * 200)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: PulsingPlaceholder(height: 16.0, borderRadius: 8.0, durationMs: 1300 + (i * 200)),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          );
        }
        final allTodos = snapshot.data ?? [];
        // Filter and sort locally to avoid needing composite Firestore index.
        // Recurring todos use effective (per-day) completion so they resurface
        // each scheduled day.
        final incompleteTodos = allTodos
            .where((t) => !_effectiveCompleted(t))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        final completedTodos = allTodos
            .where((t) => _effectiveCompleted(t))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Inline add field (when adding)
                    if (_isAdding) ...[
                      _buildInlineAddField(context),
                      const SizedBox(height: 16.0),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16.0),
                    ],
                    // Hint text at top
                    if (incompleteTodos.isNotEmpty || completedTodos.isNotEmpty) ...[
                      Center(
                        child: Text(
                          'Swipe left to delete \u2022 Tap to assign',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: const Color(0xFFBBBBBB),
                            fontSize: 11.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                    ],
                    // Incomplete todos — staggered entrance
                    ...incompleteTodos.asMap().entries.map((entry) => CascadeItem(
                      key: ValueKey('todo_${entry.value.reference.id}'),
                      index: entry.key,
                      baseDelayMs: 350,
                      staggerMs: 100,
                      child: _buildTodoItem(context, entry.value),
                    )),
                    // Completed section
                    if (completedTodos.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      // Completed header
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF9B8A9E),
                            size: 18.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Completed (${completedTodos.length})',
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: const Color(0xFF9B8A9E),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      ...completedTodos.map((todo) => _buildTodoItem(context, todo)),
                    ],
                    // Empty state
                    if (incompleteTodos.isEmpty && completedTodos.isEmpty && !_isAdding) ...[
                      const SizedBox(height: 40.0),
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.checklist_rounded,
                              size: 48.0,
                              color: Color(0xFFDADADA),
                            ),
                            const SizedBox(height: 20.0),
                            FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  _isAdding = true;
                                });
                              },
                              text: 'Add a To-do',
                              options: FFButtonOptions(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            Text(
                              'Keep track of things you need to get done.\nAssign to-dos to family members too.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: const Color(0xFFBBBBBB),
                                fontSize: 13.0,
                                lineHeight: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInlineAddField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field with checkmark/x buttons
        Row(
          children: [
            // Empty circle placeholder
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFDDDDDD),
                  width: 2.0,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Text field
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitTodo(),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a to-do...',
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FFAppState().currentFontFamily,
                    color: const Color(0xFFBBBBBB),
                    fontSize: 15.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            // Cancel button (X)
            GestureDetector(
              onTap: _cancelAdd,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF5D4E60),
                  size: 20.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            // Submit button (checkmark)
            GestureDetector(
              onTap: _isSaving ? null : _submitTodo,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _textController.text.trim().isNotEmpty && !_isSaving
                      ? const Color(0xFF7CB342)
                      : const Color(0xFF7CB342).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
              ),
            ),
          ],
        ),
        // Assignment chips
        Padding(
          padding: const EdgeInsets.only(left: 36.0, top: 8.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              // Repeat chip
              Builder(builder: (context) {
                final primary = FlutterFlowTheme.of(context).primary;
                final on = _recurDays.isNotEmpty;
                return GestureDetector(
                  onTap: _showRepeatPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: on ? primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: on ? primary : const Color(0xFFE0E0E0),
                        width: on ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.repeat_rounded,
                            size: 16.0, color: on ? primary : const Color(0xFF9B8A9E)),
                        const SizedBox(width: 6.0),
                        Text(
                          on ? recurrenceLabel(_recurDays, _recurIntervalWeeks) : 'Repeat',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: on ? primary : const Color(0xFF9B8A9E),
                            fontSize: 12.0,
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Mom chip
              GestureDetector(
                onTap: () => setState(() => _assignToMom = !_assignToMom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: _assignToMom
                        ? const Color(0xFFEC407A).withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: _assignToMom ? const Color(0xFFEC407A) : const Color(0xFFE0E0E0),
                      width: _assignToMom ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC407A),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('M', style: TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Mom',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: _assignToMom ? const Color(0xFFEC407A) : const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          fontWeight: _assignToMom ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dad chip
              GestureDetector(
                onTap: () => setState(() => _assignToDad = !_assignToDad),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: _assignToDad
                        ? const Color(0xFF1976D2).withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: _assignToDad ? const Color(0xFF1976D2) : const Color(0xFFE0E0E0),
                      width: _assignToDad ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          color: _parentInfo.partnerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(_parentInfo.partnerInitial, style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        _parentInfo.partnerName,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: _assignToDad ? Color(_parentInfo.partnerColor.value) : const Color(0xFF9B8A9E),
                          fontSize: 12.0,
                          fontWeight: _assignToDad ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Children chips
              if (_userChildren != null && _userChildren!.isNotEmpty) ...[
                ..._userChildren!.map((child) {
                  final isSelected = _selectedChildren.contains(child.reference);
                  final childColor = child.selectedColor ?? FlutterFlowTheme.of(context).primary;
                  final initial = child.name.isNotEmpty ? child.name[0].toLowerCase() : '?';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedChildren.remove(child.reference);
                        } else {
                          _selectedChildren.add(child.reference);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected ? childColor.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: isSelected ? childColor : const Color(0xFFE0E0E0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18.0,
                            height: 18.0,
                            decoration: BoxDecoration(
                              color: childColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            child.name.length > 6 ? '${child.name.substring(0, 6)}...' : child.name,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: FFAppState().currentFontFamily,
                              color: isSelected ? childColor : const Color(0xFF9B8A9E),
                              fontSize: 11.0,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _cancelAdd() {
    setState(() {
      _isAdding = false;
      _textController.clear();
      _assignToMom = false;
      _assignToDad = false;
      _selectedChildren = [];
      _recurDays = [];
      _recurIntervalWeeks = 1;
    });
  }

  void _showRepeatPicker() {
    final primary = FlutterFlowTheme.of(context).primary;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // days 1..7
    final draftDays = <int>{..._recurDays};
    int draftInterval = _recurIntervalWeeks < 1 ? 1 : _recurIntervalWeeks;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            Widget preset(String label, List<int> days) {
              final sel = draftDays.length == days.length &&
                  days.every(draftDays.contains);
              return GestureDetector(
                onTap: () => setSheet(() {
                  draftDays
                    ..clear()
                    ..addAll(days);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
                  decoration: BoxDecoration(
                    color: sel ? primary.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: sel ? primary : const Color(0xFFE0E0E0)),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: sel ? primary : const Color(0xFF5D4E60),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0)),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 18,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Repeat',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Color(0xFF5D4E60))),
                  const SizedBox(height: 14.0),
                  Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                    preset('Every day', const [1, 2, 3, 4, 5, 6, 7]),
                    preset('Weekdays', const [1, 2, 3, 4, 5]),
                    preset('Weekends', const [6, 7]),
                  ]),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final sel = draftDays.contains(day);
                      return GestureDetector(
                        onTap: () => setSheet(() {
                          if (!draftDays.remove(day)) draftDays.add(day);
                        }),
                        child: Container(
                          width: 38.0, height: 38.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? primary : Colors.transparent,
                            border: Border.all(
                                color: sel ? primary : const Color(0xFFE0E0E0), width: 1.5),
                          ),
                          child: Center(
                            child: Text(dayLabels[i],
                                style: TextStyle(
                                    color: sel ? Colors.white : const Color(0xFF9B8A9E),
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const Text('Every',
                          style: TextStyle(fontSize: 14.0, color: Color(0xFF5D4E60))),
                      const SizedBox(width: 12.0),
                      _stepBtn(Icons.remove, () {
                        if (draftInterval > 1) setSheet(() => draftInterval--);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('$draftInterval',
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Color(0xFF5D4E60))),
                      ),
                      _stepBtn(Icons.add, () {
                        if (draftInterval < 12) setSheet(() => draftInterval++);
                      }),
                      const SizedBox(width: 10.0),
                      Text(draftInterval == 1 ? 'week' : 'weeks',
                          style: const TextStyle(fontSize: 14.0, color: Color(0xFF5D4E60))),
                    ],
                  ),
                  const SizedBox(height: 22.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _recurDays = [];
                              _recurIntervalWeeks = 1;
                            });
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text('One-time', style: TextStyle(color: Color(0xFF9B8A9E))),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          onPressed: () {
                            setState(() {
                              _recurDays = draftDays.toList()..sort();
                              _recurIntervalWeeks = draftInterval;
                            });
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text('Done', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32.0, height: 32.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 18.0, color: const Color(0xFF5D4E60)),
        ),
      );

  Future<void> _submitTodo() async {
    final title = _textController.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final existingTodos = await queryTodoRecordOnce(
        queryBuilder: (todoRecord) => todoRecord
            .where('user_ref', isEqualTo: currentUserReference),
      );
      final sortOrders = existingTodos.map((t) => t.sortOrder).toList();
      final maxSortOrder = sortOrders.isEmpty ? 0 : sortOrders.reduce((a, b) => a > b ? a : b);

      await TodoRecord.collection.add(createTodoRecordData(
        title: title,
        isCompleted: false,
        userRef: currentUserReference,
        createdTime: getCurrentTimestamp,
        sortOrder: maxSortOrder + 1,
        assignedToMom: _assignToMom,
        assignedToDad: _assignToDad,
        selectedChildren: _selectedChildren.isNotEmpty ? _selectedChildren : null,
        recurDays: _recurDays.isNotEmpty ? (_recurDays..sort()) : null,
        recurIntervalWeeks: _recurDays.isNotEmpty ? _recurIntervalWeeks : null,
        recurAnchor: _recurDays.isNotEmpty ? _todayYmd : null,
      ));

      // Reset for next todo
      _textController.clear();
      setState(() {
        _isSaving = false;
        _assignToMom = false;
        _assignToDad = false;
        _selectedChildren = [];
        _recurDays = [];
        _recurIntervalWeeks = 1;
      });

      // Keep focus for rapid entry
      _textFocusNode.requestFocus();
    } catch (e) {
      debugPrint('Error adding todo: $e');
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding todo: $e')),
        );
      }
    }
  }

  Widget _buildTodoItem(BuildContext context, TodoRecord todo) {
    final isCompleted = _effectiveCompleted(todo);
    final recurLabel =
        todo.hasRecurDays() ? recurrenceLabel(todo.recurDays, todo.recurIntervalWeeks) : '';

    return Dismissible(
      key: Key(todo.reference.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
          size: 22.0,
        ),
      ),
      onDismissed: (_) => _deleteTodo(todo),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onTap: () => _showAssignmentSheet(context, todo),
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: Row(
              children: [
                // Checkbox - tap to toggle
                GestureDetector(
                  onTap: () => _toggleTodo(todo),
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? FlutterFlowTheme.of(context).primary : Colors.transparent,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 2.0,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16.0,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12.0),
                // Title (+ repeat badge)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        todo.title,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: isCompleted ? const Color(0xFF9B8A9E) : const Color(0xFF5D4E60),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (recurLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat_rounded,
                                  size: 12.0,
                                  color: FlutterFlowTheme.of(context).primary),
                              const SizedBox(width: 4.0),
                              Text(
                                recurLabel,
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Assignee icons (on the right)
                _buildAssigneeIcons(todo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignmentSheet(BuildContext context, TodoRecord todo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AssignmentBottomSheet(
        todo: todo,
        onUpdate: () => setState(() {}),
        parentInfo: _parentInfo,
      ),
    );
  }

  Widget _buildAssigneeIcons(TodoRecord todo) {
    final List<Widget> icons = [];

    if (todo.assignedToMom) {
      icons.add(_buildMomIcon());
    }
    if (todo.assignedToDad) {
      icons.add(_buildDadIcon());
    }
    if (todo.selectedChildren.isNotEmpty) {
      for (var i = 0; i < todo.selectedChildren.length && i < 2; i++) {
        icons.add(_buildChildIcon(todo.selectedChildren[i]));
      }
      if (todo.selectedChildren.length > 2) {
        icons.add(_buildMoreIndicator(todo.selectedChildren.length - 2));
      }
    }

    if (icons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 24.0 + (icons.length - 1) * 14.0,
      height: 24.0,
      child: Stack(
        children: icons.asMap().entries.map((entry) {
          return Positioned(
            left: entry.key * 14.0,
            child: entry.value,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMomIcon() {
    return Container(
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEC407A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: const Center(
        child: Text(
          'M',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDadIcon() {
    return Container(
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: const Center(
        child: Text(
          'D',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChildIcon(DocumentReference childRef) {
    return FutureBuilder<ChildernRecord>(
      future: ChildernRecord.getDocumentOnce(childRef),
      builder: (context, snapshot) {
        final child = snapshot.data;
        final color = child?.selectedColor ?? const Color(0xFF52A097);
        final initial = (child?.name.isNotEmpty == true) ? child!.name[0].toUpperCase() : 'C';

        return Container(
          width: 22.0,
          height: 22.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        color: const Color(0xFF9B8A9E),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for assigning family members to a todo
class _AssignmentBottomSheet extends StatefulWidget {
  final TodoRecord todo;
  final VoidCallback onUpdate;
  final ParentDisplayInfo parentInfo;

  const _AssignmentBottomSheet({
    required this.todo,
    required this.onUpdate,
    required this.parentInfo,
  });

  @override
  State<_AssignmentBottomSheet> createState() => _AssignmentBottomSheetState();
}

class _AssignmentBottomSheetState extends State<_AssignmentBottomSheet> {
  late bool _assignedToMom;
  late bool _assignedToDad;
  late List<DocumentReference> _selectedChildren;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _assignedToMom = widget.todo.assignedToMom;
    _assignedToDad = widget.todo.assignedToDad;
    _selectedChildren = List.from(widget.todo.selectedChildren);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.todo.reference.update({
        'assigned_to_mom': _assignedToMom,
        'assigned_to_dad': _assignedToDad,
        'selected_children': _selectedChildren,
      });
      widget.onUpdate();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating todo: $e');
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeBottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0 + bottomPadding + safeBottomPadding),
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
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Title
              Text(
                'Assign To',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF5D4E60),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.todo.title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF9B8A9E),
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 20.0),
              // Mom/Dad row
              Row(
                children: [
                  // Mom chip
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _assignedToMom = !_assignedToMom),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: _assignedToMom
                              ? const Color(0xFFEC407A).withOpacity(0.15)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: _assignedToMom
                                ? const Color(0xFFEC407A)
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEC407A),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Mom',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: const Color(0xFF5D4E60),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Dad chip
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _assignedToDad = !_assignedToDad),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: _assignedToDad
                              ? const Color(0xFF1976D2).withOpacity(0.15)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: _assignedToDad
                                ? const Color(0xFF1976D2)
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: widget.parentInfo.partnerColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.parentInfo.partnerInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              widget.parentInfo.partnerName,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: const Color(0xFF5D4E60),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Children section
              Text(
                'Children',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FFAppState().currentFontFamily,
                  color: const Color(0xFF9B8A9E),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              // Children list
              StreamBuilder<List<ChildernRecord>>(
                stream: queryChildernRecord(
                  queryBuilder: (childernRecord) => childernRecord
                      .where('userRef', isEqualTo: currentUserReference),
                ),
                builder: (context, snapshot) {
                  final children = snapshot.data ?? [];
                  if (children.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No children added yet',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FFAppState().currentFontFamily,
                          color: const Color(0xFFBBBBBB),
                          fontSize: 13.0,
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: children.map((child) {
                      final isSelected = _selectedChildren.contains(child.reference);
                      final color = child.selectedColor ?? const Color(0xFF52A097);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedChildren.remove(child.reference);
                            } else {
                              _selectedChildren.add(child.reference);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    child.name.isNotEmpty ? child.name[0].toLowerCase() : 'c',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                child.name,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  color: const Color(0xFF5D4E60),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24.0),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
