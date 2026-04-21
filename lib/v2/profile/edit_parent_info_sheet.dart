import '/auth/firebase_auth/auth_util.dart';
import '/app_state.dart';
import '/backend/backend.dart';
import '/components/momrise_confirmation.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/v2/auth/parent_setup_enhanced_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full page for editing parent names and colors post-onboarding.
/// Reuses the same 10-color palette from ParentSetupEnhancedModel.
class EditParentInfoPage extends StatefulWidget {
  const EditParentInfoPage({super.key});

  static String routeName = 'EditParentInfo';
  static String routePath = '/edit-parent-info';

  @override
  State<EditParentInfoPage> createState() => _EditParentInfoPageState();
}

class _EditParentInfoPageState extends State<EditParentInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _myNameController;
  late TextEditingController _partnerNameController;
  late Color _myColor;
  late Color _partnerColor;

  @override
  void initState() {
    super.initState();
    final user = currentUserDocument;
    _myNameController = TextEditingController(
      text: user?.myName ?? 'Me',
    );
    _partnerNameController = TextEditingController(
      text: user?.partnerName ?? '',
    );
    _myColor = Color(user?.myColor ?? 0xFFEC407A);
    _partnerColor = Color(user?.partnerColor ?? 0xFF1976D2);
  }

  @override
  void dispose() {
    _myNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  /// Performs the Firestore write only. The AnimatedSaveButton handles
  /// spinner, success animation, haptic, and calling onComplete.
  Future<void> _saveToFirestore() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      throw Exception('Validation failed');
    }

    await currentUserReference?.update(createUsersRecordData(
      myName: _myNameController.text.trim(),
      myColor: _myColor.value,
      partnerName: _partnerNameController.text.trim().isNotEmpty
          ? _partnerNameController.text.trim()
          : null,
      partnerColor: _partnerColor.value,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
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
            ),

            // Scrollable content
            SafeArea(
              child: Column(
                children: [
                  // Scroll area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Edit Parent Info',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                fontFamily: FFAppState().currentFontFamily,
                                fontSize: 28.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Update names and colors for you and your husband. These appear throughout the app.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: FFAppState().currentFontFamily,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                            ),
                            const SizedBox(height: 32.0),

                            // --- You section ---
                            _buildSection(
                              context,
                              title: 'You',
                              subtitle: 'What should we call you?',
                              controller: _myNameController,
                              hint: 'Your name or nickname',
                              selectedColor: _myColor,
                              onColorSelected: (c) {
                                HapticFeedback.lightImpact();
                                setState(() => _myColor = c);
                              },
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              initial: _myNameController.text.isNotEmpty
                                  ? _myNameController.text[0].toUpperCase()
                                  : 'M',
                            ),
                            const SizedBox(height: 20.0),

                            // --- Husband section ---
                            _buildSection(
                              context,
                              title: 'Your Husband (Optional)',
                              subtitle: 'What should we call him?',
                              controller: _partnerNameController,
                              hint: "Husband's name or nickname",
                              selectedColor: _partnerColor,
                              onColorSelected: (c) {
                                HapticFeedback.lightImpact();
                                setState(() => _partnerColor = c);
                              },
                              validator: (_) => null,
                              initial: _partnerNameController.text.isNotEmpty
                                  ? _partnerNameController.text[0].toUpperCase()
                                  : 'H',
                            ),
                            const SizedBox(height: 100.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed save button at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24.0,
                  12.0,
                  24.0,
                  MediaQuery.of(context).padding.bottom + 12.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9E1).withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: FFButtonWidget(
                    onPressed: () async {
                      try {
                        await _saveToFirestore();
                        if (context.mounted) {
                          // Dismiss keyboard and let it animate away before showing confirmation
                          FocusScope.of(context).unfocus();
                          await Future.delayed(const Duration(milliseconds: 300));
                        }
                        if (context.mounted) {
                          await MomRiseConfirmation.show(context, message: 'Saved');
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (_) {
                        // Validation failed — form shows inline errors
                      }
                    },
                    text: 'Save',
                    options: FFButtonOptions(
                      height: 56.0,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: FFAppState().currentFontFamily,
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
              ),
            ),

            // Floating back arrow
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.0,
              left: 8.0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24.0),
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required Color selectedColor,
    required ValueChanged<Color> onColorSelected,
    required String? Function(String?) validator,
    required String initial,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: circle + title/subtitle
          Row(
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: selectedColor.withValues(alpha: 0.4),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: FFAppState().currentFontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: FFAppState().currentFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: FFAppState().currentFontFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Name input
          TextFormField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FFAppState().currentFontFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontFamily: FFAppState().currentFontFamily,
              fontSize: 16.0,
              letterSpacing: 0.0,
            ),
            validator: validator,
          ),
          const SizedBox(height: 16.0),

          // Color label
          Text(
            'Pick a color',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FFAppState().currentFontFamily,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 12.0),

          // Color palette
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: ParentSetupEnhancedModel.colorPalette.map((color) {
              final isSelected = selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12.0),
                    border: isSelected
                        ? Border.all(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.5,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 22.0,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
