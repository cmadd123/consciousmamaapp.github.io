/// Shared recurrence helpers for todos and routines.
///
/// Recurrence model (see CreatorThemeEditor decisions): repeat on specific
/// weekdays (1=Mon..7=Sun), optionally every N weeks. An empty day list means
/// the item is one-time (todos) or "shows every day" (legacy routines).

const List<String> kWeekdayShort = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
];

/// Format a date as YYYY-MM-DD (local).
String ymdString(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? parseYmd(String? s) {
  if (s == null || s.isEmpty) return null;
  final parts = s.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

DateTime _mondayOf(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

/// Whether a recurring item is active on [date], given its weekdays, the
/// every-N-weeks interval, and the anchor date the interval counts from.
bool recursOnDate(
  List<int> recurDays,
  int intervalWeeks,
  String anchor,
  DateTime date,
) {
  if (recurDays.isEmpty) return false;
  if (!recurDays.contains(date.weekday)) return false;
  final interval = intervalWeeks < 1 ? 1 : intervalWeeks;
  if (interval == 1) return true;
  final anchorDate = parseYmd(anchor) ?? date;
  final weeks =
      (_mondayOf(date).difference(_mondayOf(anchorDate)).inDays / 7).round();
  return weeks % interval == 0;
}

/// Human label for a recurrence, e.g. "Weekdays", "Every day", "Mon, Wed",
/// "Every 2 wks · Tue". Returns '' for one-time items.
String recurrenceLabel(List<int> recurDays, int intervalWeeks) {
  if (recurDays.isEmpty) return '';
  final days = [...recurDays]..sort();
  final interval = intervalWeeks < 1 ? 1 : intervalWeeks;
  final prefix = interval > 1 ? 'Every $interval wks · ' : '';

  String base;
  if (_setEquals(days, const [1, 2, 3, 4, 5])) {
    base = 'Weekdays';
  } else if (_setEquals(days, const [6, 7])) {
    base = 'Weekends';
  } else if (days.length == 7) {
    base = 'Every day';
  } else {
    base = days.map((d) => kWeekdayShort[d - 1]).join(', ');
  }
  return '$prefix$base';
}

bool _setEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
