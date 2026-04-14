import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/creator_service.dart';
import 'creator_theme_notifier.dart';

/// Preset theme palettes for creators to choose from
class _ThemePreset {
  final String name;
  final Color primary;
  final Color accent;
  final Color gradStart;
  final Color gradEnd;
  final Color iconColor;

  const _ThemePreset({
    required this.name,
    required this.primary,
    required this.accent,
    required this.gradStart,
    required this.gradEnd,
    required this.iconColor,
  });
}

const _presets = [
  _ThemePreset(name: 'Default', primary: Color(0xFF52A097), accent: Color(0xFFEE8B60), gradStart: Color(0xFFD7F2EB), gradEnd: Color(0xFFFFE9E1), iconColor: Color(0xFF52A097)),
  _ThemePreset(name: 'Rose', primary: Color(0xFFE91E63), accent: Color(0xFFAD1457), gradStart: Color(0xFFFCE4EC), gradEnd: Color(0xFFF3E5F5), iconColor: Color(0xFFE91E63)),
  _ThemePreset(name: 'Ocean', primary: Color(0xFF0288D1), accent: Color(0xFF00BCD4), gradStart: Color(0xFFE1F5FE), gradEnd: Color(0xFFE0F7FA), iconColor: Color(0xFF0288D1)),
  _ThemePreset(name: 'Forest', primary: Color(0xFF2E7D32), accent: Color(0xFF8BC34A), gradStart: Color(0xFFE8F5E9), gradEnd: Color(0xFFF1F8E9), iconColor: Color(0xFF2E7D32)),
  _ThemePreset(name: 'Sunset', primary: Color(0xFFFF5722), accent: Color(0xFFFF9800), gradStart: Color(0xFFFFF3E0), gradEnd: Color(0xFFFFEBEE), iconColor: Color(0xFFFF5722)),
  _ThemePreset(name: 'Lavender', primary: Color(0xFF7B1FA2), accent: Color(0xFFE040FB), gradStart: Color(0xFFF3E5F5), gradEnd: Color(0xFFEDE7F6), iconColor: Color(0xFF7B1FA2)),
  _ThemePreset(name: 'Midnight', primary: Color(0xFF283593), accent: Color(0xFF5C6BC0), gradStart: Color(0xFFE8EAF6), gradEnd: Color(0xFFE3F2FD), iconColor: Color(0xFF283593)),
  _ThemePreset(name: 'Peach', primary: Color(0xFFE64A19), accent: Color(0xFFFF8A65), gradStart: Color(0xFFFBE9E7), gradEnd: Color(0xFFFFF8E1), iconColor: Color(0xFFE64A19)),
  _ThemePreset(name: 'Sage', primary: Color(0xFF607D8B), accent: Color(0xFF78909C), gradStart: Color(0xFFECEFF1), gradEnd: Color(0xFFE8F5E9), iconColor: Color(0xFF607D8B)),
  _ThemePreset(name: 'Berry', primary: Color(0xFF880E4F), accent: Color(0xFFC2185B), gradStart: Color(0xFFFCE4EC), gradEnd: Color(0xFFF8BBD0), iconColor: Color(0xFF880E4F)),
];

class CreatorThemeEditorWidget extends StatefulWidget {
  final CreatorsRecord creator;

  const CreatorThemeEditorWidget({super.key, required this.creator});

  static String routeName = 'CreatorThemeEditor';

  @override
  State<CreatorThemeEditorWidget> createState() => _CreatorThemeEditorWidgetState();
}

class _CreatorThemeEditorWidgetState extends State<CreatorThemeEditorWidget> {
  late Color _primary;
  late Color _accent;
  late Color _gradStart;
  late Color _gradEnd;
  late Color _iconColor;
  bool _useGradient = true;
  bool _isSaving = false;
  String? _editingColor; // Which color is being edited (null = none)

  @override
  void initState() {
    super.initState();
    _primary = parseHexColor(widget.creator.themePrimary) ?? const Color(0xFF52A097);
    _accent = parseHexColor(widget.creator.themeAccent) ?? const Color(0xFFEE8B60);
    _gradStart = parseHexColor(widget.creator.themeBackgroundGradientStart) ?? const Color(0xFFD7F2EB);
    _gradEnd = parseHexColor(widget.creator.themeBackgroundGradientEnd) ?? const Color(0xFFFFE9E1);
    _iconColor = parseHexColor(widget.creator.themeIconColor) ?? const Color(0xFF52A097);
    _useGradient = _gradStart != _gradEnd;
  }

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await widget.creator.reference.update({
        'theme_primary': _colorToHex(_primary),
        'theme_accent': _colorToHex(_accent),
        'theme_background_gradient_start': _colorToHex(_gradStart),
        'theme_background_gradient_end': _useGradient ? _colorToHex(_gradEnd) : _colorToHex(_gradStart),
        'theme_icon_color': _colorToHex(_iconColor),
      });

      // Update the theme notifier
      if (mounted) {
        final themeNotifier = Provider.of<CreatorThemeNotifier>(context, listen: false);
        await themeNotifier.loadActiveCreator();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Theme saved! Your followers will see these colors.'),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _applyPreset(_ThemePreset preset) {
    HapticFeedback.lightImpact();
    setState(() {
      _primary = preset.primary;
      _accent = preset.accent;
      _gradStart = preset.gradStart;
      _gradEnd = preset.gradEnd;
      _iconColor = preset.iconColor;
      _useGradient = true;
      _editingColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: FlutterFlowTheme.of(context).primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize Theme',
          style: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: 'Andika New Basic',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                _isSaving ? 'Saving...' : 'Save',
                style: TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, size: 18, color: _primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap any colored element in the preview to change it. Your followers see these colors.',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Andika New Basic',
                        color: _primary,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Presets
            Text('Presets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const SizedBox(height: 8),
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presets.length,
                itemBuilder: (context, i) {
                  final preset = _presets[i];
                  return GestureDetector(
                    onTap: () => _applyPreset(preset),
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [preset.gradStart, preset.gradEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: preset.primary.withOpacity(0.4), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: preset.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Background toggle
            Row(
              children: [
                Text('Background', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _useGradient = false;
                          _gradEnd = _gradStart;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: !_useGradient ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_useGradient ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)] : null,
                          ),
                          child: Text('Solid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: !_useGradient ? Colors.grey[800] : Colors.grey[500])),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _useGradient = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _useGradient ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _useGradient ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)] : null,
                          ),
                          child: Text('Gradient', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _useGradient ? Colors.grey[800] : Colors.grey[500])),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive preview
            _buildInteractivePreview(),

            const SizedBox(height: 20),

            // Color picker (shows when editing)
            if (_editingColor != null) ...[
              _buildColorPicker(),
              const SizedBox(height: 16),
            ],

            // Reset button
            Center(
              child: TextButton.icon(
                onPressed: () => _applyPreset(_presets[0]),
                icon: Icon(Icons.refresh, size: 16, color: Colors.grey[500]),
                label: Text('Reset to Default', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Interactive preview — tap elements to edit their color
  Widget _buildInteractivePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradStart, _useGradient ? _gradEnd : _gradStart],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tappable background label
              GestureDetector(
                onTap: () => setState(() => _editingColor = _useGradient ? 'gradStart' : 'gradStart'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: _editingColor == 'gradStart' || _editingColor == 'gradEnd'
                        ? Border.all(color: _primary, width: 2)
                        : null,
                  ),
                  child: Text(
                    _useGradient ? '↕ Tap to edit background gradient' : '● Tap to edit background',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Greeting
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Good morning, Sarah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF5D4E60))),
              ),
              const SizedBox(height: 12),

              // Meals card — tap to edit PRIMARY
              GestureDetector(
                onTap: () => setState(() => _editingColor = 'primary'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    border: _editingColor == 'primary' ? Border.all(color: _primary, width: 2) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu_rounded, color: _iconColor, size: 18),
                          const SizedBox(width: 6),
                          Text("Today's Meals", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5D4E60))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('PRIMARY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: _primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final meal in ['Breakfast · Overnight Oats', 'Lunch · Turkey Wraps', 'Dinner · Chicken Stir Fry'])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(width: 4, height: 20, decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(2))),
                              const SizedBox(width: 8),
                              Text(meal, style: const TextStyle(fontSize: 12, color: Color(0xFF5D4E60))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Events card — tap to edit ACCENT
              GestureDetector(
                onTap: () => setState(() => _editingColor = 'accent'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    border: _editingColor == 'accent' ? Border.all(color: _accent, width: 2) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: _iconColor, size: 18),
                          const SizedBox(width: 6),
                          Text("Today's Events", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5D4E60))),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('ACCENT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: _accent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            const Text('Soccer Practice · 4:00 PM', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Icon color row — tap to edit ICON COLOR
              GestureDetector(
                onTap: () => setState(() => _editingColor = 'iconColor'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    border: _editingColor == 'iconColor' ? Border.all(color: _iconColor, width: 2) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu_rounded, color: _iconColor, size: 18),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_today_rounded, color: _iconColor, size: 18),
                      const SizedBox(width: 8),
                      Icon(Icons.auto_stories_rounded, color: _iconColor, size: 18),
                      const SizedBox(width: 8),
                      Icon(Icons.home_rounded, color: _iconColor, size: 18),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('ICONS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: _iconColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Color picker for the currently editing color
  Widget _buildColorPicker() {
    final Color currentColor;
    final String label;

    switch (_editingColor) {
      case 'primary':
        currentColor = _primary;
        label = 'Primary Color — buttons, bars, active states';
        break;
      case 'accent':
        currentColor = _accent;
        label = 'Accent Color — events, emphasis, highlights';
        break;
      case 'gradStart':
        currentColor = _gradStart;
        label = _useGradient ? 'Background Top' : 'Background Color';
        break;
      case 'gradEnd':
        currentColor = _gradEnd;
        label = 'Background Bottom';
        break;
      case 'iconColor':
        currentColor = _iconColor;
        label = 'Icon Color — nav bar, card icons';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 24, height: 24, decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: currentColor.withOpacity(0.3), blurRadius: 6)])),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              ),
              if (_useGradient && _editingColor == 'gradStart')
                GestureDetector(
                  onTap: () => setState(() => _editingColor = 'gradEnd'),
                  child: Text('Bottom →', style: TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.w600)),
                ),
              if (_editingColor == 'gradEnd')
                GestureDetector(
                  onTap: () => setState(() => _editingColor = 'gradStart'),
                  child: Text('← Top', style: TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Color grid — common colors
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Row of common colors
              ..._colorOptions.map((color) => _buildColorDot(color, currentColor)),
            ],
          ),

          const SizedBox(height: 12),

          // Hue slider
          _buildHueSlider(currentColor),
        ],
      ),
    );
  }

  static const _colorOptions = [
    Color(0xFF52A097), Color(0xFF2E7D32), Color(0xFF0288D1), Color(0xFF283593),
    Color(0xFF7B1FA2), Color(0xFFE91E63), Color(0xFFFF5722), Color(0xFFFF9800),
    Color(0xFF795548), Color(0xFF607D8B), Color(0xFF880E4F), Color(0xFFAD1457),
    Color(0xFF00BCD4), Color(0xFF8BC34A), Color(0xFFFFC107), Color(0xFF9C27B0),
    // Light colors (for backgrounds)
    Color(0xFFD7F2EB), Color(0xFFFFE9E1), Color(0xFFFCE4EC), Color(0xFFF3E5F5),
    Color(0xFFE1F5FE), Color(0xFFE8F5E9), Color(0xFFFFF3E0), Color(0xFFEDE7F6),
    Color(0xFFF5F5F5), Color(0xFFECEFF1), Color(0xFFFFF8E1), Color(0xFFE0F7FA),
  ];

  Widget _buildColorDot(Color color, Color selectedColor) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          switch (_editingColor) {
            case 'primary': _primary = color; break;
            case 'accent': _accent = color; break;
            case 'gradStart': _gradStart = color; if (!_useGradient) _gradEnd = color; break;
            case 'gradEnd': _gradEnd = color; break;
            case 'iconColor': _iconColor = color; break;
          }
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)],
        ),
        child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildHueSlider(Color currentColor) {
    final hsl = HSLColor.fromColor(currentColor);
    return Column(
      children: [
        // Hue
        Row(
          children: [
            Text('Hue', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: hsl.hue,
                  min: 0,
                  max: 360,
                  activeColor: currentColor,
                  onChanged: (v) {
                    final newColor = hsl.withHue(v).toColor();
                    setState(() {
                      switch (_editingColor) {
                        case 'primary': _primary = newColor; break;
                        case 'accent': _accent = newColor; break;
                        case 'gradStart': _gradStart = newColor; if (!_useGradient) _gradEnd = newColor; break;
                        case 'gradEnd': _gradEnd = newColor; break;
                        case 'iconColor': _iconColor = newColor; break;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        // Lightness
        Row(
          children: [
            Text('Light', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: hsl.lightness,
                  min: 0.1,
                  max: 0.95,
                  activeColor: currentColor,
                  onChanged: (v) {
                    final newColor = hsl.withLightness(v).toColor();
                    setState(() {
                      switch (_editingColor) {
                        case 'primary': _primary = newColor; break;
                        case 'accent': _accent = newColor; break;
                        case 'gradStart': _gradStart = newColor; if (!_useGradient) _gradEnd = newColor; break;
                        case 'gradEnd': _gradEnd = newColor; break;
                        case 'iconColor': _iconColor = newColor; break;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
