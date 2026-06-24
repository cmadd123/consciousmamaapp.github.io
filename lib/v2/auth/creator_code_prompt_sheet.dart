import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Creator-code prompt bottom sheet. Two paths:
///   - "I have a code" → inline TextField → submit calls
///     setActiveCreatorCode Cloud Function → success snackbar → close
///   - "Not now" → close immediately
///
/// Used in two places:
///   - welcome_celebration_widget (v1 signup flow)
///   - paiment_copy_widget initState (v2 signup → paywall flow)
///
/// Stateful instead of inline so we can hold controller + loading state
/// cleanly. The parent is responsible for what happens after the sheet
/// closes — the sheet itself only writes active_creator_code via the
/// callable on success.
class CreatorCodePromptSheet extends StatefulWidget {
  const CreatorCodePromptSheet({super.key});

  @override
  State<CreatorCodePromptSheet> createState() => _CreatorCodePromptSheetState();
}

class _CreatorCodePromptSheetState extends State<CreatorCodePromptSheet> {
  final _codeController = TextEditingController();
  bool _showingInput = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 3 || code.length > 20) {
      setState(() => _errorMessage = 'Code must be 3-20 letters or numbers.');
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('setActiveCreatorCode');
      final response = await callable.call({'code': code});
      final data = Map<String, dynamic>.from(response.data as Map);
      final creatorName = data['creator_name'] as String? ?? 'the creator';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Thanks — $creatorName will get credit when you subscribe.",
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          duration: const Duration(seconds: 4),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _submitting = false;
        _errorMessage = e.message ?? "We couldn't apply that code.";
      });
    } catch (_) {
      setState(() {
        _submitting = false;
        _errorMessage = "Couldn't apply the code. Try again in a moment.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Did a creator share MomRise with you?',
                  style: theme.bodyMedium.override(
                    fontFamily: 'Andika New Basic',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Enter their code and they'll earn a share of your subscription. Totally optional — it doesn't change your price.",
            style: theme.bodySmall.override(
              fontFamily: 'Andika New Basic',
              color: theme.secondaryText,
              fontSize: 13.5,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20),
          if (!_showingInput) ...[
            FilledButton(
              onPressed: () => setState(() => _showingInput = true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'I have a code',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Not now',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: theme.secondaryText,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 20,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              style: theme.bodyLarge.override(
                fontFamily: 'Andika New Basic',
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: TextStyle(
                  color: theme.secondaryText.withOpacity(0.4),
                  letterSpacing: 4.0,
                ),
                filled: true,
                fillColor: theme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
                errorText: _errorMessage,
                errorMaxLines: 2,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Apply code',
                      style: theme.bodyMedium.override(
                        fontFamily: 'Andika New Basic',
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _submitting ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'Skip',
                style: theme.bodyMedium.override(
                  fontFamily: 'Andika New Basic',
                  color: theme.secondaryText,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
