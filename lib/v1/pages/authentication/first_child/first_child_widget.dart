import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'first_child_model.dart';
export 'first_child_model.dart';

class FirstChildWidget extends StatefulWidget {
  const FirstChildWidget({
    super.key,
    bool? isFirst,
  }) : isFirst = isFirst ?? true;

  final bool isFirst;

  static String routeName = 'FirstChild';
  static String routePath = '/firstChild';

  @override
  State<FirstChildWidget> createState() => _FirstChildWidgetState();
}

class _FirstChildWidgetState extends State<FirstChildWidget> {
  late FirstChildModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FirstChildModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFECE5E5), Color(0xFFEDFFFD)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, 1.0),
              end: AlignmentDirectional(0, -1.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 50.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(-1.0, 0.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 100.0, 0.0, 0.0),
                      child: ClipOval(
                        child: Container(
                          width: 64.0,
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/image_22.png',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                    child: Text(
                      'Please add your first child details.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            fontSize: 32.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 40.0),
                    child: Text(
                      'Enter your child details.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FFAppState().currentFontFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'Name',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(27.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(27.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(27.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(27.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                                  20.0, 20.0, 20.0, 20.0),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FFAppState().currentFontFamily,
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(27.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 16.0, 20.0, 16.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    _model.isclicked = !_model.isclicked;
                                    safeSetState(() {});
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Select avatar',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: FFAppState().currentFontFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .black60,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_model.isclicked == true)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10.0, 0.0, 10.0, 20.0),
                                  child: StreamBuilder<List<AvatarsRecord>>(
                                    stream: queryAvatarsRecord(),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      List<AvatarsRecord>
                                          wrapAvatarsRecordList =
                                          snapshot.data!;

                                      return Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        runAlignment: WrapAlignment.start,
                                        verticalDirection:
                                            VerticalDirection.down,
                                        clipBehavior: Clip.none,
                                        children: List.generate(
                                            wrapAvatarsRecordList.length,
                                            (wrapIndex) {
                                          final wrapAvatarsRecord =
                                              wrapAvatarsRecordList[wrapIndex];
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              _model.avtarSelected =
                                                  wrapAvatarsRecord
                                                      .reference.id;
                                              _model.selectedAvatarImage =
                                                  wrapAvatarsRecord.photoUrl;
                                              safeSetState(() {});
                                            },
                                            child: Container(
                                              width: 58.0,
                                              height: 58.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0x2A52A097),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: valueOrDefault<Color>(
                                                    _model.selectedAvatarImage ==
                                                            wrapAvatarsRecord
                                                                .photoUrl
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : Colors.transparent,
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                  ),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        5.0, 5.0, 5.0, 5.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  child: Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      shape: BoxShape.rectangle,
                                                      border: Border.all(
                                                        color:
                                                            Colors.transparent,
                                                        width: 0.0,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.network(
                                                        wrapAvatarsRecord
                                                            .photoUrl,
                                                        width: 30.0,
                                                        height: 30.0,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_model.isAvtarSelected == false)
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Text(
                              'Please select an avatar',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    final datePickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: getCurrentTimestamp,
                                      firstDate: DateTime(1900),
                                      lastDate: getCurrentTimestamp,
                                      builder: (context, child) {
                                        return wrapInMaterialDatePickerTheme(
                                          context,
                                          child!,
                                          headerBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          headerForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          headerTextStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineLarge
                                                  .override(
                                                    fontFamily: FFAppState().currentFontFamily,
                                                    fontSize: 32.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                          pickerBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          pickerForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          selectedDateTimeBackgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                          selectedDateTimeForegroundColor:
                                              FlutterFlowTheme.of(context).info,
                                          actionButtonForegroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          iconSize: 24.0,
                                        );
                                      },
                                    );

                                    if (datePickedDate != null) {
                                      safeSetState(() {
                                        _model.datePicked = DateTime(
                                          datePickedDate.year,
                                          datePickedDate.month,
                                          datePickedDate.day,
                                        );
                                      });
                                    }
                                    // Don't reset to current date if user cancels
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(27.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 16.0, 20.0, 16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  _model.datePicked != null
                                                      ? dateTimeFormat(
                                                          "M/d/yy",
                                                          _model.datePicked,
                                                          locale:
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .languageCode,
                                                        )
                                                      : 'Birth date',
                                                  '- -',
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: FFAppState().currentFontFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black60,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(const SizedBox(width: 12.0)),
                          ),
                        ),
                        if (_model.isBirthDaySelected == false)
                          Align(
                            alignment: const AlignmentDirectional(-1.0, 0.0),
                            child: Text(
                              'Please select your child birth date',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select color',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FFAppState().currentFontFamily,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 0.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0x5752A097);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            constraints: const BoxConstraints(
                                              minWidth: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x5752A097),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  _model.selectedCOolor ==
                                                          const Color(0x5752A097)
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText
                                                      : Colors.transparent,
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFCF3E9);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFCF3E9),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: valueOrDefault<Color>(
                                                  _model.selectedCOolor ==
                                                          const Color(0xFFFCF3E9)
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText
                                                      : Colors.transparent,
                                                  Colors.transparent,
                                                ),
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFCE9F7);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            constraints: const BoxConstraints(
                                              minWidth: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFCE9F7),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFCE9F7)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFE9E9FC);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE9E9FC),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFE9E9FC)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFCE9E9);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFCE9E9),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFCE9E9)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.selectedCOolor =
                                                const Color(0xFFFCFBE9);
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFCFBE9),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: _model.selectedCOolor ==
                                                        const Color(0xFFFCFBE9)
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText
                                                    : Colors.transparent,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 5.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (_model.formKey.currentState == null ||
                                  !_model.formKey.currentState!.validate()) {
                                return;
                              }
                              if (_model.avtarSelected != null &&
                                  _model.avtarSelected != '') {
                                var childernRecordReference =
                                    ChildernRecord.collection.doc();
                                await childernRecordReference
                                    .set(createChildernRecordData(
                                  name: _model.textController.text,
                                  birthDay: _model.datePicked,
                                  selectedColor: _model.selectedCOolor,
                                  userRef: currentUserReference,
                                  selectedAvatar: _model.avtarSelected,
                                  avatar: _model.selectedAvatarImage,
                                ));
                                _model.childedDoc =
                                    ChildernRecord.getDocumentFromData(
                                        createChildernRecordData(
                                          name: _model.textController.text,
                                          birthDay: _model.datePicked,
                                          selectedColor:
                                              _model.selectedCOolor,
                                          userRef: currentUserReference,
                                          selectedAvatar:
                                              _model.avtarSelected,
                                          avatar: _model.selectedAvatarImage,
                                        ),
                                        childernRecordReference);

                                await currentUserReference!
                                    .update(createUsersRecordData(
                                  firstChildCreated: true,
                                ));
                                if (widget.isFirst) {
                                  context.pushNamed(
                                    OnBoadrdingFirstWidget.routeName,
                                    queryParameters: {
                                      'childran': serializeParam(
                                        _model.childedDoc?.reference,
                                        ParamType.DocumentReference,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  context.pushNamed(HomePageWidget.routeName);
                                }
                                                            } else {
                                _model.isAvtarSelected = false;
                                safeSetState(() {});
                              }

                              safeSetState(() {});
                            },
                            text: 'Add child',
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
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'By Continuing, you are agree to our ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FFAppState().currentFontFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: FFAppState().currentFontFamily,
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
    );
  }
}
