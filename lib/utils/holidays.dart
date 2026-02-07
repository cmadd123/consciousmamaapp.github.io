import 'package:flutter/material.dart';

/// US Federal Holidays and common celebrations
///
/// This class provides holiday information for the calendar
/// including emoji decorations and child birthdays
class Holidays {
  /// Check if a date is a holiday
  static bool isHoliday(DateTime date) {
    return getHoliday(date) != null;
  }

  /// Get holiday info for a date (returns null if not a holiday)
  static HolidayInfo? getHoliday(DateTime date) {
    // Normalize to start of day for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check fixed holidays
    for (final holiday in _fixedHolidays) {
      if (holiday.month == normalizedDate.month &&
          holiday.day == normalizedDate.day) {
        return holiday;
      }
    }

    // Check calculated holidays (Easter, Thanksgiving, etc.)
    final calculated = _getCalculatedHolidays(date.year);
    for (final holiday in calculated) {
      final holidayDate = DateTime(holiday.year ?? date.year, holiday.month, holiday.day);
      if (holidayDate.year == normalizedDate.year &&
          holidayDate.month == normalizedDate.month &&
          holidayDate.day == normalizedDate.day) {
        return holiday;
      }
    }

    return null;
  }

  /// Fixed date holidays (same date every year)
  static final List<HolidayInfo> _fixedHolidays = [
    HolidayInfo(name: "New Year's Day", month: 1, day: 1, emoji: '🎊', color: const Color(0xFFFFD700)),
    HolidayInfo(name: "Valentine's Day", month: 2, day: 14, emoji: '💝', color: const Color(0xFFFF69B4)),
    HolidayInfo(name: "St. Patrick's Day", month: 3, day: 17, emoji: '☘️', color: const Color(0xFF228B22)),
    HolidayInfo(name: "Independence Day", month: 7, day: 4, emoji: '🇺🇸', color: const Color(0xFF0055A4)),
    HolidayInfo(name: "Halloween", month: 10, day: 31, emoji: '🎃', color: const Color(0xFFFF8C00)),
    HolidayInfo(name: "Veterans Day", month: 11, day: 11, emoji: '🇺🇸', color: const Color(0xFF0055A4)),
    HolidayInfo(name: "Christmas Eve", month: 12, day: 24, emoji: '🎄', color: const Color(0xFF228B22)),
    HolidayInfo(name: "Christmas", month: 12, day: 25, emoji: '🎄', color: const Color(0xFFDC143C)),
    HolidayInfo(name: "New Year's Eve", month: 12, day: 31, emoji: '🎊', color: const Color(0xFFFFD700)),
  ];

  /// Get calculated holidays for a specific year
  static List<HolidayInfo> _getCalculatedHolidays(int year) {
    final holidays = <HolidayInfo>[];

    // MLK Day - 3rd Monday in January
    final mlkDay = _getNthWeekdayOfMonth(year, 1, DateTime.monday, 3);
    holidays.add(HolidayInfo(
      name: "MLK Jr. Day",
      month: mlkDay.month,
      day: mlkDay.day,
      year: year,
      emoji: '🌟',
      color: const Color(0xFF4B0082),
    ));

    // Presidents Day - 3rd Monday in February
    final presidentsDay = _getNthWeekdayOfMonth(year, 2, DateTime.monday, 3);
    holidays.add(HolidayInfo(
      name: "Presidents Day",
      month: presidentsDay.month,
      day: presidentsDay.day,
      year: year,
      emoji: '🇺🇸',
      color: const Color(0xFF0055A4),
    ));

    // Mother's Day - 2nd Sunday in May
    final mothersDay = _getNthWeekdayOfMonth(year, 5, DateTime.sunday, 2);
    holidays.add(HolidayInfo(
      name: "Mother's Day",
      month: mothersDay.month,
      day: mothersDay.day,
      year: year,
      emoji: '💐',
      color: const Color(0xFFFF69B4),
    ));

    // Memorial Day - Last Monday in May
    final memorialDay = _getLastWeekdayOfMonth(year, 5, DateTime.monday);
    holidays.add(HolidayInfo(
      name: "Memorial Day",
      month: memorialDay.month,
      day: memorialDay.day,
      year: year,
      emoji: '🇺🇸',
      color: const Color(0xFF0055A4),
    ));

    // Father's Day - 3rd Sunday in June
    final fathersDay = _getNthWeekdayOfMonth(year, 6, DateTime.sunday, 3);
    holidays.add(HolidayInfo(
      name: "Father's Day",
      month: fathersDay.month,
      day: fathersDay.day,
      year: year,
      emoji: '👔',
      color: const Color(0xFF1E90FF),
    ));

    // Labor Day - 1st Monday in September
    final laborDay = _getNthWeekdayOfMonth(year, 9, DateTime.monday, 1);
    holidays.add(HolidayInfo(
      name: "Labor Day",
      month: laborDay.month,
      day: laborDay.day,
      year: year,
      emoji: '⚒️',
      color: const Color(0xFF8B4513),
    ));

    // Thanksgiving - 4th Thursday in November
    final thanksgiving = _getNthWeekdayOfMonth(year, 11, DateTime.thursday, 4);
    holidays.add(HolidayInfo(
      name: "Thanksgiving",
      month: thanksgiving.month,
      day: thanksgiving.day,
      year: year,
      emoji: '🦃',
      color: const Color(0xFFFF8C00),
    ));

    return holidays;
  }

  /// Get the Nth occurrence of a weekday in a month
  static DateTime _getNthWeekdayOfMonth(int year, int month, int weekday, int n) {
    var date = DateTime(year, month, 1);
    var count = 0;

    while (date.month == month) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) {
          return date;
        }
      }
      date = date.add(const Duration(days: 1));
    }

    return date; // Fallback (shouldn't reach here)
  }

  /// Get the last occurrence of a weekday in a month
  static DateTime _getLastWeekdayOfMonth(int year, int month, int weekday) {
    var date = DateTime(year, month + 1, 0); // Last day of month

    while (date.weekday != weekday && date.month == month) {
      date = date.subtract(const Duration(days: 1));
    }

    return date;
  }
}

/// Information about a holiday
class HolidayInfo {
  final String name;
  final int month;
  final int day;
  final int? year; // For calculated holidays
  final String emoji;
  final Color color;

  HolidayInfo({
    required this.name,
    required this.month,
    required this.day,
    this.year,
    required this.emoji,
    required this.color,
  });
}

/// Information about a birthday
class BirthdayInfo {
  final String childName;
  final int month;
  final int day;
  final int? year; // Birth year (optional, for age calculation)
  final Color color;

  BirthdayInfo({
    required this.childName,
    required this.month,
    required this.day,
    this.year,
    required this.color,
  });

  /// Get age if birth year is known
  int? getAge(int currentYear) {
    if (year == null) return null;
    return currentYear - year!;
  }

  String get emoji => '🎂';
}
