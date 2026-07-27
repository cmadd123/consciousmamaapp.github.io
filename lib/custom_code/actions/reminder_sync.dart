import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'notification_service.dart';

/// Query the user's recurring to-dos + routines and (re)schedule their local
/// reminders according to the current per-module notification settings.
///
/// Weekly local notifications persist across launches, so calling this on app
/// start (after login) and after saving notification settings keeps them in
/// sync with the latest recurring items without per-mutation wiring.
Future<void> resyncRecurringReminders() async {
  if (currentUserReference == null) return;
  try {
    final todos = await queryTodoRecordOnce(
      queryBuilder: (q) =>
          q.where('user_ref', isEqualTo: currentUserReference),
    );
    final routines = await queryRoutinesRecordOnce(
      queryBuilder: (q) =>
          q.where('user_ref', isEqualTo: currentUserReference),
    );

    final todoItems = todos
        .where((t) => t.hasRecurDays())
        .map((t) => <String, dynamic>{
              'id': t.reference.id,
              'title': t.title,
              'days': t.recurDays,
            })
        .toList();
    final routineItems = routines
        .where((r) => r.hasRecurDays())
        .map((r) => <String, dynamic>{
              'id': r.reference.id,
              'title': r.name,
              'days': r.recurDays,
            })
        .toList();

    await notificationService.syncRecurringReminders(
        routine: false, items: todoItems);
    await notificationService.syncRecurringReminders(
        routine: true, items: routineItems);
  } catch (_) {
    // Best-effort — never block launch/settings on reminder scheduling.
  }
}
