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
      // Dismiss keyboard so preview isn't cut off
      FocusScope.of(context).unfocus();
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewPadding.bottom + MediaQuery.of(context).viewInsets.bottom + 24.0,
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
      ),
    );
  }

  /// Preview — mini app mockup matching the website preview
  Widget _buildCreatorPreview() {
    final creator = _validatedCreator!;
    final primary = parseHexColor(creator.themePrimary) ?? FlutterFlowTheme.of(context).primary;
    final accent = parseHexColor(creator.themeAccent) ?? FlutterFlowTheme.of(context).tertiary;
    final gradStart = parseHexColor(creator.themeBackgroundGradientStart) ?? const Color(0xFFD7F2EB);
    final gradEnd = parseHexColor(creator.themeBackgroundGradientEnd) ?? const Color(0xFFFFE9E1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradStart, gradEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: primary.withOpacity(0.2), width: 2.0),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          // Creator info row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary,
                child: Text(
                  creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(creator.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF5D4E60))),
                    if (creator.hasNiche())
                      Text(creator.niche, style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mini meals card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_menu_rounded, color: primary, size: 16),
                    const SizedBox(width: 6),
                    Text("Today's Meals", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5D4E60))),
                  ],
                ),
                const SizedBox(height: 8),
                // Meal rows
                for (final meal in ['Breakfast · Overnight Oats', 'Lunch · Turkey Wraps', 'Dinner · Chicken Stir Fry'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(width: 3, height: 16, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text(meal, style: const TextStyle(fontSize: 10, color: Color(0xFF5D4E60))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Mini event card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: primary, size: 16),
                const SizedBox(width: 6),
                Text("Today's Events", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5D4E60))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Soccer 4pm', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ],
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
