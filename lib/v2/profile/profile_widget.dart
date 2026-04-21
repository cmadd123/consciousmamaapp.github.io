import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/v2/creator/creator_theme_notifier.dart';
import '/v2/creator/creator_theme_wrapper.dart';
import '/v2/creator/enter_creator_code_widget.dart';
import '/v2/creator/creator_theme_editor.dart';
import '/custom_code/actions/creator_service.dart';
import '/backend/schema/structs/index.dart';
import '/components/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v1/pages/childern/children/children_widget.dart';
import '/v1/profile/delete_user/delete_user_widget.dart';
import '/v1/profile/profile_edit_pop_up/profile_edit_pop_up_widget.dart';
import '/v1/profile/profile_edite_email_pop_up/profile_edite_email_pop_up_widget.dart';
import 'dart:ui';
import '/index.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/page_animations.dart';
import '/v2/profile/edit_parent_info_sheet.dart' show EditParentInfoPage;
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> with TickerProviderStateMixin, PageAnimationMixin {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CreatorsRecord? _creatorProfile;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    initPageAnimations(itemCount: 5);
    _loadCreatorProfile();
  }

  Future<void> _loadCreatorProfile() async {
    final profile = await getCurrentUserCreatorProfile();
    if (mounted && profile != null) {
      setState(() => _creatorProfile = profile);
    }
  }

  @override
  void dispose() {
    disposePageAnimations();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed(HomeHybridWidget.routeName);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
        body: Stack(
          children: [
            CreatorThemedBackground(
              width: double.infinity,
              height: double.infinity,
              stops: const [0.0, 1.0],
              begin: const AlignmentDirectional(0.0, 1.0),
              end: const AlignmentDirectional(0, -1.0),
              fallbackStart: const Color(0xFFECE5E5),
              fallbackEnd: const Color(0xFFEDFFFD),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                    animateItem(0, Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.safePop();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_sharp,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 18.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 10.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 20.0, 0.0),
                                  child: Text(
                                    'Settings',
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  animateItem(1, Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 94.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 0.0, 0.0),
                            child: breathingWidget(ClipOval(
                              child: Container(
                                width: 62.0,
                                height: 62.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    if (currentUserPhoto != null &&
                                        currentUserPhoto != '') {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                        child: Image.network(
                                          currentUserPhoto,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                        child: Image.asset(
                                          'assets/images/woman.png',
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            )),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 0.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 8.0),
                                    child: AuthUserStreamWidget(
                                      builder: (context) => Text(
                                        currentUserDisplayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 24.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ),
                                  AuthUserStreamWidget(
                                    builder: (context) => Text(
                                      currentPhoneNumber,
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
                          Builder(
                            builder: (context) => Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 16.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(dialogContext)
                                                .unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: ProfileEditPopUpWidget(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.border_color_outlined,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  if (false)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Visibility(
                          visible: false,
                          child: Builder(
                            builder: (context) => InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      elevation: 0,
                                      insetPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      alignment: AlignmentDirectional(0.0, 0.0)
                                          .resolve(Directionality.of(context)),
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusScope.of(dialogContext)
                                              .unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: ProfileEditeEmailPopUpWidget(),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        child: Icon(
                                          Icons.lock_outline,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 24.0,
                                        ),
                                      ),
                                      Text(
                                        'Update Email',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  CascadeItem(index: 0, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(ChildrenWidget.routeName);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.people_outline,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'My Kids',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Parent Info (names & colors)
                  CascadeItem(index: 0, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditParentInfoPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.family_restroom,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Parent Info',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Comfort Mode Toggle - Hidden from UI but code preserved
                  // To re-enable comfort mode, uncomment the Padding widget below
                  // Padding(
                  //   padding:
                  //       EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 60.0,
                  //     decoration: BoxDecoration(
                  //       color: FlutterFlowTheme.of(context).secondaryBackground,
                  //       borderRadius: BorderRadius.circular(14.0),
                  //     ),
                  //     child: Padding(
                  //       padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  //       child: Row(
                  //         mainAxisSize: MainAxisSize.max,
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Row(
                  //             mainAxisSize: MainAxisSize.max,
                  //             mainAxisAlignment: MainAxisAlignment.start,
                  //             children: [
                  //               Padding(
                  //                 padding: EdgeInsetsDirectional.fromSTEB(
                  //                     0.0, 0.0, 16.0, 0.0),
                  //                 child: Icon(
                  //                   Icons.tune,
                  //                   color: FlutterFlowTheme.of(context).primary,
                  //                   size: 24.0,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 'Comfort Mode',
                  //                 style: FlutterFlowTheme.of(context)
                  //                     .bodyMedium
                  //                     .override(
                  //                       fontFamily: 'Andika New Basic',
                  //                       fontSize: 16.0,
                  //                       letterSpacing: 0.0,
                  //                       fontWeight: FontWeight.w500,
                  //                     ),
                  //               ),
                  //             ],
                  //           ),
                  //           Switch(
                  //             value: FFAppState().isComfortMode,
                  //             onChanged: (newValue) async {
                  //               safeSetState(() => FFAppState().isComfortMode = newValue);
                  //             },
                  //             activeThumbColor: FlutterFlowTheme.of(context).primary,
                  //             activeTrackColor: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.5),
                  //             inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
                  //             inactiveThumbColor: FlutterFlowTheme.of(context).secondaryText,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  CascadeItem(index: 1, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(
                            ForgetPaswwordWidget.routeName,
                            queryParameters: {
                              'email': serializeParam(
                                currentUserEmail,
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Change Password',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Notifications
                  CascadeItem(index: 2, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(NotificationSettingsWidget.routeName);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Notifications',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Clear Calendar
                  CascadeItem(index: 3, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Clear Calendar',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              content: Text(
                                'This will permanently delete ALL events, tasks, and activities from your calendar. This cannot be undone.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  child: Text(
                                    'Delete All',
                                    style: TextStyle(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;

                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            final userRef = currentUserReference;
                            if (userRef == null) {
                              Navigator.of(context).pop();
                              return;
                            }

                            final query = FirebaseFirestore.instance
                                .collection('event_and_task')
                                .where('user_ref', isEqualTo: userRef);

                            final snapshot = await query.get();
                            final total = snapshot.docs.length;

                            // Batch delete (500 per batch is Firestore limit)
                            final batches = <WriteBatch>[];
                            var currentBatch = FirebaseFirestore.instance.batch();
                            var count = 0;

                            for (final doc in snapshot.docs) {
                              currentBatch.delete(doc.reference);
                              count++;
                              if (count % 500 == 0) {
                                batches.add(currentBatch);
                                currentBatch = FirebaseFirestore.instance.batch();
                              }
                            }
                            if (count % 500 != 0) {
                              batches.add(currentBatch);
                            }

                            for (final batch in batches) {
                              await batch.commit();
                            }

                            // Dismiss loading
                            Navigator.of(context).pop();

                            HapticFeedback.mediumImpact();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cleared $total items from your calendar.',
                                  style: const TextStyle(fontFamily: 'Andika New Basic'),
                                ),
                                backgroundColor: FlutterFlowTheme.of(context).primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to clear calendar. Please try again.',
                                  style: const TextStyle(fontFamily: 'Andika New Basic'),
                                ),
                                backgroundColor: FlutterFlowTheme.of(context).error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Clear Calendar',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Creator Code — enter/change. Shows the active creator's
                  // code as a pill once set, otherwise a chevron.
                  CascadeItem(index: 5, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              final result = await showEnterCreatorCodeSheet(context);
                              if (result == true && mounted) setState(() {});
                            },
                            child: Container(
                              height: 60.0,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                        child: Icon(Icons.palette_outlined, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                                      ),
                                      Text(
                                        'Creator Code',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                    child: Consumer<CreatorThemeNotifier>(
                                      builder: (context, creatorTheme, _) {
                                        if (creatorTheme.hasActiveCreator) {
                                          return Text(
                                            creatorTheme.activeCreator!.code,
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'Andika New Basic',
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.0,
                                            ),
                                          );
                                        }
                                        return Icon(Icons.arrow_forward_ios, color: FlutterFlowTheme.of(context).primaryText, size: 18.0);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Theme toggle (only when a code is active)
                          Consumer<CreatorThemeNotifier>(
                            builder: (context, creatorTheme, _) {
                              if (!creatorTheme.hasActiveCreator) return const SizedBox.shrink();
                              return Column(
                                children: [
                                  Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Use ${creatorTheme.activeCreator!.name}\'s style',
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                        Switch.adaptive(
                                          value: creatorTheme.useCreatorTheme,
                                          onChanged: (val) => creatorTheme.setUseCreatorTheme(val),
                                          activeColor: creatorTheme.primaryColor ?? FlutterFlowTheme.of(context).primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
                  // Customize Theme — creators only, above Subscription
                  if (_creatorProfile != null)
                    CascadeItem(index: 5, baseDelayMs: 400, staggerMs: 80, child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatorThemeEditorWidget(creator: _creatorProfile!),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                    child: Icon(Icons.color_lens_outlined, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                                  ),
                                  Text(
                                    'Customize Theme',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: Icon(Icons.arrow_forward_ios, color: FlutterFlowTheme.of(context).primaryText, size: 18.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  // Subscription
                  CascadeItem(index: 5, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(PaimentCopyWidget.routeName);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.dollarSign,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Subscription',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Cancel Subscription
                  CascadeItem(index: 6, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Cancel Subscription?'),
                              content: Text(
                                'Your subscription will remain active until the end of your current billing period. You won\'t be charged again.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Keep Subscription'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Cancel Subscription',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final result = await actions.cancelSubscription();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              );
                            }
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.cancel_outlined,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Cancel Subscription',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Enter Share Code
                  CascadeItem(index: 6, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final codeController = TextEditingController();
                          final result = await showDialog<String>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Enter Share Code',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Enter the 8-character code to import shared content.',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Andika New Basic',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 13.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  TextField(
                                    controller: codeController,
                                    textCapitalization: TextCapitalization.characters,
                                    maxLength: 8,
                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Andika New Basic',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 3.0,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'CODE',
                                      hintStyle: TextStyle(
                                        color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.4),
                                        letterSpacing: 3.0,
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      counterText: '',
                                    ),
                                    autofocus: true,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(null),
                                  child: Text('Cancel', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final code = codeController.text.trim().toLowerCase();
                                    if (code.length == 8) {
                                      Navigator.of(dialogContext).pop(code);
                                    }
                                  },
                                  child: Text('Import', style: TextStyle(color: FlutterFlowTheme.of(context).primary, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          );
                          codeController.dispose();
                          if (result != null && result.isNotEmpty && mounted) {
                            context.pushNamed(
                              'ImportSharedContent',
                              queryParameters: {'shareCode': result},
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.qr_code_2,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Enter Share Code',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Logout
                  CascadeItem(index: 7, baseDelayMs: 400, staggerMs: 80, child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'Logout',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            content: Text(
                              'Are you sure you want to logout?',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(true),
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context).error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;

                        FFAppState().activityFinalModel = [];
                        safeSetState(() {});
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();

                        context.goNamedAuth(
                            Loginv2Widget.routeName, context.mounted);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Icon(
                                    Icons.logout_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                ),
                                Text(
                                  'Logout',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  // Delete Account Button
                  CascadeItem(index: 8, baseDelayMs: 400, staggerMs: 80, child: Builder(
                    builder: (context) => Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return Dialog(
                                elevation: 0,
                                insetPadding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                alignment: AlignmentDirectional(0.0, 0.0)
                                    .resolve(Directionality.of(context)),
                                child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(dialogContext).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  child: DeleteUserWidget(),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Icon(
                                      Icons.delete_sweep,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 24.0,
                                    ),
                                  ),
                                  Text(
                                    'Delete Account',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
                  // Add bottom padding to account for navigation bar
                  const SizedBox(height: 120.0),
                  ],
                ),
                ),
              ),
            ),
            // Add bottom safe area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0, -1),
                    end: const Alignment(0, 1),
                    colors: [
                      Color(0xFFEDFFFD).withValues(alpha: 0.0),
                      const Color(0xFFEDFFFD),
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: HomeNavBarWidget(
                currentPage: HomeNavPage.settings,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
