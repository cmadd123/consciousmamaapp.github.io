import 'package:flutter/material.dart';

/// Confirmation shown before any action that broadcasts content to a
/// creator's followers — publishing a meal plan, saving a theme, or
/// toggling a routine as shared. Returns true only if the creator
/// explicitly confirms.
///
/// Kept dependency-free (Material only) so it can be imported from any
/// widget without pulling in FlutterFlow theme wiring.
Future<bool> confirmShareWithFollowers(
  BuildContext context, {
  required String what,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Share with your followers?'),
      content: Text(
        '$what will be visible to everyone following your creator code.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Share'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
