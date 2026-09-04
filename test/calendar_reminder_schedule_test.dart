import 'package:flutter_test/flutter_test.dart';
import 'package:luach_chanoch/calendar/enoch_calendar.dart';
import 'package:luach_chanoch/notifications/calendar_reminder_schedule.dart';

void main() {
  final calendar = EnochCalendar(
    epoch: DateTime(2026, 3, 25),
    epochAmYear: 6029,
  );

  test('schedules upcoming Enoch Sabbaths at 6 PM', () {
    final from = DateTime(2026, 3, 25, 12);
    final reminders = upcomingCalendarReminders(calendar, from);
    final sabbaths = reminders
        .where((item) => item.kind == CalendarReminderKind.sabbath)
        .toList();

    expect(sabbaths, hasLength(16));
    expect(sabbaths.first.scheduledAt, DateTime(2026, 3, 28, 18));
    expect(sabbaths.every((item) => item.scheduledAt.isAfter(from)), isTrue);
    expect(
      sabbaths.every(
        (item) => calendar.fromGregorian(item.scheduledAt).isSabbath,
      ),
      isTrue,
    );
  });

  test('schedules reference observances at 9 AM', () {
    final from = DateTime(2026, 3, 25, 12);
    final reminders = upcomingCalendarReminders(calendar, from);
    final observanceReminders = reminders
        .where((item) => item.kind == CalendarReminderKind.observance)
        .toList();

    expect(observanceReminders, hasLength(36));
    expect(observanceReminders.first.title, 'Passover today');
    expect(observanceReminders.first.scheduledAt, DateTime(2026, 4, 7, 9));
    expect(
      observanceReminders.every((item) => item.scheduledAt.hour == 9),
      isTrue,
    );
  });
}
