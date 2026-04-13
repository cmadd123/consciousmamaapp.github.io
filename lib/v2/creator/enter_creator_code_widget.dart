import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/backend.dart';
import '/custom_code/actions/creator_service.dart';
import 'creator_theme_notifier.dart';

/// Bottom sheet for entering a creator code.
/// Shows validation feedback and a preview of the creator's theme before committing.
class EnterCreatorCodeSheet extends StatefulWidget {
  const EnterCreatorCodeSheet({super.key});

  @override
  State<EnterCreatorCodeSheet> createState() => _EnterCreatorCodeSheetState();
}

class _EnterCreatorCodeSheetState extends State<EnterCreatorCodeSheet> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValidating = false;
  bool _isActivating = false;
  String? _errorMessage;
  CreatorsRecord? _validatedCreator;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a code');
      return;
    }

    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _validatedCreator = null;
    });

    final creator = await validateCreatorCode(code);

    if (!mounted) return;

    if (creator != null) {
      setState(() {
        _validatedCreator = creator;
        _isValidating = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Code not found. Check the code and try again.';
        _isValidating = false;
      });
    }
  }

  Future<void> _activateCode() async {
    if (_validatedCreator == null) return;

    setState(() => _isActivating = true);

    final success = await activateCreatorCode(_validatedCreator!);

    if (!mounted) return;

    if (success) {
      // Update the theme notifier
      final themeNotifier = Provider.of<CreatorThemeNotifier>(context, listen: false);
      themeNotifier.setActiveCreator(_validatedCreator);

      HapticFeedback.mediumImpact();
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isActivating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20.0),

          // Title
          Text(
            'Enter Creator Code',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              fontFamily: 'Andika New Basic',
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Get a personalized experience from your favorite creator',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'Andika New Basic',
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 24.0),

          // Code input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.characters,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CODE',
                    hintStyle: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.4),
                      letterSpacing: 2.0,
                    ),
                    filled: true,
                    fillColor: FlutterFlowTheme.of(context).primaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  onSubmitted: (_) => _validateCode(),
                ),
              ),
              const SizedBox(width: 12.0),
              FFButtonWidget(
                onPressed: _isValidating ? null : () => _validateCode(),
                text: _isValidating ? '...' : 'Apply',
                options: FFButtonOptions(
                  height: 52.0,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Andika New Basic',
                    color: Colors.white,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
            ],
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12.0),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: FlutterFlowTheme.of(context).error,
                fontSize: 13.0,
              ),
            ),
          ],

          // Creator preview card (shown after successful validation)
          if (_validatedCreator != null) ...[
            const SizedBox(height: 20.0),
            _buildCreatorPreview(),
            const SizedBox(height: 16.0),
            FFButtonWidget(
              onPressed: _isActivating ? null : () => _activateCode(),
              text: _isActivating ? 'Activating...' : 'Use This Creator\'s Style',
              options: FFButtonOptions(
                width: double.infinity,
                height: 52.0,
                color: parseHexColor(_validatedCreator!.themePrimary) ??
                    FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Andika New Basic',
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ],

          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  /// Preview card showing the creator's name, bio, niche, and theme colors.
  Widget _buildCreatorPreview() {
    final creator = _validatedCreator!;
    final primary = parseHexColor(creator.themePrimary);
    final secondary = parseHexColor(creator.themeSecondary);
    final accent = parseHexColor(creator.themeAccent);
    final gradStart = parseHexColor(creator.themeBackgroundGradientStart);
    final gradEnd = parseHexColor(creator.themeBackgroundGradientEnd);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: (gradStart != null && gradEnd != null)
            ? LinearGradient(
                colors: [gradStart, gradEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: (gradStart == null || gradEnd == null)
            ? (secondary ?? FlutterFlowTheme.of(context).primaryBackground)
            : null,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: primary?.withOpacity(0.3) ?? Colors.grey.shade200,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          // Creator avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: primary ?? FlutterFlowTheme.of(context).primary,
            backgroundImage: creator.hasAvatarUrl()
                ? NetworkImage(creator.avatarUrl)
                : null,
            child: !creator.hasAvatarUrl()
                ? Text(
                    creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12.0),

          // Creator name
          Text(
            creator.name,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: primary ?? FlutterFlowTheme.of(context).primaryText,
            ),
          ),

          // Niche badge
          if (creator.hasNiche()) ...[
            const SizedBox(height: 6.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: (accent ?? primary)?.withOpacity(0.15) ?? Colors.grey.shade100,
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Text(
                creator.niche,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: accent ?? primary ?? FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
          ],

          // Bio
          if (creator.hasBio()) ...[
            const SizedBox(height: 10.0),
            Text(
              creator.bio,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],

          // Theme color swatches
          const SizedBox(height: 14.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (primary != null) _colorSwatch(primary, 'Primary'),
              if (secondary != null) _colorSwatch(secondary, 'Background'),
              if (accent != null) _colorSwatch(accent, 'Accent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorSwatch(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show the enter creator code bottom sheet.
Future<bool?> showEnterCreatorCodeSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const EnterCreatorCodeSheet(),
  );
}
