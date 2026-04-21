import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'loginv2_model.dart';
export 'loginv2_model.dart';

class Loginv2Widget extends StatefulWidget {
  const Loginv2Widget({super.key});

  static String routeName = 'Loginv2';
  static String routePath = '/loginv2';

  @override
  State<Loginv2Widget> createState() => _Loginv2WidgetState();
}

class _Loginv2WidgetState extends State<Loginv2Widget> {
  late Loginv2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Loginv2Model());

    _model.emailTextController ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7F2EB), Color(0xFFFFE9E1)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, 1.0),
              end: AlignmentDirectional(0, -1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 0.0),
              child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  fontSize: 32.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 22.0, 0.0, 40.0),
                            child: Text(
                              'Login to your account.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Andika New Basic',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 10.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.emailTextController,
                                    focusNode: _model.textFieldFocusNode1,
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
                                      hintText: 'Enter your email',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            letterSpacing: 0.0,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 20.0, 0.0, 20.0),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          color: FlutterFlowTheme.of(context)
                                              .black40,
                                          letterSpacing: 0.0,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model
                                        .emailTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.passwordTextController,
                                    focusNode: _model.textFieldFocusNode2,
                                    autofocus: false,
                                    obscureText: !_model.passwordVisibility,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            letterSpacing: 0.0,
                                          ),
                                      hintText: 'Enter your password',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            letterSpacing: 0.0,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              20.0, 20.0, 0.0, 20.0),
                                      suffixIcon: InkWell(
                                        onTap: () => safeSetState(
                                          () => _model.passwordVisibility =
                                              !_model.passwordVisibility,
                                        ),
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          color: FlutterFlowTheme.of(context)
                                              .black40,
                                          letterSpacing: 0.0,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model
                                        .passwordTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 40.0),
                                child: Text(
                                  'Forgot Password?',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 16.0),
                            child: FFButtonWidget(
                              onPressed: () async {
                                // Validate email and password are not empty
                                if (_model.emailTextController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter your email address',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 3000),
                                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                                    ),
                                  );
                                  return;
                                }
                                if (_model.passwordTextController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter your password',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 3000),
                                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                                    ),
                                  );
                                  return;
                                }

                                GoRouter.of(context).prepareAuthEvent();

                                final user = await authManager.signInWithEmail(
                                  context,
                                  _model.emailTextController.text,
                                  _model.passwordTextController.text,
                                );
                                if (user == null) {
                                  return;
                                }

                                // Mark onboarding complete for existing users if needed
                                if (currentUserReference != null) {
                                  final userDoc = await UsersRecord.getDocumentOnce(currentUserReference!);
                                  if (!userDoc.onboardingCompleted) {
                                    await currentUserReference!.update(createUsersRecordData(
                                      onboardingCompleted: true,
                                    ));
                                  }
                                }

                                // Login always goes to home
                                if (!context.mounted) return;
                                context.pushNamedAuth(
                                    HomeHybridWidget.routeName,
                                    context.mounted);
                              },
                              text: 'Login',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 20.0),
                                child: Text(
                                  'Or continue with',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        try {
                                          print('Google Sign-In: Starting sign-in process...');
                                          GoRouter.of(context).prepareAuthEvent();
                                          final user = await authManager
                                              .signInWithGoogle(context);
                                          print('Google Sign-In: User result = ${user?.uid ?? "null"}');
                                          if (user == null) {
                                            print('Google Sign-In: User is null, sign-in cancelled or failed');
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Google Sign-In cancelled or failed. Please try again.'),
                                              ),
                                            );
                                            return;
                                          }

                                          // Mark onboarding complete if needed
                                          final userDoc = await UsersRecord.getDocumentOnce(
                                            UsersRecord.collection.doc(user.uid),
                                          );
                                          if (!userDoc.onboardingCompleted) {
                                            await UsersRecord.collection.doc(user.uid).update(createUsersRecordData(
                                              onboardingCompleted: true,
                                            ));
                                          }

                                          // Login always goes to home
                                          if (!context.mounted) return;
                                          context.goNamedAuth(
                                              HomeHybridWidget.routeName,
                                              context.mounted);
                                        } catch (e) {
                                          print('Google Sign-In Error: $e');
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Google Sign-In error: ${e.toString()}'),
                                            ),
                                          );
                                          return;
                                        }
                                      },
                                      child: Container(
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: const Color(0x6552A097),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 10.0, 10.0, 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 18.0, 0.0),
                                                child: ClipRRect(
                                                  child: Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: const BoxDecoration(),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/Google.png',
                                                        width: 20.0,
                                                        height: 0.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Google',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        try {
                                          print('Apple Sign-In: Starting sign-in process...');
                                          GoRouter.of(context).prepareAuthEvent();
                                          final user = await authManager
                                              .signInWithApple(context);
                                          print('Apple Sign-In: User result = ${user?.uid ?? "null"}');
                                          if (user == null) {
                                            print('Apple Sign-In: User is null, sign-in cancelled or failed');
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Apple Sign-In cancelled or failed. Please try again.'),
                                              ),
                                            );
                                            return;
                                          }

                                          // Mark onboarding complete if needed
                                          final userDoc = await UsersRecord.getDocumentOnce(
                                            UsersRecord.collection.doc(user.uid),
                                          );
                                          if (!userDoc.onboardingCompleted) {
                                            await UsersRecord.collection.doc(user.uid).update(createUsersRecordData(
                                              onboardingCompleted: true,
                                            ));
                                          }

                                          // Login always goes to home
                                          if (!context.mounted) return;
                                          context.goNamedAuth(
                                              HomeHybridWidget.routeName,
                                              context.mounted);
                                        } catch (e) {
                                          print('Apple Sign-In Error: $e');
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Apple Sign-In error: ${e.toString()}'),
                                            ),
                                          );
                                          return;
                                        }
                                      },
                                      child: Container(
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: const Color(0x6552A097),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  10.0, 10.0, 10.0, 10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 0.0, 18.0, 0.0),
                                                child: ClipRRect(
                                                  child: Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration: const BoxDecoration(),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/Vector.png',
                                                        width: 20.0,
                                                        height: 0.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Apple',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Andika New Basic',
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 27.0, 0.0, 0.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Don’t have an account? ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Andika New Basic',
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      TextSpan(
                                        text: 'Create Account',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                        mouseCursor: SystemMouseCursors.click,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            context.pushNamed(
                                                SignUpv2Widget.routeName);
                                          },
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Andika New Basic',
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 40.0, 0.0, 20.0),
                            child: Center(
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'By continuing, you agree to our ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Andika New Basic',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Andika New Basic',
                                        color: const Color(0x8F000000),
                                        fontSize: 12.0,
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
                ),
        ),
      ),
    );
  }
}
