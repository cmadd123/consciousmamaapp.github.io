import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'childen_edit_pop_up_c_model.dart';
export 'childen_edit_pop_up_c_model.dart';

class ChildenEditPopUpCWidget extends StatefulWidget {
  const ChildenEditPopUpCWidget({
    super.key,
    required this.childRow,
  });

  final ChildernRecord? childRow;

  @override
  State<ChildenEditPopUpCWidget> createState() =>
      _ChildenEditPopUpCWidgetState();
}

class _ChildenEditPopUpCWidgetState extends State<ChildenEditPopUpCWidget> {
  late ChildenEditPopUpCModel _model;
  String? _newAvatarUrl;
  bool _isUploadingImage = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChildenEditPopUpCModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.selectedAvtar = widget!.childRow?.avatar;
      _newAvatarUrl = widget!.childRow?.avatar;
      safeSetState(() {});
    });

    _model.textController ??=
        TextEditingController(text: widget!.childRow?.name);
    _model.textFieldFocusNode ??= FocusNode();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final selectedMedia = await selectMediaWithSourceBottomSheet(
        context: context,
        allowPhoto: true,
        allowVideo: false,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (selectedMedia != null && selectedMedia.isNotEmpty) {
        final file = selectedMedia.first;
        final downloadUrl = await uploadData(
          'users/$currentUserUid/children/${widget.childRow?.reference.id}/avatar.${file.storagePath.split('.').last}',
          file.bytes,
        );

        if (downloadUrl != null) {
          setState(() => _newAvatarUrl = downloadUrl);
        }
      }
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Widget _buildInitialAvatar() {
    final name = widget.childRow?.name ?? '';
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: 500.0,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: Form(
        key: _model.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 0.0),
                    child: Text(
                      'Edit Child Details',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Andika New Basic',
                                letterSpacing: 0.0,
                              ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Text(
                    'Enter your child details below to update.',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Andika New Basic',
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                // Avatar picker
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: InkWell(
                    onTap: _isUploadingImage ? null : _pickAndUploadImage,
                    borderRadius: BorderRadius.circular(50.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: widget.childRow?.selectedColor ??
                                FlutterFlowTheme.of(context).primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 3.0,
                            ),
                          ),
                          child: _newAvatarUrl != null && _newAvatarUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _newAvatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 100.0,
                                    height: 100.0,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildInitialAvatar(),
                                  ),
                                )
                              : _buildInitialAvatar(),
                        ),
                        if (_isUploadingImage)
                          Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: 2.0,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Tap to change photo',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                  child: Container(
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
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                        hintText: 'Name',
                        hintStyle: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                              fontFamily: 'Andika New Basic',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(27.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
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
                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 25.0, 0.0, 25.0),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                      cursorColor: FlutterFlowTheme.of(context).primaryText,
                      validator:
                          _model.textControllerValidator.asValidator(context),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    // Date-PickerAction
                    final _datePickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          (widget!.childRow?.birthDay ?? DateTime.now()),
                      firstDate: DateTime(1900),
                      lastDate: (widget!.childRow?.birthDay ?? DateTime.now()),
                      builder: (context, child) {
                        return wrapInMaterialDatePickerTheme(
                          context,
                          child!,
                          headerBackgroundColor:
                              FlutterFlowTheme.of(context).primary,
                          headerForegroundColor:
                              FlutterFlowTheme.of(context).info,
                          headerTextStyle: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                                fontFamily: 'Andika New Basic',
                                fontSize: 32.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                          pickerBackgroundColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          pickerForegroundColor:
                              FlutterFlowTheme.of(context).primaryText,
                          selectedDateTimeBackgroundColor:
                              FlutterFlowTheme.of(context).primary,
                          selectedDateTimeForegroundColor:
                              FlutterFlowTheme.of(context).info,
                          actionButtonForegroundColor:
                              FlutterFlowTheme.of(context).primaryText,
                          iconSize: 24.0,
                        );
                      },
                    );

                    if (_datePickedDate != null) {
                      safeSetState(() {
                        _model.datePicked = DateTime(
                          _datePickedDate.year,
                          _datePickedDate.month,
                          _datePickedDate.day,
                        );
                      });
                    } else if (_model.datePicked != null) {
                      safeSetState(() {
                        _model.datePicked = widget!.childRow?.birthDay;
                      });
                    }
                    _model.datepickerValue = _model.datePicked;
                    safeSetState(() {});
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          FlutterFlowTheme.of(context).formTextFiledBackGround,
                      borderRadius: BorderRadius.circular(27.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 16.0, 20.0, 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                valueOrDefault<String>(
                                  () {
                                    if ((widget!.childRow?.birthDay != null) &&
                                        (_model.datepickerValue == null)) {
                                      return dateTimeFormat(
                                        "yMMMd",
                                        widget!.childRow?.birthDay,
                                        locale: FFLocalizations.of(context)
                                            .languageCode,
                                      );
                                    } else if (_model.datepickerValue != null) {
                                      return _model.datePicked?.toString();
                                    } else {
                                      return 'Birth Day';
                                    }
                                  }(),
                                  '- -',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Andika New Basic',
                                      color:
                                          FlutterFlowTheme.of(context).black60,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 40.0, 0.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          text: 'Cancel',
                          options: FFButtonOptions(
                            height: 49.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0x0052A097),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Andika New Basic',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              return;
                            }

                            await widget!.childRow!.reference
                                .update(createChildernRecordData(
                              name: _model.textController.text,
                              birthDay: _model.datePicked != null
                                  ? _model.datePicked
                                  : widget!.childRow?.birthDay,
                              avatar: _newAvatarUrl,
                            ));
                            FFAppState().editing =
                                !(FFAppState().editing ?? true);
                            _model.updatePage(() {});
                            FFAppState().clearChildrenCache();
                            FFAppState().activityFinalModel = [];
                            safeSetState(() {});
                            Navigator.pop(context);
                          },
                          text: 'Update',
                          options: FFButtonOptions(
                            height: 49.0,
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
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 20.0)),
                  ),
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ),
      ),
    );
  }
}
