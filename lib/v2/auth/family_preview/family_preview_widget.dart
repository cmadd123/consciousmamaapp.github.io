import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/onboarding_progress_indicator_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/v2/auth/demo_data_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'family_preview_model.dart';
export 'family_preview_model.dart';

class FamilyPreviewWidget extends StatefulWidget {
  const FamilyPreviewWidget({super.key});

  static String routeName = 'familyPreview';
  static String routePath = '/familyPreview';

  @override
  State<FamilyPreviewWidget> createState() => _FamilyPreviewWidgetState();
}

class _FamilyPreviewWidgetState extends State<FamilyPreviewWidget>
    with SingleTickerProviderStateMixin {
  late FamilyPreviewModel _model;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyPreviewModel());

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: SafeArea(
              child: StreamBuilder<UsersRecord>(
                stream: UsersRecord.getDocument(currentUserReference!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = snapshot.data!;

                  // Get user's colors and names
                  final myName = user.myName;
                  final myColor = user.myColor != null
                      ? Color(user.myColor!)
                      : const Color(0xFFEC407A);
                  final partnerName = user.partnerName.isNotEmpty
                      ? user.partnerName
                      : 'Partner';
                  final partnerColor = user.partnerColor != null
                      ? Color(user.partnerColor!)
                      : const Color(0xFF1976D2);

                  // Fetch children to display in preview
                  return StreamBuilder<List<ChildernRecord>>(
                    stream: queryChildernRecord(
                      queryBuilder: (childernRecord) => childernRecord
                          .where('userRef', isEqualTo: currentUserReference),
                    ),
                    builder: (context, childSnapshot) {
                      final children = childSnapshot.data ?? [];
                      final firstChild = children.isNotEmpty ? children.first : null;

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                              // Back arrow
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => context.safePop(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              // Progress indicator
                              const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                                child: OnboardingProgressIndicator(
                                  currentStep: 7,
                                  totalSteps: 7,
                                ),
                              ),
                              // Celebration header
                              const Text(
                                '🎉',
                                style: TextStyle(fontSize: 48.0),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Your family is ready!',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).headlineMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Here\'s how your family will look in the app',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              const SizedBox(height: 32.0),

                              // Preview Card - Mock "My Week" activity
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12.0,
                                      color: Colors.black.withValues(alpha: 0.08),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Mini header
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18.0,
                                          color: FlutterFlowTheme.of(context).primary,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'My Week Preview',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context).primary,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),

                                    // Mock activity card 1 - parent + child
                                    _buildMockActivityCard(
                                      context,
                                      title: 'Story Time',
                                      duration: '15 min',
                                      assignedTo: [
                                        _AssignedPerson(myName[0].toUpperCase(), myColor),
                                        if (firstChild != null)
                                          _AssignedPerson(
                                            firstChild.name.isNotEmpty ? firstChild.name[0].toLowerCase() : 'c',
                                            firstChild.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                            isChild: true,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12.0),

                                    // Mock activity card 2 - both parents + child (or just user if no partner)
                                    _buildMockActivityCard(
                                      context,
                                      title: 'Park Adventure',
                                      duration: '45 min',
                                      assignedTo: [
                                        _AssignedPerson(myName[0].toUpperCase(), myColor),
                                        if (user.partnerName.isNotEmpty)
                                          _AssignedPerson(partnerName[0].toUpperCase(), partnerColor),
                                        if (firstChild != null)
                                          _AssignedPerson(
                                            firstChild.name.isNotEmpty ? firstChild.name[0].toLowerCase() : 'c',
                                            firstChild.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                            isChild: true,
                                          ),
                                      ],
                                    ),
                                    // Only show third activity if partner exists
                                    if (user.partnerName.isNotEmpty) ...[
                                      const SizedBox(height: 12.0),
                                      // Mock activity card 3 - partner + child
                                      _buildMockActivityCard(
                                        context,
                                        title: 'Bath Time',
                                        duration: '20 min',
                                        assignedTo: [
                                          _AssignedPerson(partnerName[0].toUpperCase(), partnerColor),
                                          if (firstChild != null)
                                            _AssignedPerson(
                                              firstChild.name.isNotEmpty ? firstChild.name[0].toLowerCase() : 'c',
                                              firstChild.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                              isChild: true,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              // Family circles display
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12.0,
                                      color: Colors.black.withValues(alpha: 0.08),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Your Family',
                                      style: FlutterFlowTheme.of(context).titleMedium.override(
                                        fontFamily: 'Andika New Basic',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // User circle
                                        _buildFamilyMember(
                                          context,
                                          name: myName,
                                          color: myColor,
                                          initial: myName[0].toUpperCase(),
                                        ),
                                        // Partner circle (only if name is provided)
                                        if (user.partnerName.isNotEmpty) ...[
                                          const SizedBox(width: 24.0),
                                          _buildFamilyMember(
                                            context,
                                            name: partnerName,
                                            color: partnerColor,
                                            initial: partnerName[0].toUpperCase(),
                                          ),
                                        ],
                                      ],
                                    ),
                                    // Show children from outer StreamBuilder
                                    if (children.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: Wrap(
                                          spacing: 16.0,
                                          runSpacing: 16.0,
                                          alignment: WrapAlignment.center,
                                          children: children.map((child) {
                                            return _buildFamilyMember(
                                              context,
                                              name: child.name,
                                              color: child.selectedColor ?? FlutterFlowTheme.of(context).primary,
                                              initial: child.name.isNotEmpty
                                                  ? child.name[0].toLowerCase()
                                                  : 'c',
                                              isChild: true,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32.0),

                              // Continue button
                              SizedBox(
                                width: double.infinity,
                                height: 56.0,
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    // Save children and mark onboarding complete before paywall
                                    try {
                                      final demoData = Provider.of<DemoDataNotifier>(context, listen: false);
                                      await demoData.saveToFirestore();
                                    } catch (e) {
                                      debugPrint('Error saving demo data: $e');
                                    }

                                    if (currentUserReference != null) {
                                      final userDoc = await currentUserReference!.get();
                                      final userData = userDoc.data() as Map<String, dynamic>?;
                                      final updateData = createUsersRecordData(
                                        onboardingCompleted: true,
                                      );
                                      if (userData == null || userData['free_trial_start'] == null) {
                                        updateData['free_trial_start'] = FieldValue.serverTimestamp();
                                      }
                                      await currentUserReference!.update(updateData);
                                    }

                                    // Update local state
                                    try {
                                      final appState = Provider.of<AppStateNotifier>(context, listen: false);
                                      appState.onboardingCompleted = true;
                                    } catch (e) {
                                      debugPrint('Could not update AppStateNotifier: $e');
                                    }

                                    if (mounted) {
                                      context.goNamed(PaimentCopyWidget.routeName);
                                    }
                                  },
                                  text: 'Let\'s Get Started!',
                                  options: FFButtonOptions(
                                    height: 56.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockActivityCard(
    BuildContext context, {
    required String title,
    required String duration,
    required List<_AssignedPerson> assignedTo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Colored bar
          Container(
            width: 4.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 12.0),
          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                // Duration tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 10.0,
                        color: Color(0xFF9C27B0),
                      ),
                      const SizedBox(width: 3.0),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontFamily: 'Andika New Basic',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Assignment circles (stacked)
          SizedBox(
            width: assignedTo.length == 1 ? 30.0 : 30.0 + (assignedTo.length - 1) * 18.0,
            height: 30.0,
            child: Stack(
              children: List.generate(assignedTo.length, (index) {
                return Positioned(
                  left: index * 18.0,
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: assignedTo[index].color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        assignedTo[index].initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMember(
    BuildContext context, {
    required String name,
    required Color color,
    required String initial,
    bool isChild = false,
  }) {
    return Column(
      children: [
        Container(
          width: isChild ? 50.0 : 60.0,
          height: isChild ? 50.0 : 60.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: color.withValues(alpha: 0.4),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: isChild ? 18.0 : 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Andika New Basic',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          name,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.0,
          ),
        ),
      ],
    );
  }
}

class _AssignedPerson {
  final String initial;
  final Color color;
  final bool isChild;

  _AssignedPerson(this.initial, this.color, {this.isChild = false});
}
