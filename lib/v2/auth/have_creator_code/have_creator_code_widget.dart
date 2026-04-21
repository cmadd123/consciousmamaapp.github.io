import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/backend.dart';
import '/custom_code/actions/creator_service.dart';
import '/v2/creator/creator_theme_notifier.dart';
import '/index.dart';

/// Onboarding step: "Did a creator recommend MomRise?"
///
/// Shown right after sign-up, before the paywall. Lets the user enter a
/// creator's code so the first paid invoice attributes to that creator.
/// Skippable — most users won't have a code.
class HaveCreatorCodeWidget extends StatefulWidget {
  const HaveCreatorCodeWidget({super.key});

  static String routeName = 'HaveCreatorCode';
  static String routePath = '/have-creator-code';

  @override
  State<HaveCreatorCodeWidget> createState() => _HaveCreatorCodeWidgetState();
}

class _HaveCreatorCodeWidgetState extends State<HaveCreatorCodeWidget>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isValidating = false;
  bool _isActivating = false;
  String? _errorMessage;
  CreatorsRecord? _validatedCreator;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Enter the code to check it');
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
      FocusScope.of(context).unfocus();
      setState(() {
        _validatedCreator = creator;
        _isValidating = false;
      });
    } else {
      setState(() {
        _errorMessage = "We couldn't find that code. Double-check with your creator.";
        _isValidating = false;
      });
    }
  }

  Future<void> _applyAndContinue() async {
    if (_validatedCreator == null) {
      await _validateCode();
      if (_validatedCreator == null) return;
    }

    setState(() => _isActivating = true);
    final ok = await activateCreatorCode(_validatedCreator!);
    if (!mounted) return;

    if (ok) {
      // Sync the theme notifier so the look-and-feel updates immediately
      // the moment they land on the paywall.
      try {
        final notifier = Provider.of<CreatorThemeNotifier>(context, listen: false);
        notifier.setActiveCreator(_validatedCreator!);
      } catch (_) {
        // Notifier not provided in this tree yet; ignore.
      }
    }

    if (!mounted) return;
    _goToPaywall();
  }

  void _goToPaywall() {
    context.goNamed(PaimentCopyWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final creator = _validatedCreator;
    return PopScope(
      canPop: false,
      child: Scaffold(
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF52A097).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFF52A097),
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Did a creator send you here?',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF2A6F67),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.0,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "If a mom recommended MomRise, enter her code to support her. She'll get a share of every month you stay subscribed.",
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF5D4E60),
                            letterSpacing: 0.0,
                          ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    // Code input
                    TextField(
                      controller: _codeController,
                      focusNode: _focusNode,
                      autofocus: false,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      onSubmitted: (_) => _validateCode(),
                      onChanged: (_) {
                        if (_validatedCreator != null || _errorMessage != null) {
                          setState(() {
                            _validatedCreator = null;
                            _errorMessage = null;
                          });
                        }
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        LengthLimitingTextInputFormatter(24),
                      ],
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Andika New Basic',
                            color: const Color(0xFF2A6F67),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Creator code',
                        hintStyle: TextStyle(
                          color: const Color(0xFF5D4E60).withOpacity(0.4),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF52A097), width: 2),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Andika New Basic',
                              color: const Color(0xFFEF4444),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],

                    if (creator != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    creator.name.isNotEmpty
                                        ? creator.name
                                        : 'Creator found',
                                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                                          fontFamily: 'Andika New Basic',
                                          color: const Color(0xFF2A6F67),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  if (creator.bio.isNotEmpty)
                                    Text(
                                      creator.bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            fontFamily: 'Andika New Basic',
                                            color: const Color(0xFF5D4E60),
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Primary action button
                    FFButtonWidget(
                      onPressed: _isValidating || _isActivating
                          ? null
                          : () async {
                              if (creator != null) {
                                await _applyAndContinue();
                              } else {
                                await _validateCode();
                              }
                            },
                      text: _isActivating
                          ? 'Saving…'
                          : _isValidating
                              ? 'Checking…'
                              : (creator != null ? 'Continue with this creator' : 'Check code'),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54.0,
                        padding: EdgeInsets.zero,
                        iconPadding: EdgeInsets.zero,
                        color: const Color(0xFF52A097),
                        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Andika New Basic',
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(27.0),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip link
                    Center(
                      child: TextButton(
                        onPressed: _isValidating || _isActivating ? null : _goToPaywall,
                        child: Text(
                          "I don't have a code — skip",
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Andika New Basic',
                                color: const Color(0xFF5D4E60),
                                decoration: TextDecoration.underline,
                                letterSpacing: 0.0,
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
