import '../calendar/enoch_calendar.dart';
import '../content/daily_content.dart';

enum CalendarReminderKind { sabbath, observance }

class CalendarReminder {
  const CalendarReminder({
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
  });

  final CalendarReminderKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;
}

/// Calculates local reminder times independently from the device plugin.
List<CalendarReminder> upcomingCalendarReminders(
  EnochCalendar calendar,
  DateTime from, {
  int sabbathLimit = 16,
  int observanceLimit = 36,
}) {
  final reminders = <CalendarReminder>[];
  var cursor = DateTime(from.year, from.month, from.day);
  var sabbathsScheduled = 0;

  while (sabbathsScheduled < sabbathLimit) {
    final date = calendar.fromGregorian(cursor);
    final scheduledAt = DateTime(cursor.year, cursor.month, cursor.day, 18);
    if (date.isSabbath && scheduledAt.isAfter(from)) {
      reminders.add(CalendarReminder(
        kind: CalendarReminderKind.sabbath,
        scheduledAt: scheduledAt,
        title: 'Sabbath begins soon',
        body:
            'Prepare for Sabbath — ${date.monthName} ${date.day}, AM ${date.amYear}.',
      ));
      sabbathsScheduled++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }

  final currentYear = calendar
      .fromGregorian(
        DateTime(from.year, from.month, from.day),
      )
      .amYear;
  var observancesScheduled = 0;
  for (var amYear = currentYear;
      amYear <= currentYear + 3 && observancesScheduled < observanceLimit;
      amYear++) {
    for (final observance in observances) {
      if (observancesScheduled >= observanceLimit) break;
      final gregorianDate = calendar.toGregorian(
        amYear: amYear,
        month: observance.month,
        day: observance.day,
      );
      final scheduledAt = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        9,
      );
      if (!scheduledAt.isAfter(from)) continue;
      reminders.add(CalendarReminder(
        kind: CalendarReminderKind.observance,
        scheduledAt: scheduledAt,
        title: '${observance.name} today',
        body: 'Luach Chanoch observance: ${observance.description}',
      ));
      observancesScheduled++;
    }
  }

  return reminders;
}
