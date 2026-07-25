import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '/auth/firebase_auth/auth_util.dart';

/// TEMPORARY in-app "note mode" for beta reviewers only (Collin + Haley).
/// A floating button opens an inline note panel; the note captures the
/// current route + who + when and saves to the Firestore `feedback`
/// collection. Compile the notes with the `feedbackMarkdown` function.
///
/// Renders the child untouched for everyone else. Self-contained (its own
/// inline panel, no showDialog) so it can live at the MaterialApp.router
/// builder level, above the app's Navigator. Remove before GA.
class AnnotationOverlay extends StatefulWidget {
  final Widget child;
  const AnnotationOverlay({super.key, required this.child});

  // Reviewers who see the note button. Lowercase.
  static const Set<String> reviewers = {
    'collinjmaddox@gmail.com',
    'haley.hostetter@gmail.com',
    'haleyjmaddox@gmail.com',
  };

  @override
  State<AnnotationOverlay> createState() => _AnnotationOverlayState();
}

class _AnnotationOverlayState extends State<AnnotationOverlay> {
  final _controller = TextEditingController();
  bool _open = false;
  bool _saving = false;
  String _flash = '';

  bool get _isReviewer =>
      AnnotationOverlay.reviewers.contains(currentUserEmail.toLowerCase());

  String _currentRoute() {
    try {
      return GoRouter.of(context)
          .routerDelegate
          .currentConfiguration
          .uri
          .toString();
    } catch (_) {
      return '';
    }
  }

  Future<void> _save() async {
    final note = _controller.text.trim();
    if (note.isEmpty) return;
    setState(() => _saving = true);
    final route = _currentRoute();
    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'note': note,
        'route': route,
        'email': currentUserEmail,
        'status': 'open',
        'created_at': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      if (mounted) {
        setState(() {
          _saving = false;
          _open = false;
          _flash = 'Note saved 📝';
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _flash = '');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _flash = "Couldn't save";
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReviewer) return widget.child;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          // Note panel
          if (_open)
            Positioned(
              left: 12,
              right: 12,
              bottom: 150,
              child: SafeArea(
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Note · ${_currentRoute().isEmpty ? "this screen" : _currentRoute()}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "What's wrong / what to change here?",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => setState(() => _open = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: _saving ? null : _save,
                              child: Text(_saving ? 'Saving…' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Flash confirmation
          if (_flash.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 130,
              child: SafeArea(
                child: Center(
                  child: Material(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(_flash,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          // Floating note button
          Positioned(
            right: 14,
            bottom: 96,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: FloatingActionButton.small(
                  heroTag: 'annotate_fab',
                  backgroundColor: Colors.deepPurple.withOpacity(0.9),
                  onPressed: () => setState(() => _open = !_open),
                  child: Icon(_open ? Icons.close : Icons.edit_note,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
