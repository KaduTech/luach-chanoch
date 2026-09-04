import 'package:flutter/material.dart';

/// A documented 364-day solar calendar: 12 months of 30 days plus four
/// quarter-ending seasonal days (months 3, 6, 9, and 12).
class EnochCalendar {
  EnochCalendar({
    required this.epoch,
    required this.epochAmYear,
  });

  final DateTime epoch;
  final int epochAmYear;

  static const int daysPerYear = 364;
  static const List<String> monthNames = <String>[
    'Aviv', 'Ziv', 'Sivan', 'Tammuz', 'Av', 'Elul',
    'Ethanim', 'Bul', 'Kislev', 'Tevet', 'Shevat', 'Adar',
  ];

  EnochDate fromGregorian(DateTime date) {
    final DateTime normalized = DateUtils.dateOnly(date);
    final int delta = normalized.difference(DateUtils.dateOnly(epoch)).inDays;
    // Dart's integer division truncates toward zero; calendar years need floor
    // division so dates before the epoch land in the prior AM year.
    final int yearOffset = delta >= 0
        ? delta ~/ daysPerYear
        : ((delta + 1) ~/ daysPerYear) - 1;
    final int dayOfYear = delta % daysPerYear;
    int remaining = dayOfYear;
    int month = 1;
    while (remaining >= daysInMonth(month)) {
      remaining -= daysInMonth(month);
      month++;
    }
    return EnochDate(
      amYear: epochAmYear + yearOffset,
      month: month,
      day: remaining + 1,
      weekdayIndex: (2 + delta) % 7, // Wednesday is index 2
      dayOfYear: dayOfYear + 1,
      gregorianDate: normalized,
    );
  }

  DateTime toGregorian({required int amYear, required int month, required int day}) {
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(month)) {
      throw ArgumentError('Invalid Enoch calendar date.');
    }
    final int years = amYear - epochAmYear;
    var daysBeforeMonth = 0;
    for (var index = 1; index < month; index++) {
      daysBeforeMonth += daysInMonth(index);
    }
    return DateUtils.dateOnly(epoch).add(Duration(
      days: years * daysPerYear + daysBeforeMonth + day - 1,
    ));
  }

  int daysInMonth(int month) => month % 3 == 0 ? 31 : 30;

  String seasonFor(EnochDate date) {
    if (date.month <= 3) return 'Spring Tekufah';
    if (date.month <= 6) return 'Summer Tekufah';
    if (date.month <= 9) return 'Autumn Tekufah';
    return 'Winter Tekufah';
  }

  bool isSeasonalDay(EnochDate date) => date.month % 3 == 0 && date.day == 31;
}

class EnochDate {
  const EnochDate({
    required this.amYear,
    required this.month,
    required this.day,
    required this.weekdayIndex,
    required this.dayOfYear,
    required this.gregorianDate,
  });

  final int amYear;
  final int month;
  final int day;
  final int weekdayIndex;
  final int dayOfYear;
  final DateTime gregorianDate;

  String get monthName => EnochCalendar.monthNames[month - 1];
  String get weekday => const <String>[
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Sabbath', 'Sunday',
  ][weekdayIndex];
  bool get isSabbath => weekdayIndex == 5;
}
