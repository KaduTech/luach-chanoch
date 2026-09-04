import '../calendar/enoch_calendar.dart';

class DailyContent {
  const DailyContent(
      {required this.title, required this.reference, required this.prompt});
  final String title;
  final String reference;
  final String prompt;
}

class Observance {
  const Observance(this.month, this.day, this.name, this.description);
  final int month;
  final int day;
  final String name;
  final String description;
}

const List<DailyContent> weeklyReadingCycle = <DailyContent>[
  DailyContent(
      title: 'Creation and purpose',
      reference: 'Genesis 1:1–5',
      prompt: 'Consider the goodness of beginning again.'),
  DailyContent(
      title: 'Walk in wisdom',
      reference: 'Psalm 1',
      prompt: 'What path is being set before you today?'),
  DailyContent(
      title: 'Love the Lord',
      reference: 'Deuteronomy 6:4–9',
      prompt: 'Carry these words into your ordinary moments.'),
  DailyContent(
      title: 'Justice and mercy',
      reference: 'Micah 6:6–8',
      prompt: 'Choose one merciful action today.'),
  DailyContent(
      title: 'Light of the world',
      reference: 'Matthew 5:14–16',
      prompt: 'Let your good work point beyond yourself.'),
  DailyContent(
      title: 'Rest and delight',
      reference: 'Isaiah 58:13–14',
      prompt: 'Prepare your heart for Sabbath rest.'),
  DailyContent(
      title: 'Sabbath peace',
      reference: 'Exodus 20:8–11',
      prompt: 'Receive this day as holy and life-giving.'),
];

const List<Observance> observances = <Observance>[
  Observance(1, 14, 'Passover', 'Passover observance.'),
  Observance(
      1, 15, 'Unleavened Bread begins', 'First day of Unleavened Bread.'),
  Observance(
      1, 21, 'Unleavened Bread concludes', 'Final day of Unleavened Bread.'),
  Observance(3, 31, 'Summer Tekufah', 'Seasonal boundary day.'),
  Observance(6, 31, 'Autumn Tekufah', 'Seasonal boundary day.'),
  Observance(7, 1, 'Trumpets', 'Memorial day.'),
  Observance(7, 10, 'Day of Atonement', 'Day of Atonement observance.'),
  Observance(7, 15, 'Booths begins', 'First day of Booths.'),
  Observance(7, 21, 'Booths concludes', 'Final day of Booths.'),
  Observance(9, 31, 'Winter Tekufah', 'Seasonal boundary day.'),
  Observance(12, 31, 'Spring Tekufah', 'Seasonal boundary day.'),
];

DailyContent readingFor(EnochDate date) =>
    weeklyReadingCycle[date.weekdayIndex];

Observance? observanceFor(int month, int day) {
  for (final item in observances) {
    if (item.month == month && item.day == day) return item;
  }
  return null;
}

class UpcomingObservance {
  const UpcomingObservance({
    required this.observance,
    required this.enochDate,
  });

  final Observance observance;
  final EnochDate enochDate;
}

List<UpcomingObservance> upcomingObservances(
  EnochCalendar calendar,
  DateTime from, {
  int limit = 3,
}) {
  final current = calendar.fromGregorian(from);
  final normalizedFrom = DateTime(from.year, from.month, from.day);
  final candidates = <UpcomingObservance>[];
  for (final amYear in <int>[current.amYear, current.amYear + 1]) {
    for (final observance in observances) {
      final gregorian = calendar.toGregorian(
        amYear: amYear,
        month: observance.month,
        day: observance.day,
      );
      if (!gregorian.isBefore(normalizedFrom)) {
        candidates.add(UpcomingObservance(
          observance: observance,
          enochDate: calendar.fromGregorian(gregorian),
        ));
      }
    }
  }
  candidates.sort(
      (a, b) => a.enochDate.gregorianDate.compareTo(b.enochDate.gregorianDate));
  return candidates.take(limit).toList();
}
