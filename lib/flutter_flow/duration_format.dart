/// Formats a cook/prep time (stored as total minutes) into a human string
/// that rolls long times up into hours: 180 → "3 hr", 185 → "3 hr 5 min",
/// 45 → "45 min", 0 → "0 min". Keeps the underlying storage in minutes so
/// nothing about the data model changes — this is display-only.
String formatCookTime(num? minutes) {
  final total = (minutes ?? 0).round();
  if (total <= 0) return '0 min';
  final h = total ~/ 60;
  final m = total % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h hr';
  return '$h hr $m min';
}
